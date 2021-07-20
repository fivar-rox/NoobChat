import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noobchat/allnames.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'friend.dart';
import 'allnames.dart';
import 'blogs.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  //String? userId;
  int _selectedIndex=0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
   List<Widget> _widgetoption = <Widget>[
    new Friend(),
    Allnames(),
    Blog()
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: const Color(0x81B7C2E2),
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          actions: <Widget>[
            ElevatedButton(
              child: Text('Logout Now'),
              onPressed: () async {
                await googleSignIn.signOut();
                SharedPreferences sharedPrefs =
                await SharedPreferences.getInstance();
                sharedPrefs.setString('id', '');
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        body:Container(
          child: _widgetoption.elementAt(_selectedIndex),
        ),

        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
              ),
              BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'People',
              ),
              BottomNavigationBarItem(
              icon: Icon(Icons.my_library_books_rounded),
              label: 'Blogs',
          ),
        ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          backgroundColor: const Color(0x286781CE),
          onTap: _onItemTapped,
      )
    );
  }


}

