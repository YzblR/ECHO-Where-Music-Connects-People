import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import 'search_screen.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedFeed = 0;

  List<Map<String, dynamic>> posts = [];
  bool isLoadingPosts = true;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser {
    return Supabase.instance.client.auth.currentUser;
  }

  String get username {
    final metadata = currentUser?.userMetadata;

    final value = metadata?['username']?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value;
    }

    return currentUser?.email?.split('@').first ?? 'User';
  }

  String get email {
    return currentUser?.email ?? '';
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  // ============================================================
  // LOAD POSTS
  // ============================================================

  Future<void> loadPosts() async {
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        posts = List<Map<String, dynamic>>.from(data);
        isLoadingPosts = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingPosts = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unable to load posts.')));
    }
  }

  // ============================================================
  // CREATE POST
  // ============================================================

  Future<void> openCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      await loadPosts();
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void goToSearch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadPosts,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ======================================================
                      // HEADER
                      // ======================================================

                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                        child: Row(
                          children: [
                            const Text(
                              'echo',
                              style: TextStyle(
                                color: EchoColors.primary,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 3),

                            GestureDetector(
                              onTap: goToProfile,
                              child: CircleAvatar(
                                radius: 17,
                                backgroundColor: EchoColors.secondary,
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ======================================================
                      // STORIES
                      // ======================================================
                      SizedBox(
                        height: 91,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          children: [
                            StoryItem(
                              name: 'Your Story',
                              username: username,
                              image: '',
                              hasPlus: true,
                              isCurrentUser: true,
                              onTap: goToProfile,
                            ),

                            const StoryItem(
                              name: 'Garrett',
                              username: 'Garrett',
                              image: 'https://i.pravatar.cc/150?img=12',
                            ),

                            const StoryItem(
                              name: 'Dean',
                              username: 'Dean',
                              image: 'https://i.pravatar.cc/150?img=11',
                            ),

                            const StoryItem(
                              name: 'Justin',
                              username: 'Justin',
                              image: 'https://i.pravatar.cc/150?img=13',
                            ),

                            const StoryItem(
                              name: 'Logan',
                              username: 'Logan',
                              image: 'https://i.pravatar.cc/150?img=14',
                            ),
                          ],
                        ),
                      ),

                      // ======================================================
                      // FOR YOU / FOLLOWING
                      // ======================================================
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFeed = 0;
                                });
                              },
                              child: FeedTab(
                                title: 'For You',
                                selected: selectedFeed == 0,
                              ),
                            ),
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFeed = 1;
                                });
                              },
                              child: FeedTab(
                                title: 'Following',
                                selected: selectedFeed == 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 1, color: Color(0xFFE5E5E5)),

                      // ======================================================
                      // FEED
                      // ======================================================
                      if (selectedFeed == 0) ...[
                        // ----------------------------------------------------
                        // USER'S SUPABASE POSTS
                        // ----------------------------------------------------

                        if (isLoadingPosts)
                          const Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              color: EchoColors.primary,
                            ),
                          ),

                        if (!isLoadingPosts && posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              'No posts yet. Create your first post!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                        ...posts.map((post) {
                          final postType =
                              post['post_type']?.toString() ?? 'Music';

                          final caption = post['caption']?.toString() ?? '';

                          final createdAt = post['created_at']?.toString();

                          return postType == 'Playlist'
                              ? PlaylistPost(
                                  username: username,
                                  time: formatTime(createdAt),
                                  profileImage: '',
                                  albumImage: 'https://picsum.photos/seed/echoPlaylist/300/300',
                                  playlistTitle: 'My Playlist',
                                  subtitle: caption,
                                  songs: 'Playlist',
                                  likes: '0',
                                  comments: '0',
                                )
                              : MusicPost(
                                  username: username,
                                  time: formatTime(createdAt),
                                  profileImage: '',
                                  albumImage: 'https://picsum.photos/seed/echoMusic/300/300',
                                  song: 'Music Post',
                                  artist: 'ECHO',
                                  tag: 'Music',
                                  caption: caption,
                                  likes: '0',
                                  comments: '0',
                                );
                        }),

                        // ----------------------------------------------------
                        // HANNAH POST
                        // ----------------------------------------------------
                        const MusicPost(
                          username: 'Hannah',
                          time: '2h ago',
                          profileImage: 'https://i.pravatar.cc/150?img=45',
                          albumImage:
                              'https://picsum.photos/seed/babynow/300/300',
                          song: 'Baby Now That I Found You',
                          artist: 'Ella Bright',
                          tag: 'Review',
                          caption: 'this song feels like finding the right person at the right time. <3',
                          likes: '10K',
                          comments: '2K',
                        ),

                        // ----------------------------------------------------
                        // ZAZA POST
                        // ----------------------------------------------------
                        const PlaylistPost(
                          username: 'Zaza',
                          time: '1h ago',
                          profileImage: 'https://i.pravatar.cc/150?img=32',
                          albumImage: 'https://picsum.photos/seed/fallingforyou/300/300',
                          playlistTitle: 'Falling For You',
                          subtitle: 'Every song reminds me of you',
                          songs: '143 songs',
                          likes: '20K',
                          comments: '5K',
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'Posts from people you follow will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // BOTTOM NAVIGATION
            // ============================================================
            Container(
              height: 66,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // HOME

                  BottomNavIcon(
                    icon: Icons.home_rounded,
                    selected: true,
                    onTap: () {},
                  ),

                  // SEARCH
                  BottomNavIcon(
                    icon: Icons.search_rounded,
                    selected: false,
                    onTap: goToSearch,
                  ),

                  // CREATE POST
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: openCreatePost,
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: EchoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // MESSAGES
                  BottomNavIcon(
                    icon: Icons.chat_bubble_outline_rounded,
                    selected: false,
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

// ============================================================
// TIME FORMAT
// ============================================================

String formatTime(String? dateString) {
  if (dateString == null) {
    return 'Just now';
  }

  final date = DateTime.tryParse(dateString);

  if (date == null) {
    return 'Just now';
  }

  final difference = DateTime.now().difference(date);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }

  return '${difference.inDays}d ago';
}

// ============================================================
// STORY
// ============================================================

class StoryItem extends StatelessWidget {
  final String name;
  final String username;
  final String image;
  final bool hasPlus;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const StoryItem({
    super.key,
    required this.name,
    required this.username,
    required this.image,
    this.hasPlus = false,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: EchoColors.primary,
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: EchoColors.secondary,
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                ),

                if (hasPlus)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: const BoxDecoration(
                        color: EchoColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              isCurrentUser ? username : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FEED TAB
// ============================================================

class FeedTab extends StatelessWidget {
  final String title;
  final bool selected;

  const FeedTab({super.key, required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? EchoColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? EchoColors.primary : Colors.black87,
        ),
      ),
    );
  }
}

// ============================================================
// MUSIC POST
// ============================================================

class MusicPost extends StatelessWidget {
  final String username;
  final String time;
  final String profileImage;
  final String albumImage;
  final String song;
  final String artist;
  final String tag;
  final String caption;
  final String likes;
  final String comments;

  const MusicPost({
    super.key,
    required this.username,
    required this.time,
    required this.profileImage,
    required this.albumImage,
    required this.song,
    required this.artist,
    required this.tag,
    required this.caption,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: EchoColors.secondary,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),

              const SizedBox(width: 9),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(Icons.more_horiz, size: 22),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  albumImage,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        artist,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: EchoColors.primary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: EchoColors.primary,
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 20,
                            color: EchoColors.primary,
                          ),

                          SizedBox(width: 5),

                          Text(
                            'Listen',
                            style: TextStyle(
                              fontSize: 11,
                              color: EchoColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            caption,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, size: 18),

              const SizedBox(width: 4),

              Text(likes, style: const TextStyle(fontSize: 10)),

              const SizedBox(width: 16),

              const Icon(Icons.chat_bubble_outline_rounded, size: 17),

              const SizedBox(width: 4),

              Text(comments, style: const TextStyle(fontSize: 10)),

              const SizedBox(width: 16),

              const Icon(Icons.repeat, size: 17),
            ],
          ),

          const SizedBox(height: 13),

          const Divider(height: 1, color: Color(0xFFE5E5E5)),
        ],
      ),
    );
  }
}

