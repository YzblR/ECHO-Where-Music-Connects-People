import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> conversations = [
    {
      'name': 'Sevi Camero',
      'username': '@cameroRoar',
      'message': 'That song is so good!',
      'time': '10:42 AM',
      'image': 'https://i.pravatar.cc/150?img=47',
      'unread': true,
    },
    {
      'name': 'Duke Laurence',
      'username': '@dukeLangsakalam',
      'message': 'You should listen to this playlist.',
      'time': '9:15 AM',
      'image': 'https://i.pravatar.cc/150?img=12',
      'unread': true,
    },
    {
      'name': 'Akihiro Leonell',
      'username': '@youCaptain',
      'message': 'I love that artist too!',
      'time': 'Yesterday',
      'image': 'https://i.pravatar.cc/150?img=32',
      'unread': false,
    },
    {
      'name': 'Emma Paige',
      'username': '@cutesyEmmz',
      'message': 'See you later!',
      'time': 'Yesterday',
      'image': 'https://i.pravatar.cc/150?img=11',
      'unread': false,
    },
    {
      'name': 'Serene Lovely',
      'username': '@loveSerene',
      'message': 'Have you heard their new album?',
      'time': 'Monday',
      'image': 'https://i.pravatar.cc/150?img=44',
      'unread': false,
    },
    {
      'name': 'Soledad Bellandie',
      'username': '@sol',
      'message': 'Are you going to Bruno Mars concert?',
      'time': 'Tuesday',
      'image': 'https://i.pravatar.cc/150?img=44',
      'unread': true,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // NAVIGATION
  // ================================================================

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void goToSearch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }

  void goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final searchText = searchController.text.toLowerCase();

    final filteredConversations = conversations.where((conversation) {
      final name = conversation['name'].toString().toLowerCase();
      final username = conversation['username'].toString().toLowerCase();

      return name.contains(searchText) || username.contains(searchText);
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
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
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
                            'New message feature is coming soon.',
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  contentPadding: const EdgeInsets.symmetric(
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
            // CONVERSATIONS
            // ==========================================================

            Expanded(
              child: filteredConversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 34,
                              color: EchoColors.primary,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'No messages found',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Try searching for another person.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        5,
                        20,
                        20,
                      ),
                      itemCount: filteredConversations.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 5);
                      },
                      itemBuilder: (context, index) {
                        final conversation =
                            filteredConversations[index];

                        return ConversationTile(
                          name: conversation['name'],
                          username: conversation['username'],
                          message: conversation['message'],
                          time: conversation['time'],
                          unread: conversation['unread'],
                          onTap: () async {
                            final result =
                                await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  name: conversation['name'],
                                  username: conversation['username'],
                                  initialMessage:
                                      conversation['message'],
                                ),
                              ),
                            );

                            if (result != null &&
                                result.trim().isNotEmpty) {
                              setState(() {
                                conversation['message'] = result;
                                conversation['time'] = 'now';
                                conversation['unread'] = false;
                              });
                            }
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: unread
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),

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
                          overflow: TextOverflow.ellipsis,
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
                          decoration: const BoxDecoration(
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
  final String initialMessage;

  const ChatScreen({
    super.key,
    required this.name,
    required this.username,
    required this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    messages.add({
      'text': widget.initialMessage,
      'isMe': false,
    });

    messages.add({
      'text': 'I know right! I have been listening to it all day.',
      'isMe': false,
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ================================================================
  // SEND MESSAGE
  // ================================================================

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        'text': text,
        'isMe': true,
      });
    });

    messageController.clear();
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
            final lastMyMessage = messages
                .where((message) => message['isMe'] == true)
                .toList();

            Navigator.pop(
              context,
              lastMyMessage.isNotEmpty
                  ? lastMyMessage.last['text']
                  : null,
            );
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'More options coming soon.',
                  ),
                  behavior: SnackBarBehavior.floating,
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                18,
                20,
                18,
                15,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return ChatBubble(
                  text: message['text'],
                  isMe: message['isMe'],
                );
              },
            ),
          ),

          // ==========================================================
          // MESSAGE INPUT
          // ==========================================================

          Container(
            padding: const EdgeInsets.fromLTRB(
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
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: EchoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? EchoColors.primary
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(
              isMe ? 17 : 4,
            ),
            bottomRight: Radius.circular(
              isMe ? 4 : 17,
            ),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: Colors.grey.shade200,
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: isMe
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
        color: selected
            ? EchoColors.primary
            : Colors.grey,
      ),
    );
  }
}