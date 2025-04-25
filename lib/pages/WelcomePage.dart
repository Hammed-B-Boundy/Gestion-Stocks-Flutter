import 'package:flutter/material.dart';
import 'package:my_store/pages/Delayed_animation.dart';
import 'package:my_store/pages/HomePage.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        child: Container(
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
              padding: ResponsiveHelper.getAdaptivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: ResponsiveHelper.isMobile(context) ? 150.0 : 200.0,
                  ),
                  DelayedAnimation(
                    delay: 1000,
                    child: Image.asset(
                      'images/cart.png',
                      height:
                          ResponsiveHelper.isMobile(context) ? 150.0 : 200.0,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getAdaptiveSpacing(context),
                  ),
                  DelayedAnimation(
                    delay: 2000,
                    child: Text(
                      'Hey! Bienvenue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          ResponsiveHelper.isMobile(context) ? 24.0 : 30.0,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getAdaptiveSpacing(context),
                  ),
                  DelayedAnimation(
                    delay: 3000,
                    child: Text(
                      'Vous souhaitez mieux organiser vos stocks et garder des traces de vos entrées et sorties ? \nVous êtes au bon endroit !',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          ResponsiveHelper.isMobile(context) ? 16.0 : 20.0,
                        ),
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getAdaptiveSpacing(context) * 2,
                  ),
                  DelayedAnimation(
                    delay: 4000,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveHelper.isMobile(context) ? 40 : 50,
                          vertical:
                              ResponsiveHelper.isMobile(context) ? 15 : 20,
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
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            ResponsiveHelper.isMobile(context) ? 18 : 20,
                          ),
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
        ),
      ),
    );
  }
}
