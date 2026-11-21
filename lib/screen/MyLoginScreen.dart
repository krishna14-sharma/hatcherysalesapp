import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/login.dart';
import '../widgets/app_version.dart';

class MyLoginScreen extends StatefulWidget {
  @override
  _MyLoginScreenState createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Brand header in the Phoenix logo blues
          Container(
            height: h * 0.42,
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // Chick image + logo on a white card. The photo has a
                      // white background, so it blends into the card.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/chimg.jpg',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Image.asset('assets/images/logo.JPG',
                                height: 26, fit: BoxFit.contain),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Field sales & supply management',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 26),
                      LoginUI(),
                      const SizedBox(height: 20),
                      const AppVersionText(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
