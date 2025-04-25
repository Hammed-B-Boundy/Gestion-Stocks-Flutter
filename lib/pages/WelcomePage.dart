import 'package:flutter/material.dart';
import 'package:my_store/pages/Delayed_animation.dart';
import 'package:my_store/pages/HomePage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Points de rupture pour différentes tailles d'écran
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;

          return Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background2.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: isMobile ? 150.0 : 200.0),
                    DelayedAnimation(
                      delay: 1000,
                      child: Image.asset(
                        'images/cart.png',
                        height: isMobile ? 150.0 : 200.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    DelayedAnimation(
                      delay: 2000,
                      child: Text(
                        'Hey! Bienvenue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24.0 : 30.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    DelayedAnimation(
                      delay: 3000,
                      child: Text(
                        'Vous souhaitez mieux organiser vos stocks et garder des traces de vos entrées et sorties ? \nVous êtes au bon endroit !',
                        style: TextStyle(
                          fontSize: isMobile ? 16.0 : 20.0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isMobile ? 30.0 : 40.0),
                    DelayedAnimation(
                      delay: 4000,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 40 : 50,
                            vertical: isMobile ? 15 : 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        child: Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
