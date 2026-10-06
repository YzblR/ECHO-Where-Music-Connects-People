import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final captionController = TextEditingController();

  String selectedPostType = 'Music';

  bool isPosting = false;

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> createPost() async {
    final caption = captionController.text.trim();

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before posting.')),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before creating a post.')),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      await Supabase.instance.client.from('posts').insert({
        'user_id': user.id,
        'post_type': selectedPostType,
        'caption': caption,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: isPosting
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),

        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed: isPosting ? null : createPost,
            child: isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: EchoColors.primary,
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      color: EchoColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // USER
            // ---------------------------------------------------------------

            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=47',
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Your Name',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      '@yourusername',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ---------------------------------------------------------------
            // POST TYPE
            // ---------------------------------------------------------------
            const Text(
              'What do you want to share?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _PostTypeButton(
                  icon: Icons.music_note_rounded,
                  label: 'Music',
                  selected: selectedPostType == 'Music',
                  onTap: () {
                    setState(() {
                      selectedPostType = 'Music';
                    });
                  },
                ),

                const SizedBox(width: 10),

                _PostTypeButton(
                  icon: Icons.playlist_play_rounded,
                  label: 'Playlist',
                  selected: selectedPostType == 'Playlist',
                  onTap: () {
                    setState(() {
                      selectedPostType = 'Playlist';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ---------------------------------------------------------------
            // CAPTION
            // ---------------------------------------------------------------
            const Text(
              'Caption',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: captionController,
              maxLines: 5,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Share something about your music...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------------------------------------------------------
            // ADD MUSIC / PLAYLIST
            // ---------------------------------------------------------------
            if (selectedPostType == 'Music') _AddMusicCard(),

            if (selectedPostType == 'Playlist') _AddPlaylistCard(),

            const SizedBox(height: 25),

            // ---------------------------------------------------------------
            // POST PREVIEW
            // ---------------------------------------------------------------
            const Text(
              'Preview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4AFC8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      selectedPostType == 'Music'
                          ? Icons.music_note_rounded
                          : Icons.playlist_play_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedPostType == 'Music'
                              ? 'Music Post'
                              : 'Playlist Post',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          captionController.text.isEmpty
                              ? 'Your caption will appear here'
                              : captionController.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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

// ===========================================================================
// POST TYPE BUTTON
// ===========================================================================

class _PostTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PostTypeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? EchoColors.primary : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : Colors.black87,
            ),

            const SizedBox(width: 6),

            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// ADD MUSIC
// ===========================================================================

class _AddMusicCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Spotify search can be connected here later.
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EchoColors.secondary),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: EchoColors.primary,
              size: 28,
            ),

            SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Music',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 3),

                Text(
                  'Search for a song or artist',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// ADD PLAYLIST
// ===========================================================================

class _AddPlaylistCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Playlist selection can be connected later.
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EchoColors.secondary),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: EchoColors.primary,
              size: 28,
            ),

            SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Playlist',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 3),

                Text(
                  'Choose a playlist to share',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
