import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final ImagePicker imagePicker = ImagePicker();

  Uint8List? profileImageBytes;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

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

  // ============================================================
  // PROFILE PICTURE
  // ============================================================

  Future<void> pickProfileImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      profileImageBytes = bytes;
    });
  }

  void showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
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

                const SizedBox(height: 22),

                const Text(
                  'Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: EchoColors.secondary,
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text('Change Profile Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    pickProfileImage();
                  },
                ),

                if (profileImageBytes != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    title: const Text('Remove Profile Picture'),
                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        profileImageBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
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

  // ============================================================
  // LOG OUT
  // ============================================================

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5F8),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 12),

                                            ListTile(
                                              leading: const Icon(
                                                Icons.settings_outlined,
                                              ),
                                              title: const Text('Settings'),
                                              onTap: () {
                                                Navigator.pop(context);

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Settings coming soon.',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                            ListTile(
                                              leading: const Icon(
                                                Icons.logout_rounded,
                                                color: Colors.red,
                                              ),
                                              title: const Text(
                                                'Log Out',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);

                                                logout();
                                              },
                                            ),

                                            const SizedBox(height: 12),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // ==================================================
                          // PROFILE PICTURE
                          // ==================================================
                          GestureDetector(
                            onTap: showProfilePictureOptions,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 55,
                                  backgroundColor: EchoColors.secondary,
                                  backgroundImage: profileImageBytes != null
                                      ? MemoryImage(profileImageBytes!)
                                      : null,
                                  child: profileImageBytes == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),

                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: EchoColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // USERNAME
                          // ==================================================
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ==================================================
                          // EMAIL
                          // ==================================================
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // STATS
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ProfileStat(number: '0', label: 'Posts'),
                              _ProfileStat(number: '0', label: 'Followers'),
                              _ProfileStat(number: '0', label: 'Following'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ======================================================
                    // EDIT PROFILE
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit Profile coming soon.'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: EchoColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: EchoColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // MUSIC PROFILE
                    // ======================================================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Music Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _ProfileOption(
                            icon: Icons.music_note_rounded,
                            title: 'Favorite Artists',
                            subtitle: 'Add your favorite artists',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Favorite artists coming soon.',
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          _ProfileOption(
                            icon: Icons.library_music_rounded,
                            title: 'Favorite Genres',
                            subtitle: 'Choose the music you love',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Favorite genres coming soon.'),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          _ProfileOption(
                            icon: Icons.playlist_play_rounded,
                            title: 'My Playlists',
                            subtitle: 'View your shared playlists',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Playlists coming soon.'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ======================================================
                    // MY POSTS
                    // ======================================================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Posts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            size: 45,
                            color: EchoColors.secondary,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Share your first song or playlist!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),

            // ============================================================
            // BOTTOM NAVIGATION
            //
            // HOME → SEARCH → + → MESSAGES → PROFILE
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
                  _BottomNavIcon(
                    icon: Icons.home_rounded,
                    selected: false,
                    onTap: goToHome,
                  ),

                  // SEARCH
                  _BottomNavIcon(
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
                  _BottomNavIcon(
                    icon: Icons.chat_bubble_outline_rounded,
                    selected: false,
                    onTap: goToMessages,
                  ),

                  // PROFILE
                  _BottomNavIcon(
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

// ===========================================================================
// PROFILE STAT
// ===========================================================================

class _ProfileStat extends StatelessWidget {
  final String number;
  final String label;

  const _ProfileStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ===========================================================================
// PROFILE OPTION
// ===========================================================================

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF5F8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: EchoColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// BOTTOM NAVIGATION ICON
// ===========================================================================

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavIcon({
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