// ============================================================
// PLAYLIST POST
// ============================================================

class PlaylistPost extends StatelessWidget {
  final String username;
  final String time;
  final String profileImage;
  final String albumImage;
  final String playlistTitle;
  final String subtitle;
  final String songs;
  final String likes;
  final String comments;

  const PlaylistPost({
    super.key,
    required this.username,
    required this.time,
    required this.profileImage,
    required this.albumImage,
    required this.playlistTitle,
    required this.subtitle,
    required this.songs,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: EchoColors.secondary,
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),

              const SizedBox(width: 9),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$username shared a playlist',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(Icons.more_horiz, size: 22),
            ],
          ),

          const SizedBox(height: 11),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  albumImage,
                  width: 95,
                  height: 95,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlistTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Text(
                      songs,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, size: 18),

              const SizedBox(width: 4),

              Text(likes, style: const TextStyle(fontSize: 10)),

              const SizedBox(width: 16),

              const Icon(Icons.chat_bubble_outline_rounded, size: 17),

              const SizedBox(width: 4),

              Text(comments, style: const TextStyle(fontSize: 10)),

              const SizedBox(width: 16),

              const Icon(Icons.repeat, size: 17),
            ],
          ),

          const SizedBox(height: 13),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION ICON
// ============================================================

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
        color: selected ? EchoColors.primary : Colors.grey,
      ),
    );
  }
}
