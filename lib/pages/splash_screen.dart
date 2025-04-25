import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home'); // Redirection vers Home
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/background3.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/cart.png',
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                SizedBox(height: ResponsiveHelper.getAdaptiveSpacing(context)),
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: ResponsiveHelper.getAdaptiveFontSize(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
