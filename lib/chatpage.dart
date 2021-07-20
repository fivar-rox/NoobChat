import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'profilepage.dart';

class ChatPage extends StatefulWidget {
  final docs;

  const ChatPage({Key? key, this.docs}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? groupChatId;
  String? userID;

  TextEditingController textEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    getGroupChatId();
    super.initState();
  }

  getGroupChatId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userID = sharedPreferences.getString('id');

    String anotherUserId = widget.docs['id'];

    if (userID!.compareTo(anotherUserId) > 0) {
      groupChatId = '$userID - $anotherUserId';
    } else {
      groupChatId = '$anotherUserId - $userID';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('chat of $userID');
    return Scaffold(
        backgroundColor: const Color(0x66B7C2E2),
      appBar: AppBar(
        title:GestureDetector(
          onTap: ()  {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProfilePage(docs: widget.docs)));
          },
          child:Row(
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:  FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId!)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          //QuerySnapshot? QS = snapshot.data;
          if (snapshot.hasData && snapshot.data != null) {
            return Column(
              children: <Widget>[
                Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemBuilder: (listContext, index) =>
                          buildItem(snapshot.data!.docs[index]),
                      itemCount: snapshot.data!.docs.length,
                      reverse: true,
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
                              hintText: 'Enter your message',
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
                                      sendMsg(),
                                      textEditingController.clear(),
                                  }),),),),
                  ],
                ),
              ],
            );
          } else {
            return Center(
                child: SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ));
          }
        },
      ),
    );
  }

  sendMsg() {
    String msg = textEditingController.text.trim();

    /// Upload images to firebase and returns a URL
    if (msg.isNotEmpty) {
      print('thisiscalled $msg');
      var ref = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId!)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(ref, {
          "senderId": userID,
          "anotherUserId": widget.docs['id'],
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          'content': msg,
          "type": 'text',
          "time":  DateFormat('hh:mm').format(DateTime.now()),
        });
      });

      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
    } else {
      print('Please enter some text to send');
    }
    var friend =  FirebaseFirestore.instance.collection('users').doc(userID).collection('friends').doc(widget.docs['id']);
    friend.update({"last_time": DateTime.now(), 'last_time_normal':  DateFormat('hh:mm').format(DateTime.now())});
  }

  buildItem(doc) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          left: ((doc['senderId'] == userID) ? 64 : 5),
          right: ((doc['senderId'] == userID) ? 5 : 64)),
      child:Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: ((doc['senderId'] == userID)
                  ? const Color(0xDFFFB741)
                  : const Color(0x81B7C2E2)),
            borderRadius: BorderRadius.circular(8.0)),
      child :(doc['type'] == 'text')
          ? Row(children:<Widget>[
            Expanded(
              child: Text(
            ' ${doc['content']}',
              style: TextStyle(color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                doc['time'],
                style: TextStyle(
                  fontSize: 8.0,
                  color: Colors.grey[350],
                ),
              ),
            )
          ]
          )
          : Image.network(doc['content']),

          ),
    );
  }
}