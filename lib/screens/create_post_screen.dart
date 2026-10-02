import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController captionController =
      TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  String selectedPostType = 'Music';

  String? selectedSong;
  String? selectedArtist;
  String? selectedPlaylist;
  String? selectedSongCount;

  // Stores the selected image as Base64.
  // This allows the image to be passed to the Home Feed.
  String? selectedImageBase64;

  final List<Map<String, String>> musicOptions = [
    {'title': 'Snooze', 'artist': 'SZA'},
    {'title': 'Glue Song', 'artist': 'beabadoobee'},
    {'title': 'Super Shy', 'artist': 'NewJeans'},
    {'title': 'I Like Me Better', 'artist': 'Lauv'},
    {'title': 'Every Summertime', 'artist': 'NIKI'},
    {'title': 'Totoong Tayo', 'artist': 'Jin DC'},
    {'title': 'Malay Ko', 'artist': 'Daniel Padilla'},
    {'title': 'Ikaw', 'artist': 'Yeng Constantino'},
  ];

  final List<Map<String, String>> playlistOptions = [
    {'title': 'Late Night Thoughts', 'songs': '18 songs'},
    {'title': 'Main Character', 'songs': '15 songs'},
    {'title': 'Soft Hours', 'songs': '12 songs'},
    {
      'title': '1,2,3 kanya kanya na toh',
      'songs': '30 songs',
    },
  ];

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();

      setState(() {
        selectedImageBase64 = base64Encode(bytes);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =====================================================
  // REMOVE IMAGE
  // =====================================================

  void removeImage() {
    setState(() {
      selectedImageBase64 = null;
    });
  }

  // =====================================================
  // CREATE POST
  // =====================================================

  void createPost() {
    final caption = captionController.text.trim();

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a caption.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // -----------------------------------------------------
    // MUSIC POST
    // -----------------------------------------------------

    if (selectedPostType == 'Music') {
      if (selectedSong == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a song.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.pop(
        context,
        <String, String>{
          'type': 'Music',
          'caption': caption,
          'songTitle': selectedSong!,
          'artist': selectedArtist ?? '',
          'imageBase64': selectedImageBase64 ?? '',
        },
      );
    }

    // -----------------------------------------------------
    // PLAYLIST POST
    // -----------------------------------------------------

    else {
      if (selectedPlaylist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a playlist.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.pop(
        context,
        <String, String>{
          'type': 'Playlist',
          'caption': caption,
          'playlistTitle': selectedPlaylist!,
          'songCount': selectedSongCount ?? '',
          'imageBase64': selectedImageBase64 ?? '',
        },
      );
    }
  }

  // =====================================================
  // SELECT SONG
  // =====================================================

  void showMusicSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Choose a Song',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    itemCount: musicOptions.length,
                    itemBuilder: (context, index) {
                      final music =
                          musicOptions[index];

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              EchoColors.secondary,
                          child: const Icon(
                            Icons.music_note,
                            color:
                                EchoColors.primary,
                          ),
                        ),
                        title: Text(
                          music['title']!,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            Text(music['artist']!),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            selectedSong =
                                music['title'];
                            selectedArtist =
                                music['artist'];

                            selectedPlaylist =
                                null;
                            selectedSongCount =
                                null;
                          });

                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // SELECT PLAYLIST
  // =====================================================

  void showPlaylistSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Choose a Playlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    itemCount:
                        playlistOptions.length,
                    itemBuilder: (context, index) {
                      final playlist =
                          playlistOptions[index];

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              EchoColors.secondary,
                          child: const Icon(
                            Icons.queue_music,
                            color:
                                EchoColors.primary,
                          ),
                        ),
                        title: Text(
                          playlist['title']!,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            Text(playlist['songs']!),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            selectedPlaylist =
                                playlist['title'];
                            selectedSongCount =
                                playlist['songs'];

                            selectedSong = null;
                            selectedArtist = null;
                          });

                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // BUILD SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool isMusic =
        selectedPostType == 'Music';

    return Scaffold(
      backgroundColor: EchoColors.background,

      // =================================================
      // APP BAR
      // =================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed: createPost,
            child: const Text(
              'Post',
              style: TextStyle(
                color: EchoColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),

      // =================================================
      // BODY
      // =================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =============================================
            // USER INFORMATION
            // =============================================

            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      EchoColors.secondary,
                  child: Icon(
                    Icons.person,
                    color: EchoColors.primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yzabela',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@yzabela',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =============================================
            // CAPTION
            // =============================================

            const Text(
              'What are you listening to?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: captionController,
              maxLines: 5,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Share your thoughts about this song...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // =============================================
            // ADD PHOTO
            // =============================================

            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: EchoColors.secondary,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: EchoColors.secondary,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: EchoColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        selectedImageBase64 == null
                            ? 'Add Photo'
                            : 'Change Photo',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =============================================
            // SELECTED IMAGE
            // =============================================

            if (selectedImageBase64 != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16),
                    child: Image.memory(
                      base64Decode(
                        selectedImageBase64!,
                      ),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: removeImage,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration:
                            const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // =============================================
            // MUSIC / PLAYLIST SELECTOR
            // =============================================

            Row(
              children: [
                // MUSIC
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPostType = 'Music';

                        selectedPlaylist = null;
                        selectedSongCount = null;
                      });
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      decoration:
                          BoxDecoration(
                        color: isMusic
                            ? EchoColors.primary
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: isMusic
                              ? EchoColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Music',
                          style: TextStyle(
                            color: isMusic
                                ? Colors.white
                                : Colors.black,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // PLAYLIST
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPostType =
                            'Playlist';

                        selectedSong = null;
                        selectedArtist = null;
                      });
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      decoration:
                          BoxDecoration(
                        color: !isMusic
                            ? EchoColors.primary
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: !isMusic
                              ? EchoColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Playlist',
                          style: TextStyle(
                            color: !isMusic
                                ? Colors.white
                                : Colors.black,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =============================================
            // ADD MUSIC / PLAYLIST
            // =============================================

            GestureDetector(
              onTap: isMusic
                  ? showMusicSelection
                  : showPlaylistSelection,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: EchoColors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: EchoColors.secondary,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isMusic
                            ? Icons.music_note
                            : Icons.queue_music,
                        color:
                            EchoColors.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: isMusic
                          ? Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  selectedSong ??
                                      'Add a song',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                    height: 4),
                                Text(
                                  selectedArtist ??
                                      'Choose music to share',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  selectedPlaylist ??
                                      'Add a playlist',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                    height: 4),
                                Text(
                                  selectedSongCount ??
                                      'Choose a playlist to share',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // =============================================
            // PREVIEW
            // =============================================

            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Preview user
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            EchoColors.secondary,
                        child: Icon(
                          Icons.person,
                          color:
                              EchoColors.primary,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Yzabela',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Preview caption
                  Text(
                    captionController.text.isEmpty
                        ? 'Your caption will appear here...'
                        : captionController.text,
                    style: TextStyle(
                      color: captionController
                              .text
                              .isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),

                  // Preview image
                  if (selectedImageBase64 !=
                      null) ...[
                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(
                          selectedImageBase64!,
                        ),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Preview music
                  if (isMusic &&
                      selectedSong != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          color:
                              EchoColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$selectedSong • $selectedArtist',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Preview playlist
                  if (!isMusic &&
                      selectedPlaylist != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.queue_music,
                          color:
                              EchoColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$selectedPlaylist • $selectedSongCount',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}