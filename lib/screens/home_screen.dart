import 'package:flutter/material.dart';

import '../theme.dart';
import 'search_screen.dart';
import 'create_post_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedFeed = 0;

  // ============================================================
  // CREATED POSTS
  // ============================================================

  // Stores posts created by the user during this HomeScreen session.
  final List<Map<String, String>> createdPosts = [];

  // ============================================================
  // NAVIGATION
  // ============================================================

  void goToSearch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  // UPDATED:
  // Waits for CreatePostScreen to return the created post.
  Future<void> goToCreatePost() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    // If a post was successfully created
    if (result != null) {
      setState(() {
        // Put the newest post at the top of the feed.
        createdPosts.insert(0, result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your post has been added to the feed!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void goToMessages() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MessageScreen()),
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
              child: SingleChildScrollView(
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No new notifications.'),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 3),

                          const CircleAvatar(
                            radius: 17,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=47',
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
                        children: const [
                          StoryItem(
                            name: 'Your Story',
                            image: 'https://i.pravatar.cc/150?img=47',
                            hasPlus: true,
                          ),
                          StoryItem(
                            name: 'Garrett',
                            image: 'https://i.pravatar.cc/150?img=12',
                          ),
                          StoryItem(
                            name: 'Dean',
                            image: 'https://i.pravatar.cc/150?img=11',
                          ),
                          StoryItem(
                            name: 'Justin',
                            image: 'https://i.pravatar.cc/150?img=13',
                          ),
                          StoryItem(
                            name: 'Logan',
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
                      // ====================================================
                      // USER CREATED POSTS
                      // ====================================================

                      ...createdPosts.map((post) {
                        // -------------------------------
                        // CREATED PLAYLIST POST
                        // -------------------------------

                        if (post['type'] == 'Playlist') {
                          return PlaylistPost(
                            username: 'Yzabela',
                            time: 'Just now',
                            profileImage: 'https://i.pravatar.cc/150?img=47',
                            albumImage:
                                'https://picsum.photos/seed/${post['playlistTitle'] ?? 'playlist'}/300/300',
                            playlistTitle: post['playlistTitle'] ?? '',
                            subtitle: post['caption'] ?? '',
                            songs: post['songCount'] ?? '',
                            likes: 0,
                            comments: 0,
                          );
                        }

                        // -------------------------------
                        // CREATED MUSIC POST
                        // -------------------------------

                        return MusicPost(
                          username: 'Yzabela',
                          time: 'Just now',
                          profileImage: 'https://i.pravatar.cc/150?img=47',
                          albumImage:
                              'https://picsum.photos/seed/${post['songTitle'] ?? 'music'}/300/300',
                          song: post['songTitle'] ?? '',
                          artist: post['artist'] ?? '',
                          tag: 'Music',
                          caption: post['caption'] ?? '',
                          likes: 0,
                          comments: 0,
                        );
                      }),

                      // ====================================================
                      // HANNAH MUSIC POST
                      // ====================================================
                      MusicPost(
                        username: 'Hannah',
                        time: '2h ago',
                        profileImage: 'https://i.pravatar.cc/150?img=45',
                        albumImage:
                            'https://picsum.photos/seed/babynow/300/300',
                        song: 'Baby Now That I Found You',
                        artist: 'Ella Bright',
                        tag: 'Review',
                        caption: 'this song feels like finding the right person at the right time. <3',
                        likes: 10000,
                        comments: 2000,
                      ),

                      // ====================================================
                      // ZAZA PLAYLIST POST
                      // ====================================================
                      PlaylistPost(
                        username: 'Zaza',
                        time: '1h ago',
                        profileImage: 'https://i.pravatar.cc/150?img=32',
                        albumImage:
                            'https://picsum.photos/seed/fallingforyou/300/300',
                        playlistTitle: 'Falling For You',
                        subtitle: 'Every song reminds me of you',
                        songs: '143 songs',
                        likes: 20000,
                        comments: 5000,
                      ),
                    ] else ...[
                      // ====================================================
                      // FOLLOWING EMPTY STATE
                      // ====================================================

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
                    onTap: goToCreatePost,
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
                    onTap: goToMessages,
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
// STORY
// ============================================================

class StoryItem extends StatelessWidget {
  final String name;
  final String image;
  final bool hasPlus;

  const StoryItem({
    super.key,
    required this.name,
    required this.image,
    this.hasPlus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  backgroundImage: NetworkImage(image),
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
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
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

class MusicPost extends StatefulWidget {
  final String username;
  final String time;
  final String profileImage;
  final String albumImage;
  final String song;
  final String artist;
  final String tag;
  final String caption;
  final int likes;
  final int comments;

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
  State<MusicPost> createState() => _MusicPostState();
}

class _MusicPostState extends State<MusicPost> {
  bool isLiked = false;
  bool isSaved = false;

  late int likeCount;
  late int commentCount;

  @override
  void initState() {
    super.initState();

    likeCount = widget.likes;
    commentCount = widget.comments;
  }

  // ============================================================
  // LIKE
  // ============================================================

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;

      if (isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  void toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? 'Post saved to your collection.'
              : 'Post removed from saved.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // PLAY
  // ============================================================

  void playSong() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing ${widget.song} by ${widget.artist} 🎵'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // COMMENTS
  // ============================================================

  void openComments() {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final List<String> sampleComments = [
              'This song is so good 😭',
              'I love this one!',
              'Adding this to my playlist 🎧',
            ];

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 430,
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: sampleComments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=47',
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Yzabela',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        sampleComments[index],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                filled: true,
                                fillColor: const Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          GestureDetector(
                            onTap: () {
                              if (commentController.text.trim().isEmpty) {
                                return;
                              }

                              setState(() {
                                commentCount++;
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Comment added!')),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      commentController.dispose();
    });
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      final double value = number / 1000;

      if (value == value.roundToDouble()) {
        return '${value.toInt()}K';
      }

      return '${value.toStringAsFixed(1)}K';
    }

    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // USER
          // ============================================================

          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.profileImage),
              ),

              const SizedBox(width: 9),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    widget.time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(Icons.more_horiz, size: 22),
            ],
          ),

          const SizedBox(height: 11),

          // ============================================================
          // SONG CARD
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  widget.albumImage,
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
                        widget.song,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.artist,
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
                          widget.tag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: EchoColors.primary,
                          ),
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: playSong,
                        child: const Row(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            widget.caption,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),

          const SizedBox(height: 8),

          // ============================================================
          // INTERACTIONS
          // ============================================================
          Row(
            children: [
              GestureDetector(
                onTap: toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isLiked ? EchoColors.primary : Colors.black87,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      formatNumber(likeCount),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 18),

                    const SizedBox(width: 4),

                    Text(
                      formatNumber(commentCount),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: toggleSave,
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isSaved ? EchoColors.primary : Colors.black87,
                ),
              ),
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

class PlaylistPost extends StatefulWidget {
  final String username;
  final String time;
  final String profileImage;
  final String albumImage;
  final String playlistTitle;
  final String subtitle;
  final String songs;
  final int likes;
  final int comments;

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
  State<PlaylistPost> createState() => _PlaylistPostState();
}

class _PlaylistPostState extends State<PlaylistPost> {
  bool isLiked = false;
  bool isSaved = false;

  late int likeCount;
  late int commentCount;

  @override
  void initState() {
    super.initState();

    likeCount = widget.likes;
    commentCount = widget.comments;
  }

  // ============================================================
  // LIKE
  // ============================================================

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;

      if (isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
    });
  }

  // ============================================================
  // SAVE
  // ============================================================

  void toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Playlist saved.' : 'Playlist removed from saved.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ============================================================
  // PLAY
  // ============================================================

  void playPlaylist() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing ${widget.playlistTitle} 🎵'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // COMMENTS
  // ============================================================

  void openComments() {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 430,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const Divider(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    children: const [
                      CommentItem(text: 'This playlist is perfect 😭'),
                      CommentItem(text: 'Adding this to my library!'),
                      CommentItem(text: 'The song choices are so good.'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: const Color(0xFFF2F2F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () {
                          if (commentController.text.trim().isEmpty) {
                            return;
                          }

                          setState(() {
                            commentCount++;
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment added!')),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
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
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      commentController.dispose();
    });
  }

  String formatNumber(int number) {
    if (number >= 1000) {
      final double value = number / 1000;

      if (value == value.roundToDouble()) {
        return '${value.toInt()}K';
      }

      return '${value.toStringAsFixed(1)}K';
    }

    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // USER
          // ============================================================

          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.profileImage),
              ),

              const SizedBox(width: 9),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.username} shared a playlist',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    widget.time,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(Icons.more_horiz, size: 22),
            ],
          ),

          const SizedBox(height: 11),

          // ============================================================
          // PLAYLIST CARD
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  widget.albumImage,
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
                      widget.playlistTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Text(
                      widget.songs,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: playPlaylist,
                      child: const Row(
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
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ============================================================
          // INTERACTIONS
          // ============================================================
          Row(
            children: [
              GestureDetector(
                onTap: toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isLiked ? EchoColors.primary : Colors.black87,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      formatNumber(likeCount),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: openComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 18),

                    const SizedBox(width: 4),

                    Text(
                      formatNumber(commentCount),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: toggleSave,
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isSaved ? EchoColors.primary : Colors.black87,
                ),
              ),
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
// COMMENT ITEM
// ============================================================

class CommentItem extends StatelessWidget {
  final String text;

  const CommentItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yzabela',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 3),

                Text(text, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
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
