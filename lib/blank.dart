import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BlankPage extends StatefulWidget {

  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
        body: Text("this is Blank page.")
    );
  }
}