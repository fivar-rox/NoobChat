import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CreateBlog extends StatefulWidget{
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  TextEditingController textEditingController = TextEditingController();
  String? userID, profilePic, name;
  List<String> likedUser = [];

  getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userID = sharedPreferences.getString('id');
    profilePic = sharedPreferences.getString('profile_pic');
    name = sharedPreferences.getString('name');
    setState(() {});
  }
  @override
  void initState() {
    getUserId();
    super.initState();
  }

  uploadBlog(){
    String content = textEditingController.text.trim();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String docID = '$userID + $timestamp';
    var publish = FirebaseFirestore.instance.collection('blogs').doc(docID);
    var userDetails = FirebaseFirestore.instance.collection('users').doc(userID).get();

    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.set(publish, {
        'BlogContent': content,
        'time' :  DateFormat('hh:mm').format(DateTime.now()),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'id' : userID,
        'likes' : 0,
        'comments' : 0,
        'timestamp' : timestamp,
        'docid' : docID,
        'name' : name,
        'profile_pic' : profilePic,
        'likedUsers' : likedUser,
      });
    });
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title :Text('HELLO is this working')

      ),
      backgroundColor: const Color(0x81B7C2E2),
      body:
      Padding(
        padding: EdgeInsets.all(5.0),
          child:Column(
            children: <Widget>[
              Text('Create a Blog'),
              TextField(
                controller: textEditingController,
                style:TextStyle (
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  /*enabledBorder:OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal(),
                              ) ,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),*/
                    filled: true,
                    fillColor: Colors.black12,
                    hintText: 'Enter your message',
                    hintStyle: TextStyle(
                      color: Colors.white60,
                    )
                ),
                cursorColor: Colors.orange,
              ),
              ElevatedButton(
                  onPressed: uploadBlog,
                  child: Text('Publish')
              )

            ],
          )
      )
    );
  }
}