import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => const EchoApp()));
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: echoTheme,
      home: const LoginScreen(),
    );
  }
}
