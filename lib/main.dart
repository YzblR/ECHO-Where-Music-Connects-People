import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/home_screen.dart';

const String supabaseUrl =
    'https://ypcadnkdokrvuwlybidv.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_SyvrhwR-tzncxWOdpLsy_w_9nq5PbiL';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const EchoApp(),
    ),
  );
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: echoTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session =
        Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomeScreen();
    }

    return const AuthChoiceScreen();
  }
}