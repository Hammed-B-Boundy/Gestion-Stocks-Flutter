import 'package:flutter/material.dart';
import 'package:my_store/pages/splash_screen.dart';
import 'package:my_store/pages/WelcomePage.dart';
import 'package:my_store/services/database_helper.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteDatabaseFile() async {
  String dbPath = join(await getDatabasesPath(), 'stock_database.db');
  await deleteDatabase(dbPath);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await deleteDatabaseFile(); // Supprimer la base de données
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
