import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../services/spotify_service.dart';
import 'home_screen.dart';
import 'create_post_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final SpotifyService spotifyService =
      SpotifyService();

  bool isConnectingSpotify = false;
  bool isSpotifyConnected = false;
  bool isSearching = false;

  List<Map<String, dynamic>> spotifyResults = [];

  @override
  void initState() {
    super.initState();

    isSpotifyConnected =
        spotifyService.accessToken != null;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const HomeScreen(),
      ),
    );
  }

  void goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CreatePostScreen(),
      ),
    );
  }

  void goToMessages() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MessageScreen(),
      ),
    );
  }

  void goToProfile() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ProfileScreen(),
      ),
    );
  }

  // ============================================================
  // CONNECT SPOTIFY
  // ============================================================

  Future<void> connectSpotify() async {
    if (isSpotifyConnected) {
      return;
    }

    setState(() {
      isConnectingSpotify = true;
    });

    try {
      await spotifyService.login();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isConnectingSpotify = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not connect to Spotify: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH SPOTIFY
  // ============================================================

  Future<void> searchSpotify() async {
    final query =
        searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        spotifyResults = [];
      });
      return;
    }

    if (!isSpotifyConnected) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please connect to Spotify first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final results =
          await spotifyService.searchTracks(
        query,
      );

      if (!mounted) return;

      setState(() {
        spotifyResults = results;
        isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Search failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPEN SPOTIFY
  // ============================================================

  Future<void> openSpotify(
    String url,
  ) async {
    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
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
                padding:
                    const EdgeInsets.only(
                  bottom: 15,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // =====================================================
                    // SEARCH BAR
                    // =====================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        18,
                        16,
                        18,
                        10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE9E9E9,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                              child:
                                  TextField(
                                controller:
                                    searchController,
                                onSubmitted:
                                    (_) =>
                                        searchSpotify(),
                                style:
                                    const TextStyle(
                                  fontSize: 14,
                                  color:
                                      Colors.black87,
                                ),
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      'Search songs, artists, playlists, or people...',
                                  hintStyle:
                                      TextStyle(
                                    fontSize: 13,
                                    color:
                                        Color(
                                      0xFF777777,
                                    ),
                                  ),
                                  prefixIcon:
                                      Icon(
                                    Icons.search,
                                    size: 22,
                                    color:
                                        Color(
                                      0xFF666666,
                                    ),
                                  ),
                                  border:
                                      InputBorder
                                          .none,
                                  contentPadding:
                                      EdgeInsets
                                          .symmetric(
                                    vertical:
                                        11,
                                    horizontal:
                                        8,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          IconButton(
                            onPressed:
                                searchSpotify,
                            icon:
                                const Icon(
                              Icons
                                  .search_rounded,
                              size: 26,
                              color:
                                  Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =====================================================
                    // SPOTIFY CONNECTION
                    // =====================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                      ),
                      child: SizedBox(
                        width:
                            double.infinity,
                        height: 42,
                        child:
                            ElevatedButton
                                .icon(
                          onPressed:
                              isConnectingSpotify ||
                                      isSpotifyConnected
                                  ? null
                                  : connectSpotify,
                          icon: Icon(
                            isSpotifyConnected
                                ? Icons
                                    .check_circle
                                : Icons
                                    .music_note,
                            size: 20,
                          ),
                          label: Text(
                            isConnectingSpotify
                                ? 'Connecting to Spotify...'
                                : isSpotifyConnected
                                    ? 'Spotify Connected'
                                    : 'Connect to Spotify',
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                EchoColors
                                    .primary,
                            foregroundColor:
                                Colors.white,
                            disabledBackgroundColor:
                                isSpotifyConnected
                                    ? EchoColors
                                        .secondary
                                    : EchoColors
                                        .primary,
                            disabledForegroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // =====================================================
                    // SPOTIFY SEARCH RESULTS
                    // =====================================================

                    if (isSearching)
                      const Padding(
                        padding:
                            EdgeInsets
                                .symmetric(
                          vertical: 25,
                        ),
                        child:
                            Center(
                          child:
                              CircularProgressIndicator(
                            color: EchoColors
                                .primary,
                          ),
                        ),
                      ),

                    if (!isSearching &&
                        spotifyResults
                            .isNotEmpty)
                      const SectionHeader(
                        title:
                            'Spotify Results',
                      ),

                    if (!isSearching &&
                        spotifyResults
                            .isNotEmpty)
                      const SizedBox(
                        height: 10,
                      ),

                    if (!isSearching)
                      ...spotifyResults
                          .map(
                        (track) =>
                            SpotifyTrackItem(
                          name:
                              track['name']
                                  ?.toString() ??
                                  '',
                          artist:
                              track['artist']
                                  ?.toString() ??
                                  '',
                          album:
                              track['album']
                                  ?.toString() ??
                                  '',
                          image:
                              track['image']
                                  ?.toString(),
                          spotifyUrl:
                              track[
                                      'spotifyUrl']
                                  ?.toString(),
                          onOpen:
                              () {
                            final url =
                                track[
                                    'spotifyUrl'];

                            if (url !=
                                null) {
                              openSpotify(
                                url
                                    .toString(),
                              );
                            }
                          },
                        ),
                      ),

                    // =====================================================
                    // POPULAR ARTISTS
                    // =====================================================

                    if (spotifyResults
                        .isEmpty)
                      const SectionHeader(
                        title:
                            'Popular Artists',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 12,
                      ),

                    if (spotifyResults
                        .isEmpty)
                      SizedBox(
                        height: 115,
                        child:
                            ListView(
                          scrollDirection:
                              Axis.horizontal,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                          ),
                          children:
                              const [
                            ArtistItem(
                              name:
                                  'Taylor Swift',
                              image:
                                  'https://i.pravatar.cc/150?img=47',
                            ),
                            ArtistItem(
                              name:
                                  'The 1975',
                              image:
                                  'https://i.pravatar.cc/150?img=12',
                            ),
                            ArtistItem(
                              name:
                                  'Bruno Mars',
                              image:
                                  'https://i.pravatar.cc/150?img=11',
                            ),
                            ArtistItem(
                              name:
                                  'The Ridleys',
                              image:
                                  'https://i.pravatar.cc/150?img=13',
                            ),
                            ArtistItem(
                              name:
                                  'NIKI',
                              image:
                                  'https://i.pravatar.cc/150?img=14',
                            ),
                          ],
                        ),
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 8,
                      ),

                    // =====================================================
                    // TRENDING PLAYLISTS
                    // =====================================================

                    if (spotifyResults
                        .isEmpty)
                      const SectionHeader(
                        title:
                            'Trending Playlists',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 12,
                      ),

                    if (spotifyResults
                        .isEmpty)
                      SizedBox(
                        height: 205,
                        child:
                            ListView(
                          scrollDirection:
                              Axis.horizontal,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                          ),
                          children:
                              const [
                            PlaylistCard(
                              image:
                                  'https://picsum.photos/seed/wherever/300/300',
                              title:
                                  'home is wherever',
                              subtitle:
                                  'you are',
                              followers:
                                  '250K followers',
                            ),
                            PlaylistCard(
                              image:
                                  'https://picsum.photos/seed/sounds/300/300',
                              title:
                                  'loving you sounds',
                              subtitle:
                                  'like this',
                              followers:
                                  '100K followers',
                            ),
                            PlaylistCard(
                              image:
                                  'https://picsum.photos/seed/thoughts/300/300',
                              title:
                                  'thoughts that keep',
                              subtitle:
                                  'me awake.',
                              followers:
                                  '90K followers',
                            ),
                          ],
                        ),
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 15,
                      ),

                    // =====================================================
                    // PEOPLE YOU MAY KNOW
                    // =====================================================

                    if (spotifyResults
                        .isEmpty)
                      const SectionHeader(
                        title:
                            'People you may know',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 12,
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const PersonItem(
                        name:
                            'Sevi Camero',
                        username:
                            '@cameroRoar',
                        image:
                            'https://i.pravatar.cc/150?img=5',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const PersonItem(
                        name:
                            'Duke Laurence',
                        username:
                            '@dukeLangsakalám',
                        image:
                            'https://i.pravatar.cc/150?img=8',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const PersonItem(
                        name:
                            'Akihiro Leonell',
                        username:
                            '@yourCaptain',
                        image:
                            'https://i.pravatar.cc/150?img=9',
                      ),

                    if (spotifyResults
                        .isEmpty)
                      const SizedBox(
                        height: 10,
                      ),
                  ],
                ),
              ),
            ),

            // =============================================================
            // BOTTOM NAVIGATION
            // HOME → SEARCH → + → MESSAGES → PROFILE
            // =============================================================

            Container(
              height: 66,
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                children: [

                  // HOME
                  SearchBottomNavIcon(
                    icon:
                        Icons.home_rounded,
                    selected: false,
                    onTap: goToHome,
                  ),

                  // SEARCH
                  SearchBottomNavIcon(
                    icon:
                        Icons.search_rounded,
                    selected: true,
                    onTap: () {},
                  ),

                  // CREATE POST
                  GestureDetector(
                    behavior:
                        HitTestBehavior
                            .opaque,
                    onTap:
                        goToCreatePost,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child:
                          DecoratedBox(
                        decoration:
                            const BoxDecoration(
                          color: EchoColors
                              .primary,
                          shape:
                              BoxShape
                                  .circle,
                        ),
                        child:
                            const Center(
                          child: Icon(
                            Icons.add,
                            color:
                                Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // MESSAGES
                  SearchBottomNavIcon(
                    icon: Icons
                        .chat_bubble_outline_rounded,
                    selected: false,
                    onTap:
                        goToMessages,
                  ),

                  // PROFILE
                  SearchBottomNavIcon(
                    icon: Icons
                        .person_outline_rounded,
                    selected: false,
                    onTap:
                        goToProfile,
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
// SPOTIFY TRACK ITEM
// ===========================================================================

class SpotifyTrackItem
    extends StatelessWidget {
  final String name;
  final String artist;
  final String album;
  final String? image;
  final String? spotifyUrl;
  final VoidCallback onOpen;

  const SpotifyTrackItem({
    super.key,
    required this.name,
    required this.artist,
    required this.album,
    required this.image,
    required this.spotifyUrl,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          12,
        ),
        child: Row(
          children: [

            // ALBUM IMAGE
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
              child: image != null &&
                      image!.isNotEmpty
                  ? Image.network(
                      image!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: 58,
                          height: 58,
                          color: EchoColors
                              .secondary,
                          child:
                              const Icon(
                            Icons
                                .music_note_rounded,
                            color:
                                Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 58,
                      height: 58,
                      color: EchoColors
                          .secondary,
                      child:
                          const Icon(
                        Icons
                            .music_note_rounded,
                        color:
                            Colors.white,
                      ),
                    ),
            ),

            const SizedBox(
              width: 12,
            ),

            // SONG INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color: Color(
                        0xFF555555,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    album,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Color(
                        0xFF888888,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .open_in_new_rounded,
              size: 20,
              color:
                  EchoColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// SECTION HEADER
// ===========================================================================

class SectionHeader
    extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Row(
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {},
            child:
                const Text(
              'See all',
              style:
                  TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                color:
                    EchoColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// POPULAR ARTIST
// ===========================================================================

class ArtistItem
    extends StatelessWidget {
  final String name;
  final String image;

  const ArtistItem({
    super.key,
    required this.name,
    required this.image,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 73,
      margin:
          const EdgeInsets.only(
        right: 12,
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.all(
              2,
            ),
            decoration:
                const BoxDecoration(
              shape:
                  BoxShape.circle,
              color:
                  EchoColors.secondary,
            ),
            child:
                CircleAvatar(
              radius: 29,
              backgroundColor:
                  EchoColors.secondary,
              backgroundImage:
                  NetworkImage(
                image,
              ),
              onBackgroundImageError:
                  (_, _) {},
              child:
                  const Icon(
                Icons.person,
                color:
                    Colors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            name,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w500,
              color:
                  Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// TRENDING PLAYLIST CARD
// ===========================================================================

class PlaylistCard
    extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String followers;

  const PlaylistCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.followers,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 125,
      margin:
          const EdgeInsets.only(
        right: 13,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  6,
                ),
                child:
                    Image.network(
                  image,
                  width: 125,
                  height: 125,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 125,
                      height: 125,
                      decoration:
                          BoxDecoration(
                        color:
                            EchoColors
                                .secondary,
                        borderRadius:
                            BorderRadius
                                .circular(
                          6,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .music_note_rounded,
                        color:
                            Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                right: 7,
                bottom: 7,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration:
                      const BoxDecoration(
                    color:
                        Colors.white,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons
                        .play_arrow_rounded,
                    size: 17,
                    color:
                        Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            title,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
              color:
                  Colors.black87,
            ),
          ),

          Text(
            subtitle,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
              color:
                  Colors.black87,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            followers,
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PEOPLE YOU MAY KNOW
// ===========================================================================

class PersonItem
    extends StatelessWidget {
  final String name;
  final String username;
  final String image;

  const PersonItem({
    super.key,
    required this.name,
    required this.username,
    required this.image,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        13,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                EchoColors.secondary,
            backgroundImage:
                NetworkImage(
              image,
            ),
            onBackgroundImageError:
                (_, _) {},
            child:
                const Icon(
              Icons.person,
              color:
                  Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  name,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.black,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  username,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 80,
            height: 32,
            child:
                OutlinedButton(
              onPressed: () {},
              style:
                  OutlinedButton.styleFrom(
                side:
                    const BorderSide(
                  color:
                      EchoColors.primary,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                padding:
                    EdgeInsets.zero,
              ),
              child:
                  const Text(
                'Follow',
                style:
                    TextStyle(
                  fontSize: 13,
                  color:
                      EchoColors.primary,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// BOTTOM NAVIGATION ICON
// ===========================================================================

class SearchBottomNavIcon
    extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const SearchBottomNavIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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