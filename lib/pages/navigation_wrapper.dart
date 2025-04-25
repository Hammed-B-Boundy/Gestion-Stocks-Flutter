import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'FournisseursListPage.dart';
import 'StocksListPage.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StocksListPage(),
    FournisseursListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stocks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Fournisseurs',
          ),
        ],
      ),
    );
  }
}
