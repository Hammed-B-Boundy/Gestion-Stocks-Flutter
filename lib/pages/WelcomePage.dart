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
      body: Container(
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  ResponsiveHelper.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 0.6
                      : ResponsiveHelper.isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getAdaptivePadding(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  DelayedAnimation(
                    delay: 1000,
                    child: Image.asset(
                      'images/cart.png',
                      height: ResponsiveHelper.getAdaptiveImageHeight(
                        context,
                        factor: 0.25,
                      ),
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
                          28.0,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getAdaptiveSpacing(
                          context,
                        ),
                      ),
                      child: Text(
                        'Vous souhaitez mieux organiser vos stocks et garder des traces de vos entrées et sorties ? \nVous êtes au bon endroit !',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getAdaptiveFontSize(
                            context,
                            18.0,
                          ),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                              ResponsiveHelper.getAdaptiveSpacing(context) * 5,
                          vertical:
                              ResponsiveHelper.getAdaptiveSpacing(context) *
                              1.5,
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
                            20.0,
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
