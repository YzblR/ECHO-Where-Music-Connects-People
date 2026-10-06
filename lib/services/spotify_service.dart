import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyService {
  // ============================================================
  // SPOTIFY APP INFORMATION
  // ============================================================

  static const String clientId =
      '3c84d0f66fee4f1c9618833f855b6120';

  static const String redirectUri =
      'http://127.0.0.1:8080';

  static const String verifierKey =
      'spotify_code_verifier';

  // ============================================================
  // SINGLETON
  // ============================================================

  static final SpotifyService instance =
      SpotifyService._internal();

  factory SpotifyService() => instance;

  SpotifyService._internal();

  // ============================================================
  // VARIABLES
  // ============================================================

  String? accessToken;
  String? _codeVerifier;

  // ============================================================
  // SPOTIFY LOGIN
  // ============================================================

  Future<void> login() async {
    // Generate PKCE verifier.
    _codeVerifier = _generateCodeVerifier();

    final prefs =
        await SharedPreferences.getInstance();

    // Save verifier so it can be recovered
    // after Spotify redirects back.
    await prefs.setString(
      verifierKey,
      _codeVerifier!,
    );

    // Generate PKCE challenge.
    final codeChallenge =
        _generateCodeChallenge(
      _codeVerifier!,
    );

    // Spotify authorization URL.
    final authUrl = Uri.https(
      'accounts.spotify.com',
      '/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
      },
    );

    // Open Spotify login.
    await launchUrl(
      authUrl,
      webOnlyWindowName: '_self',
    );
  }

  // ============================================================
  // HANDLE SPOTIFY CALLBACK
  // ============================================================

  Future<bool> handleCallback(Uri uri) async {
    // Get authorization code from the URL.
    final code =
        uri.queryParameters['code'];

    // Spotify did not return a code.
    if (code == null || code.isEmpty) {
      return false;
    }

    final prefs =
        await SharedPreferences.getInstance();

    // Recover the PKCE verifier.
    _codeVerifier ??=
        prefs.getString(verifierKey);

    if (_codeVerifier == null) {
      return false;
    }

    // Exchange the authorization code
    // for an access token.
    final response = await http.post(
      Uri.parse(
        'https://accounts.spotify.com/api/token',
      ),
      headers: {
        'Content-Type':
            'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': _codeVerifier!,
      },
    );

    if (response.statusCode != 200) {
      print(
        'Spotify token error: ${response.body}',
      );

      return false;
    }

    final data =
        jsonDecode(response.body);

    accessToken =
        data['access_token'];

    // The verifier is no longer needed.
    await prefs.remove(verifierKey);

    _codeVerifier = null;

    return accessToken != null;
  }

  // ============================================================
  // GENERATE PKCE VERIFIER
  // ============================================================

  String _generateCodeVerifier() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789-._~';

    final random =
        Random.secure();

    return List.generate(
      64,
      (_) => characters[
          random.nextInt(
            characters.length,
          )
        ],
    ).join();
  }

  // ============================================================
  // GENERATE PKCE CHALLENGE
  // ============================================================

  String _generateCodeChallenge(
    String verifier,
  ) {
    final bytes =
        utf8.encode(verifier);

    final digest =
        sha256.convert(bytes);

    return base64Url
        .encode(digest.bytes)
        .replaceAll('=', '');
  }

  // ============================================================
  // SEARCH SPOTIFY TRACKS
  // ============================================================

  Future<List<Map<String, dynamic>>> searchTracks(
    String query,
  ) async {
    if (accessToken == null) {
      throw Exception(
        'Please connect to Spotify first.',
      );
    }

    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.https(
      'api.spotify.com',
      '/v1/search',
      {
        'q': query.trim(),
        'type': 'track',
        'limit': '10',
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Spotify search failed: '
        '${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body);

    final tracks =
        data['tracks']['items'] as List;

    return tracks
        .map<Map<String, dynamic>>(
      (track) {
        final artists =
            track['artists'] as List;

        final album =
            track['album'];

        final images =
            album['images'] as List;

        return {
          'name': track['name'],

          'artist': artists
              .map(
                (artist) =>
                    artist['name'],
              )
              .join(', '),

          'album': album['name'],

          'image': images.isNotEmpty
              ? images[0]['url']
              : null,

          'spotifyUrl':
              track['external_urls']
                  ['spotify'],
        };
      },
    ).toList();
  }
}