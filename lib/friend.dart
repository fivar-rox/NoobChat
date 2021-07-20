import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'chatpage.dart';

class Friend extends StatefulWidget{
  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend>{
 // GoogleSignIn googleSignIn = GoogleSignIn();
  String? userId;
  List<String>? friends;

  getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userId = sharedPreferences.getString('id');
    friends = sharedPreferences.getStringList('friends');
    setState(() {});
  }

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('friend of $userId');
    return Scaffold(
      backgroundColor: const Color(0x81B7C2E2),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').orderBy('last_time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              itemBuilder: (listContext, index) =>
                  buildItem((snapshot.data)!.docs[index]),
              itemCount: (snapshot.data)!.docs.length,
            );
          }
          else{
            return Center(
              child :Text('You Have No friends'),
          );
          }
        },
      ),
    );
  }

  buildItem(doc) {
    return (userId != doc['id'])
        ?Padding (
          padding : EdgeInsets.only(top: 6.0),
          child : GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatPage(docs: doc)));
            },
            child: Card(
                  color: Colors.orangeAccent[400],
                  child:Row(
                    children:<Widget>[
                      Padding (
                        padding: EdgeInsets.fromLTRB(5.0, 2.0,5.0,2.0),
                        child :CircleAvatar(
                          radius: 20,
                          child: ClipOval(child: Image.network(doc['profile_pic'])),
                        ),
                      ),
                      Expanded(
                        child :Padding(
                          padding: const EdgeInsets.fromLTRB(10.0,10.0,0.0,10.0),
                            child: Container(
                                child: Text(doc['name']),
                            ),
                          ),),
                      Padding(
                        padding: EdgeInsets.only(right:10.0),
                        child :Text(
                          doc['last_time_normal'],
                          style: TextStyle(
                            fontSize: 10.0,
                          ),
                        ),
                      )
                  ],
                  ),
            ),




      ),)
        : Container();
  }
}