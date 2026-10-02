import 'package:flutter/material.dart';

import '../spacing.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------------------------

  void login() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // ECHO Logo
              const AppLogo(),

              const SizedBox(height: 34),

              // ----------------------------------------------------------------
              // WELCOME SECTION
              // ----------------------------------------------------------------

              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome to Echo!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFE95D91),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      'Where Music Connects People.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF757575),
                            fontSize: 14,
                          ),
                    ),

                    const SizedBox(height: 12),

                    const _MusicIllustration(),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ----------------------------------------------------------------
              // LOGIN TITLE
              // ----------------------------------------------------------------

              Text(
                'Login',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ----------------------------------------------------------------
              // EMAIL
              // ----------------------------------------------------------------

              CustomTextField(
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: AppSpacing.sm),

              // ----------------------------------------------------------------
              // PASSWORD
              // ----------------------------------------------------------------

              CustomTextField(
                hintText: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passwordController,
              ),

              // ----------------------------------------------------------------
              // FORGOT PASSWORD
              // ----------------------------------------------------------------

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------------
              // LOGIN BUTTON
              // ----------------------------------------------------------------

              Center(
                child: PrimaryButton(
                  label: 'Login',
                  onPressed: login,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// MUSIC ILLUSTRATION
// ===========================================================================

class _MusicIllustration extends StatelessWidget {
  const _MusicIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(320, 85),
            painter: _MusicWavePainter(),
          ),

          const Positioned(
            left: 10,
            bottom: 20,
            child: Icon(
              Icons.music_note,
              size: 36,
              color: Color(0xFFF4AFC8),
            ),
          ),

          const Positioned(
            left: 70,
            top: 8,
            child: Icon(
              Icons.music_note,
              size: 38,
              color: Color(0xFFE96B9A),
            ),
          ),

          const Positioned(
            right: 55,
            top: 8,
            child: Icon(
              Icons.music_note,
              size: 38,
              color: Color(0xFFE96B9A),
            ),
          ),

          const Positioned(
            right: 10,
            bottom: 20,
            child: Icon(
              Icons.music_note,
              size: 30,
              color: Color(0xFFF4AFC8),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MUSIC WAVE PAINTER
// ===========================================================================

class _MusicWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF4AFC8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    path.moveTo(0, size.height * 0.65);

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.15,
      size.width * 0.45,
      size.height * 0.85,
      size.width * 0.65,
      size.height * 0.35,
    );

    path.cubicTo(
      size.width * 0.80,
      size.height * 0.05,
      size.width * 0.90,
      size.height * 0.80,
      size.width,
      size.height * 0.35,
    );

    canvas.drawPath(path, paint);

    final secondPath = Path();

    secondPath.moveTo(0, size.height * 0.85);

    secondPath.cubicTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.45,
      size.height,
      size.width * 0.65,
      size.height * 0.55,
    );

    secondPath.cubicTo(
      size.width * 0.80,
      size.height * 0.20,
      size.width * 0.90,
      size.height * 0.95,
      size.width,
      size.height * 0.55,
    );

    canvas.drawPath(secondPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}