import 'package:flutter/material.dart';

import 'translation_screen.dart';
import 'translation_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> _pagesTitle = ["Translate", "My Translations", "Profile"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return TranslationScreen();
      case 1:
        return TranslationListScreen();
      case 2:
        return ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = BottomNavigationBar(
      selectedItemColor: Theme.of(context).accentColor,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.translate),
          title: Text('My Translations'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text('Me'),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(_pagesTitle[_selectedIndex]),
        ),
        body: getPage(_selectedIndex),
        bottomNavigationBar: bottom);
  }
}
