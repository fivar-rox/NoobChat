import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'profilepage.dart';

class BlogPage extends StatefulWidget {
  final docs;

  const BlogPage({Key? key, this.docs}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  var likeIcon = Icon(Icons.check_circle_outline);
  var dislikeIcon = Icon(Icons.check_circle);
  var useIcon;
  bool liked = false;
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? userID, name, profilePic;

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

  @override
  Widget build(BuildContext context){
    int likes = widget.docs['likes'];
    var likedUser = widget.docs['likedUsers'];
    liked = likedUser.contains(userID);
    useIcon = likeIcon;
    return Scaffold(
      backgroundColor: const Color(0x66B7C2E2),
      appBar: AppBar(
        title: Text('noobBlogs'),
      ),
      body:Column(
        children:<Widget>[
          //blog card
        Padding(
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
                                                  MaterialPageRoute(builder: (context) => ProfilePage(docs: widget.docs)));
                                            },
                                            child: Text(widget.docs['name'])
                                        )
                                    ),
                                    Text(widget.docs['date']),

                                    Padding( padding: EdgeInsets.only(left: 5.0, right: 8.0), child:Text(widget.docs['time']))
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
                                  widget.docs['BlogContent'],
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
                                    (liked)? decreaseLike(widget.docs) : increaseLike(widget.docs),
                                    setState(() {
                                      liked = !(liked);
                                      likes = widget.docs['likes'];
                                    }),
                                    print(liked),
                                  },
                                  icon: (liked) ? dislikeIcon : likeIcon,
                                ),
                                Text('$likes'),
                                IconButton(
                                  onPressed:() => {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => BlogPage(docs: widget.docs)))
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
          ),

          //comments and text field.
          Expanded(child:StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('blogs').doc(widget.docs['docid']).collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  children: <Widget>[
                    Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemBuilder: (listContext, index) =>
                              buildItem(snapshot.data!.docs[index]),
                          itemCount: snapshot.data!.docs.length,
                          //reverse: true,
                        )),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left :5.0,bottom: 3.0),
                            child: TextField(
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
                                  hintText: 'Enter your comment',
                                  hintStyle: TextStyle(
                                    color: Colors.white60,
                                  )
                              ),
                              cursorColor: Colors.orange,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child :CircleAvatar(
                            backgroundColor: Colors.orange,
                            radius: 25.0,
                            child: Center(
                              child:IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => {
                                    comment(),
                                    textEditingController.clear(),
                                  }),),),),
                      ],
                    ),
                  ],
                );
              }
              else {
                return Center(
                  child: Text('You Have No friends to see Blogs.'),
                );
              }
            },
          ),)

        ],
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

  //comments the blog
  comment(){
    String msg = textEditingController.text.trim();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String commentID = '$userID + $timestamp';

    var comment = FirebaseFirestore.instance.collection('blogs').doc(widget.docs['docid']).collection('comments').doc(commentID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.set(comment, {
        'comment': msg,
        'time' :  DateFormat('hh:mm').format(DateTime.now()),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'id' : userID,
        'timestamp' : timestamp,
        'commentid' : commentID,
        'name' : name,
        'profile_pic' : profilePic,
      });
    });

    var count = FirebaseFirestore.instance.collection('blogs').doc(widget.docs['docid']);
    count.update({'comments': widget.docs['comments'] + 1});
  }

  //small comment card with user name and a like button.
  buildItem(doc){
    return Padding(
        padding: EdgeInsets.all(5.0),
      child:Container(
        width: MediaQuery.of(context).size.width,
          color: Colors.orange[300],
          child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 17,
              child: ClipOval(child: Image.network(doc['profile_pic'])),
            ),
            Expanded(
                child:Column(
                  children:<Widget> [
                    Row(
                      children:<Widget> [
                        //TODO add Date.
                        Expanded(child: Padding(padding: EdgeInsets.only(left:5.0,top: 5.0), child : Text(doc['name']))),
                        Padding(padding: EdgeInsets.only(right:5.0), child: Text(doc['time'], style: TextStyle(fontSize: 10.0),),)
                      ],
                    ),
                    Align(alignment: Alignment.centerLeft,child: Padding(padding: EdgeInsets.all(5.0), child: Text(doc['comment']))),
                  ],
                )
              )
          ],
        )
      )
    );
  }
}