
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';

class PostInteractions extends StatefulWidget {
  final String postId;

  const PostInteractions({
    super.key,
    required this.postId,
  });

  @override
  State<PostInteractions> createState() => _PostInteractionsState();
}

class _PostInteractionsState extends State<PostInteractions> {
  final SupabaseClient supabase = Supabase.instance.client;

  int likeCount = 0;
  int commentCount = 0;

  bool isLiked = false;
  bool isSaved = false;
  bool isLoading = true;
  bool isBusy = false;

  User? get user => supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    loadInteractions();
  }

  // ============================================================
  // LOAD LIKES, COMMENTS, AND SAVED STATUS
  // ============================================================

  Future<void> loadInteractions() async {
    try {
      final likes = await supabase
          .from('post_likes')
          .select('id, user_id')
          .eq('post_id', widget.postId);

      final comments = await supabase
          .from('post_comments')
          .select('id')
          .eq('post_id', widget.postId);

      bool liked = false;
      bool saved = false;

      if (user != null) {
        liked = (likes as List).any(
          (item) => item['user_id'].toString() == user!.id,
        );

        final savedRows = await supabase
            .from('saved_posts')
            .select('id')
            .eq('post_id', widget.postId)
            .eq('user_id', user!.id);

        saved = (savedRows as List).isNotEmpty;
      }

      if (!mounted) return;

      setState(() {
        likeCount = (likes as List).length;
        commentCount = (comments as List).length;
        isLiked = liked;
        isSaved = saved;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('LOAD INTERACTIONS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // LIKE / UNLIKE
  // ============================================================

  Future<void> toggleLike() async {
    if (user == null) {
      showMessage('Please log in to like posts.');
      return;
    }

    if (isBusy) return;

    setState(() => isBusy = true);

    try {
      if (isLiked) {
        await supabase
            .from('post_likes')
            .delete()
            .eq('post_id', widget.postId)
            .eq('user_id', user!.id);
      } else {
        await supabase.from('post_likes').insert({
          'post_id': widget.postId,
          'user_id': user!.id,
        });
      }

      await loadInteractions();
    } catch (e) {
      debugPrint('LIKE ERROR: $e');
      showMessage('Like error: $e');
    } finally {
      if (mounted) {
        setState(() => isBusy = false);
      }
    }
  }

  // ============================================================
  // SAVE / UNSAVE
  // ============================================================

  Future<void> toggleSave() async {
    if (user == null) {
      showMessage('Please log in to save posts.');
      return;
    }

    if (isBusy) return;

    setState(() => isBusy = true);

    try {
      if (isSaved) {
        await supabase
            .from('saved_posts')
            .delete()
            .eq('post_id', widget.postId)
            .eq('user_id', user!.id);
      } else {
        await supabase.from('saved_posts').insert({
          'post_id': widget.postId,
          'user_id': user!.id,
        });
      }

      await loadInteractions();
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
      showMessage('Save error: $e');
    } finally {
      if (mounted) {
        setState(() => isBusy = false);
      }
    }
  }

  // ============================================================
  // COMMENTS
  // ============================================================

  Future<void> openComments() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => CommentsSheet(postId: widget.postId),
    );

    if (mounted) {
      await loadInteractions();
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: toggleLike,
          child: Row(
            children: [
              Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
                color: isLiked ? EchoColors.primary : Colors.black87,
              ),
              const SizedBox(width: 4),
              Text(
                isLoading ? '...' : '$likeCount',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: openComments,
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                isLoading ? '...' : '$commentCount',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: toggleSave,
          child: Icon(
            isSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 19,
            color: isSaved ? EchoColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COMMENTS SHEET
// ============================================================

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> comments = [];

  bool loading = true;
  bool sending = false;

  User? get user => supabase.auth.currentUser;

  String get username {
    final value = user?.userMetadata?['username']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return user?.email?.split('@').first ?? 'User';
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD COMMENTS
  // ============================================================

  Future<void> loadComments() async {
    try {
      final data = await supabase
          .from('post_comments')
          .select()
          .eq('post_id', widget.postId)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        comments = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint('LOAD COMMENTS ERROR: $e');

      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comments error: $e')),
      );
    }
  }

  // ============================================================
  // SEND COMMENT
  // ============================================================

  Future<void> sendComment() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to comment.'),
        ),
      );
      return;
    }

    if (sending) return;

    setState(() => sending = true);

    try {
      await supabase.from('post_comments').insert({
        'post_id': widget.postId,
        'user_id': user!.id,
        'username': username,
        'comment': text,
      });

      controller.clear();
      await loadComments();
    } catch (e) {
      debugPrint('SEND COMMENT ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: EchoColors.primary,
                        ),
                      )
                    : comments.isEmpty
                        ? const Center(
                            child: Text('Be the first to comment.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final item = comments[index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['username']?.toString() ??
                                          'User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item['comment']?.toString() ?? '',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendComment(),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sending ? null : sendComment,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: EchoColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}