import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offNamed('/signup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.offNamed('/signup'),
      child: Scaffold(
        backgroundColor: Color(0xFF33490B),
        body: Stack(
          children: [
            SizedBox.expand(
              child: Container(
                width: double.infinity,
                height: 852,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFF33490B)),
                child: Stack(
                  children: [
                    Positioned(
                      left: 46,
                      top: 276,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: ShapeDecoration(
                          color: Colors.white.withAlpha((0.05 * 255).toInt()),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 71,
                      top: 301,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: ShapeDecoration(
                          color: Colors.white.withAlpha((0.05 * 255).toInt()),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 96,
                      top: 326,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: ShapeDecoration(
                          color: Colors.white.withAlpha((0.05 * 255).toInt()),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 121,
                      top: 351,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: ShapeDecoration(
                          color: Colors.white.withAlpha((0.05 * 255).toInt()),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 115,
                      top: 407,
                      child: Text(
                        'TACAB AI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE1E1E0),
                          fontSize: 35,
                          fontFamily: 'JejuGothic',
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Align(
                alignment:
                    Alignment.bottomCenter, // Center the text horizontally
                child: Text(
                  'Version 1.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w100,
                    letterSpacing: -0.17,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
