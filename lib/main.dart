import 'package:flutter/material.dart';
import 'package:my_store/pages/splash_screen.dart';
import 'package:my_store/pages/WelcomePage.dart';
import 'package:my_store/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Initialisation propre de la DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Stocks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(color: Colors.red[700]),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[700]!),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[700]!, width: 2),
          ),
        ),
      ),
      // darkTheme: ThemeData.dark(), // Thème sombre
      // themeMode: themeProvider.themeMode, // Utilise le thème actuel
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => WelcomePage(), // Ta page principale
      },
    );
  }
}
