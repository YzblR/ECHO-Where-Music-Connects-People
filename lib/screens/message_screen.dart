import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController searchController = TextEditingController();

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  Map<String, Map<String, dynamic>> latestMessages = {};

  bool isLoading = true;

  User? get currentUser => supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    loadUsersAndMessages();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // LOAD USERS AND MESSAGES
  // ================================================================

  Future<void> loadUsersAndMessages() async {
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get all registered users except the current user.
      final profileData = await supabase
          .from('profiles')
          .select('id, username, email')
          .neq('id', currentUser!.id)
          .order('username');

      final profileList =
          List<Map<String, dynamic>>.from(profileData);

      // Get all messages involving the current user.
      final messageData = await supabase
          .from('messages')
          .select('id, sender_id, receiver_id, message, created_at')
          .or(
            'sender_id.eq.${currentUser!.id},'
            'receiver_id.eq.${currentUser!.id}',
          )
          .order('created_at', ascending: false);

      final messageList =
          List<Map<String, dynamic>>.from(messageData);

      final Map<String, Map<String, dynamic>> latest = {};

      // Find the latest message for each conversation.
      for (final message in messageList) {
        final senderId = message['sender_id']?.toString();
        final receiverId = message['receiver_id']?.toString();

        if (senderId == null || receiverId == null) {
          continue;
        }

        final otherUserId =
            senderId == currentUser!.id ? receiverId : senderId;

        if (!latest.containsKey(otherUserId)) {
          latest[otherUserId] = message;
        }
      }

      if (!mounted) return;

      setState(() {
        users = profileList;
        latestMessages = latest;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load messages: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ================================================================
  // NAVIGATION
  // ================================================================

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void goToSearch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
  }

  void goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  // ================================================================
  // FORMAT MESSAGE TIME
  // ================================================================

  String formatMessageTime(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return '';
    }

    final localDate = date.toLocal();
    final now = DateTime.now();

    final difference = now.difference(localDate);

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return '${localDate.month}/${localDate.day}';
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final searchText =
        searchController.text.trim().toLowerCase();

    final filteredUsers = users.where((user) {
      final username =
          user['username']?.toString().toLowerCase() ?? '';

      final email =
          user['email']?.toString().toLowerCase() ?? '';

      return username.contains(searchText) ||
          email.contains(searchText);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                12,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Select a user below to start a conversation.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // SEARCH
            // ==========================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 21,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: EchoColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==========================================================
            // USERS / CONVERSATIONS
            // ==========================================================

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: EchoColors.primary,
                      ),
                    )
                  : filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFFFE8F0),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 34,
                                  color: EchoColors.primary,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Text(
                                searchText.isEmpty
                                    ? 'No users found'
                                    : 'No users found',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                searchText.isEmpty
                                    ? 'There are no other registered users yet.'
                                    : 'Try searching for another person.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            5,
                            20,
                            20,
                          ),
                          itemCount: filteredUsers.length,
                          separatorBuilder:
                              (context, index) {
                            return const SizedBox(height: 5);
                          },
                          itemBuilder: (context, index) {
                            final user =
                                filteredUsers[index];

                            final userId =
                                user['id'].toString();

                            final username =
                                user['username']
                                        ?.toString() ??
                                    'User';

                            final email =
                                user['email']
                                        ?.toString() ??
                                    '';

                            final latest =
                                latestMessages[userId];

                            final message =
                                latest?['message']
                                        ?.toString() ??
                                    'Start a conversation';

                            final time =
                                formatMessageTime(
                              latest?['created_at']
                                  ?.toString(),
                            );

                            final unread = false;

                            return ConversationTile(
                              name: username,
                              username: email,
                              message: message,
                              time: time,
                              unread: unread,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(
                                      name: username,
                                      username: email,
                                      receiverId: userId,
                                    ),
                                  ),
                                );

                                // Refresh when returning
                                // from the chat.
                                loadUsersAndMessages();
                              },
                            );
                          },
                        ),
            ),

            // ==========================================================
            // BOTTOM NAVIGATION
            // ==========================================================

            Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  // HOME
                  BottomNavIcon(
                    icon: Icons.home_rounded,
                    selected: false,
                    onTap: goToHome,
                  ),

                  // SEARCH
                  BottomNavIcon(
                    icon: Icons.search_rounded,
                    selected: false,
                    onTap: goToSearch,
                  ),

                  // PLUS
                  GestureDetector(
                    onTap: goToCreatePost,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: EchoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // MESSAGES
                  BottomNavIcon(
                    icon: Icons.chat_bubble_rounded,
                    selected: true,
                    onTap: () {},
                  ),

                  // PROFILE
                  BottomNavIcon(
                    icon: Icons.person_outline_rounded,
                    selected: false,
                    onTap: goToProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CONVERSATION TILE
// ============================================================================

class ConversationTile extends StatelessWidget {
  final String name;
  final String username;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.name,
    required this.username,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: 3,
        ),
        child: Row(
          children: [
            // AVATAR
            const CircleAvatar(
              radius: 27,
              backgroundColor: Color(0xFFF4AFC8),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),

            const SizedBox(width: 13),

            // MESSAGE INFO
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),

                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: unread
                                ? EchoColors.primary
                                : Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: unread
                                ? Colors.black87
                                : Colors.grey.shade600,
                            fontWeight: unread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      if (unread) ...[
                        const SizedBox(width: 8),

                        Container(
                          width: 8,
                          height: 8,
                          decoration:
                              const BoxDecoration(
                            color: EchoColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CHAT SCREEN
// ============================================================================

class ChatScreen extends StatefulWidget {
  final String name;
  final String username;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.username,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> messages = [];

  bool isLoading = true;
  bool isSending = false;

  User? get currentUser => supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ================================================================
  // LOAD MESSAGES
  // ================================================================

  Future<void> loadMessages() async {
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get messages involving the current user.
      final data = await supabase
          .from('messages')
          .select(
            'id, sender_id, receiver_id, message, created_at',
          )
          .or(
            'sender_id.eq.${currentUser!.id},'
            'receiver_id.eq.${currentUser!.id}',
          )
          .order('created_at');

      final allMessages =
          List<Map<String, dynamic>>.from(data);

      // Keep only messages between this user and
      // the selected person.
      final conversation = allMessages.where((message) {
        final senderId =
            message['sender_id']?.toString();

        final receiverId =
            message['receiver_id']?.toString();

        return (senderId == currentUser!.id &&
                receiverId == widget.receiverId) ||
            (senderId == widget.receiverId &&
                receiverId == currentUser!.id);
      }).toList();

      if (!mounted) return;

      setState(() {
        messages = conversation;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load messages: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ================================================================
  // SEND MESSAGE
  // ================================================================

  Future<void> sendMessage() async {
    final text =
        messageController.text.trim();

    if (text.isEmpty || isSending) {
      return;
    }

    if (currentUser == null) {
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final result = await supabase
          .from('messages')
          .insert({
            'sender_id': currentUser!.id,
            'receiver_id': widget.receiverId,
            'message': text,
          })
          .select()
          .single();

      messageController.clear();

      if (!mounted) return;

      setState(() {
        messages.add(
          Map<String, dynamic>.from(result),
        );
        isSending = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send message: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 19,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFF4AFC8),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  widget.username,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content:
                      Text('More options coming soon.'),
                  behavior:
                      SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ==========================================================
          // MESSAGES
          // ==========================================================

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: EchoColors.primary,
                    ),
                  )
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFFFE8F0,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(20),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 34,
                                color:
                                    EchoColors.primary,
                              ),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'Start the conversation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Send a message to ${widget.name}.',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(
                          18,
                          20,
                          18,
                          15,
                        ),
                        itemCount: messages.length,
                        itemBuilder:
                            (context, index) {
                          final message =
                              messages[index];

                          final senderId =
                              message['sender_id']
                                  ?.toString();

                          final isMe =
                              senderId ==
                                  currentUser?.id;

                          return ChatBubble(
                            text: message['message']
                                    ?.toString() ??
                                '',
                            isMe: isMe,
                          );
                        },
                      ),
          ),

          // ==========================================================
          // MESSAGE INPUT
          // ==========================================================

          Container(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              10,
              15,
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          messageController,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        sendMessage();
                      },
                      decoration:
                          InputDecoration(
                        hintText:
                            'Write a message...',
                        hintStyle: TextStyle(
                          color:
                              Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor:
                            const Color(0xFFF6F6F6),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: isSending
                        ? null
                        : sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration:
                          const BoxDecoration(
                        color: EchoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CHAT BUBBLE
// ============================================================================

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.72,
        ),
        margin:
            const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color:
              isMe
                  ? EchoColors.primary
                  : Colors.white,
          borderRadius:
              BorderRadius.only(
            topLeft:
                const Radius.circular(17),
            topRight:
                const Radius.circular(17),
            bottomLeft:
                Radius.circular(
              isMe ? 17 : 4,
            ),
            bottomRight:
                Radius.circular(
              isMe ? 4 : 17,
            ),
          ),
          border:
              isMe
                  ? null
                  : Border.all(
                      color:
                          Colors.grey.shade200,
                    ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color:
                isMe
                    ? Colors.white
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BOTTOM NAVIGATION ICON
// ============================================================================

class BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const BottomNavIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 25,
        color:
            selected
                ? EchoColors.primary
                : Colors.grey,
      ),
    );
  }
}