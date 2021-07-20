import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noobchat/home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool pageInitialised = false;
  List<String> friends = [];

  final googleSignIn = GoogleSignIn();

  final firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    checkIfUserLoggedIn();
    super.initState();
  }

  checkIfUserLoggedIn() async {
//    await googleSignIn.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//    sharedPreferences.setString("id", '');
    bool userLoggedIn = (sharedPreferences.getString('id') ?? '').isNotEmpty;

    if (userLoggedIn) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Home()));
    } else {
      setState(() {
        pageInitialised = true;
      });
    }
  }

  handleSignIn() async {
    final res = await googleSignIn.signIn();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final auth = await res!.authentication;

    final credentials = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);

    final firebaseUser =
        (await firebaseAuth.signInWithCredential(credentials)).user;

    if (firebaseUser != null) {
      final result = (await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get())
          .docs;

      if (result.length == 0) {
        ///new user
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          "id": firebaseUser.uid,
          "name": firebaseUser.displayName,
          "profile_pic": firebaseUser.photoURL,
          "created_at": DateTime.now().millisecondsSinceEpoch,
          'friends' : friends,
        });

        sharedPreferences.setString("id", firebaseUser.uid);
        sharedPreferences.setString("name", firebaseUser.displayName!);
        sharedPreferences.setString("profile_pic", firebaseUser.photoURL!);
        sharedPreferences.setStringList('friends', friends);

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Home()));
      } else {
        ///Old user
        List<String> friendsNew = new List<String>.from(result[0]["friends"]);
        sharedPreferences.setString("id", result[0]["id"]);
        sharedPreferences.setString("name", result[0]["name"]);
        sharedPreferences.setString("profile_pic", result[0]["profile_pic"]);
        sharedPreferences.setStringList("friends", friendsNew);


        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Home()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xD8606586),
      body: (pageInitialised)
          ? Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child :Align(
                    alignment: Alignment.center,
                    child : Text(
                      "Welcome to NooB chAt",

                    )),
              ),
              //Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
              child :Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child :ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent, //background color of button
                        side: BorderSide(width:3, color:Colors.orangeAccent), //border width and color
                        elevation: 3, //elevation of button
                        shape: RoundedRectangleBorder( //to set border radius to button
                            borderRadius: BorderRadius.circular(30)
                        ),
                        padding: EdgeInsets.all(20) //content padding inside button
                    ),
                    child: Text('Sign in with Google'),
                    onPressed: handleSignIn,
                  ),
              ),
              ),

            ],
          )
      )
          : Center(
            child: SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
    );
  }
}