import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'chatpage.dart';

class ProfilePage extends StatefulWidget {
  final docs;

  const ProfilePage({Key? key, this.docs}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //building profile page for a user.

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                child: ClipOval(child: Image.network(widget.docs['profile_pic'])),
              ),
              Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child :Text(widget.docs['name']))
            ],
          ),
        ),
        body:Container(
          child:Padding(
            padding: EdgeInsets.only(top: 20),
            child:Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget>[
                CircleAvatar(
                  radius: 50,
                  child: ClipOval(child: Image.network(widget.docs['profile_pic'])),
                ),
                Padding(
                    padding: EdgeInsets.only(top:10.0),
                    child: Text(
                      widget.docs['name'],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
                Padding(
                    padding:EdgeInsets.only(top: 10.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget> [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrangeAccent, //background color of button
                            //side: BorderSide(width:3, color:Colors.orangeAccent), //border width and color
                            elevation: 3, //elevation of button
                            shape: RoundedRectangleBorder( //to set border radius to button
                                borderRadius: BorderRadius.circular(30)
                            ),
                            padding: EdgeInsets.all(5) //content padding inside button
                        ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ChatPage(docs: widget.docs)));
                          },
                          child: Text(
                            'CHAT'
                          ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 15),
                        child:ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            primary: Colors.deepOrangeAccent, //background color of button
                          ),
                            onPressed: (){
                              //do nothing
                            },
                            child:Icon(
                              Icons.person_add_alt_1_outlined,
                            )
                        ))
                    ],
                  )
                )
              ]
            )
          )
        )
    );
  }
}