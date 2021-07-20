import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noobchat/blank.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profilepage.dart';
import 'blogpage.dart';
import 'createblog.dart';
import 'blank.dart';

class Blog extends StatefulWidget {
  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  String? userID;
  var likeIcon = Icon(Icons.check_circle_outline);
  var dislikeIcon = Icon(Icons.check_circle);
  List<bool> liked =[];
  bool firstTimeInitial = true;
  int blogNum=0;

  getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userID = sharedPreferences.getString('id');
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
    return Scaffold(
      backgroundColor: const Color(0x81B7C2E2),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blogs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            liked = List.generate((snapshot.data)!.docs.length, (index) =>((snapshot.data)!.docs[index]['likedUsers'].contains(userID))? true : false);
            print(liked);
            return ListView.builder(
                itemBuilder: (listContext, index) =>
                 buildItem((snapshot.data)!.docs[index], index),
              itemCount: (snapshot.data)!.docs.length,
            );
          }
          else {
            return Center(
              child: Text('You Have No friends to see Blogs.'),
            );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateBlog()));
        },
        child: Icon(
          Icons.add,
          color: Colors.orangeAccent[400],
        ),
        backgroundColor: const Color(0x66B7C2E2),

      ),
    );
  }

  buildItem(doc, index){
    index = index;
    int likes = doc['likes'];
    return Padding(
      padding: EdgeInsets.all(5.0),
      child :Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.orange,
        child:Padding(
          padding: EdgeInsets.all(0.0),
          child:Column(
            children:<Widget>[
              //Widget 1: name and date and time in column
              // TODO: add profile picture. In the end. show time and date more nicely ig.
              Container(
                color: Colors.orange[700],
                child:Padding(
                  padding: EdgeInsets.only(left: 5.0,top:4.0, bottom: 4.0),
                    child:Row(
                      children:<Widget> [
                        Expanded(
                            child:GestureDetector(
                              onTap: (){
                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ProfilePage(docs: doc)));
                              },
                              child: Text(doc['name'])
                          )
                        ),
                        Text(doc['date']),

                        Padding( padding: EdgeInsets.only(left: 5.0, right: 8.0), child:Text(doc['time']))
                      ],
                    )
                ),
              ),

              //Widget 2: blog msg.
              Align(
                alignment: Alignment.centerLeft,
                child:Padding(
                // TODO: add create a blog page and add a gesture detector.
                  padding: EdgeInsets.all(10.0),
                  child:Text(
                    doc['BlogContent'],
                    maxLines: 4,
                )
              ),),

              //Widget 3: column with like button(number) comment button and save button.
              Padding(
                padding: EdgeInsets.all(7.0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                        onPressed:() => {
                          // TODO: have to link likes with users.
                          (liked[index])? decreaseLike(doc) : increaseLike(doc),
                          setState(() {
                            liked[index] = !(liked[index]);
                          }),
                          print('the bool value of $index'),
                          print(liked),
                        },
                        icon: (liked[index]) ? dislikeIcon :likeIcon,
                    ),
                    Text('$likes'),
                    IconButton(
                      onPressed:() => {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => BlogPage(docs: doc)))
                      },
                      icon: Icon(Icons.comment_rounded),
                    ),
                  ],
                ),
              )
            ]
          )
        )

      )
    );
  }

  //increasing no.of likes
  increaseLike(doc){
    // TODO: Have to find more secure method to do this.
    var likes = FirebaseFirestore.instance.collection('blogs').doc(doc['docid']);
    int newLikes = doc['likes']+1;
    var likedUser = doc['likedUsers'];
    likedUser.add(userID!);
    likes.update({'likes': newLikes, 'likedUsers' : likedUser});
    //setState(() {});
  }

  //decreasing no.of likes
  decreaseLike(doc){
    var likes = FirebaseFirestore.instance.collection('blogs').doc(doc['docid']);
    int newLikes = doc['likes']-1;
    var likedUser = doc['likedUsers'];
    likedUser.remove(userID!);
    likes.update({'likes': newLikes,'likedUsers' : likedUser});
    setState(() {});
  }

}
