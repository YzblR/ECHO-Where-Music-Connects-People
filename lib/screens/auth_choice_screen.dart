import 'package:flutter/material.dart';

import '../theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative music notes
            Positioned(
              top: 45,
              left: 32,
              child: Transform.rotate(
                angle: -0.15,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 34,
                  color: EchoColors.primary.withOpacity(0.25),
                ),
              ),
            ),

            Positioned(
              top: 90,
              right: 38,
              child: Transform.rotate(
                angle: 0.15,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 28,
                  color: EchoColors.primary.withOpacity(0.2),
                ),
              ),
            ),

            Positioned(
              top: 155,
              left: 75,
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 38,
                color: EchoColors.primary.withOpacity(0.15),
              ),
            ),

            Positioned(
              bottom: 110,
              right: 35,
              child: Icon(
                Icons.music_note_rounded,
                size: 30,
                color: EchoColors.primary.withOpacity(0.15),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // ECHO Logo
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        color: EchoColors.primary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: EchoColors.primary.withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 58,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'ECHO',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Where Music Connects People',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Discover • Share • Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: EchoColors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 52),

                    // Log In
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EchoColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'LOG IN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Create Account
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SignUpScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EchoColors.primary,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: EchoColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Your music. Your people. Your ECHO.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}