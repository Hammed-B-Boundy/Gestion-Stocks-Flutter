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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(flex: 2),
            Image.asset(
              'images/cart.png',
              height: ResponsiveHelper.getAdaptiveImageHeight(
                context,
                factor: 0.3,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getAdaptiveSpacing(context)),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
