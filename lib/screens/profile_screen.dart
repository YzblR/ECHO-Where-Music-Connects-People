import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'create_post_screen.dart';
import 'message_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  // ============================================================
  // PROFILE PICTURE
  // ============================================================

  final ImagePicker imagePicker = ImagePicker();
  Uint8List? profileImageBytes;

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        profileImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select profile picture: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

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

  void goToMessages() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MessageScreen()),
    );
  }

  void showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  void showEditProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _EditProfileOption(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Name',
                  onTap: () {
                    Navigator.pop(context);
                    showComingSoon('Edit Name');
                  },
                ),

                _EditProfileOption(
                  icon: Icons.alternate_email_rounded,
                  title: 'Edit Username',
                  onTap: () {
                    Navigator.pop(context);
                    showComingSoon('Edit Username');
                  },
                ),

                _EditProfileOption(
                  icon: Icons.description_outlined,
                  title: 'Edit Bio',
                  onTap: () {
                    Navigator.pop(context);
                    showComingSoon('Edit Bio');
                  },
                ),

                _EditProfileOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Change Profile Picture',
                  onTap: () async {
                    Navigator.pop(context);
                    await pickProfileImage();
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          IconButton(
                            onPressed: () {
                              showComingSoon('Settings');
                            },
                            icon: const Icon(
                              Icons.settings_outlined,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // PROFILE INFORMATION
                  // ==================================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Column(
                        children: [
                          // Profile picture
                          GestureDetector(
                            onTap: pickProfileImage,
                            child: Container(
                              width: 105,
                              height: 105,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: EchoColors.primary,
                                  width: 3,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: CircleAvatar(
                                backgroundColor: const Color(0xFFF4AFC8),
                                backgroundImage: profileImageBytes != null
                                    ? MemoryImage(profileImageBytes!)
                                    : null,
                                child: profileImageBytes == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 55,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Name
                          const Text(
                            'Yzabela',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Username
                          Text(
                            '@yzabela',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Bio
                          Text(
                            'Music lover 🎧\n'
                            'discovering songs and sharing good vibes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // PROFILE STATS
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _ProfileStat(
                                number: '12',
                                label: 'Posts',
                              ),

                              const _StatDivider(),

                              const _ProfileStat(
                                number: '120',
                                label: 'Followers',
                              ),

                              const _StatDivider(),

                              const _ProfileStat(
                                number: '85',
                                label: 'Following',
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // EDIT PROFILE BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: showEditProfile,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: EchoColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: EchoColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // PROFILE TABS
                  // ==================================================
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          _ProfileTab(
                            icon: Icons.grid_view_rounded,
                            selected: selectedTab == 0,
                            onTap: () {
                              setState(() {
                                selectedTab = 0;
                              });
                            },
                          ),

                          _ProfileTab(
                            icon: Icons.queue_music_rounded,
                            selected: selectedTab == 1,
                            onTap: () {
                              setState(() {
                                selectedTab = 1;
                              });
                            },
                          ),

                          _ProfileTab(
                            icon: Icons.bookmark_border_rounded,
                            selected: selectedTab == 2,
                            onTap: () {
                              setState(() {
                                selectedTab = 2;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==================================================
                  // POSTS
                  // ==================================================
                  if (selectedTab == 0)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(const [
                          MusicPostCard(
                            songTitle: 'Snooze',
                            artist: 'SZA',
                            caption:
                                'This song has been on repeat lately 🎧',
                            likes: '42',
                            comments: '8',
                          ),

                          SizedBox(height: 14),

                          MusicPostCard(
                            songTitle: 'Glue Song',
                            artist: 'beabadoobee',
                            caption: 'Soft songs for a slow afternoon.',
                            likes: '36',
                            comments: '5',
                          ),

                          SizedBox(height: 14),

                          MusicPostCard(
                            songTitle: 'I Like Me Better',
                            artist: 'Lauv',
                            caption: 'A classic that never gets old.',
                            likes: '51',
                            comments: '11',
                          ),

                          SizedBox(height: 14),

                          MusicPostCard(
                            songTitle: 'Super Shy',
                            artist: 'NewJeans',
                            caption:
                                'Adding this one to my playlist again 💗',
                            likes: '63',
                            comments: '14',
                          ),
                        ]),
                      ),
                    ),

                  // ==================================================
                  // PLAYLISTS
                  // ==================================================
                  if (selectedTab == 1)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(const [
                          PlaylistCard(
                            title: 'Late Night Thoughts',
                            subtitle: 'Songs for 12 AM conversations',
                            songs: '18 songs',
                          ),

                          SizedBox(height: 14),

                          PlaylistCard(
                            title: 'Main Character',
                            subtitle:
                                'Songs that make everything feel cinematic',
                            songs: '24 songs',
                          ),

                          SizedBox(height: 14),

                          PlaylistCard(
                            title: 'Soft Hours',
                            subtitle: 'Calm songs for slow days',
                            songs: '16 songs',
                          ),
                        ]),
                      ),
                    ),

                  // ==================================================
                  // SAVED
                  // ==================================================
                  if (selectedTab == 2)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(const [
                          SavedPostCard(
                            songTitle: 'Until I Found You',
                            artist: 'Stephen Sanchez',
                            savedBy: 'Sofia Martinez',
                          ),

                          SizedBox(height: 14),

                          SavedPostCard(
                            songTitle: 'Those Eyes',
                            artist: 'New West',
                            savedBy: 'Liam Anderson',
                          ),

                          SizedBox(height: 14),

                          SavedPostCard(
                            songTitle: 'Every Summertime',
                            artist: 'NIKI',
                            savedBy: 'Mia Santos',
                          ),
                        ]),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),

            // ========================================================
            // BOTTOM NAVIGATION
            // ========================================================
            Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
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

                  // PLUS - PERFECT CIRCLE
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
                    selected: false,
                    onTap: goToMessages,
                  ),

                  // PROFILE
                  BottomNavIcon(
                    icon: Icons.person_rounded,
                    selected: true,
                    onTap: () {},
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

// ================================================================
// PROFILE STAT
// ================================================================

class _ProfileStat extends StatelessWidget {
  final String number;
  final String label;

  const _ProfileStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// STAT DIVIDER
// ================================================================

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: Colors.grey.shade300);
  }
}

// ================================================================
// PROFILE TAB
// ================================================================

class _ProfileTab extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTab({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? EchoColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 23,
            color: selected ? EchoColors.primary : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// MUSIC POST CARD
// ================================================================

class MusicPostCard extends StatelessWidget {
  final String songTitle;
  final String artist;
  final String caption;
  final String likes;
  final String comments;

  const MusicPostCard({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.caption,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User information
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF4AFC8),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 10),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yzabela',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),

                  Text(
                    '@yzabela',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(Icons.more_horiz_rounded, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 14),

          // Caption
          Text(caption, style: const TextStyle(fontSize: 14, height: 1.4)),

          const SizedBox(height: 14),

          // Music
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: EchoColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        songTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        artist,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: EchoColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, size: 21),

              const SizedBox(width: 5),

              Text(likes, style: const TextStyle(fontSize: 12)),

              const SizedBox(width: 18),

              const Icon(Icons.chat_bubble_outline_rounded, size: 20),

              const SizedBox(width: 5),

              Text(comments, style: const TextStyle(fontSize: 12)),

              const Spacer(),

              const Icon(Icons.bookmark_border_rounded, size: 21),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PLAYLIST CARD
// ================================================================

class PlaylistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String songs;

  const PlaylistCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: EchoColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 7),

                Text(
                  songs,
                  style: const TextStyle(
                    fontSize: 11,
                    color: EchoColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

// ================================================================
// SAVED POST CARD
// ================================================================

class SavedPostCard extends StatelessWidget {
  final String songTitle;
  final String artist;
  final String savedBy;

  const SavedPostCard({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.savedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: EchoColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  artist,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 5),

                Text(
                  'Saved from $savedBy',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const Icon(Icons.bookmark_rounded, color: EchoColors.primary),
        ],
      ),
    );
  }
}

// ================================================================
// EDIT PROFILE OPTION
// ================================================================

class _EditProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _EditProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: EchoColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}

// ================================================================
// BOTTOM NAVIGATION ICON
// ================================================================

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