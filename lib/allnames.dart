import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Allnames extends StatefulWidget{
  @override
  _AllnamesState createState() => _AllnamesState();
}

class _AllnamesState extends State<Allnames> {
  String? userID;
  List<String>? friends;
  List<bool> friendChecker=[]; //checks if a user is a friend or not.
  getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userID = sharedPreferences.getString('id');
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
    print('allnames of $userID');
    print('all friends in allname $friends');
    //String tempUser = userID!;
    // TODO: implement build
     return Scaffold(
      backgroundColor: const Color(0x81B7C2E2),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            friendChecker = List.generate((snapshot.data)!.docs.length, (index) =>  (friends!.contains((snapshot.data)!.docs[index]['id']))? true : false);
            return ListView.builder(
              itemBuilder: (listContext, index) =>
                  buildItem((snapshot.data)!.docs[index], index),
              itemCount: (snapshot.data)!.docs.length,
            );
          }

          return Container();
        },
      ),
    );

  }

  buildItem(doc, index) {

    return Padding(
      padding: EdgeInsets.only(top: 6.0),
      child: Card(
        color: Colors.orangeAccent[400],
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 2.0),
              child: CircleAvatar(
                radius: 20,
                child: ClipOval(child: Image.network(doc['profile_pic'])),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                  child: Container(
                    child: Text(doc['name']),
                  ),
            ),),
            (friendChecker[index])
                ?IconButton(
                //not functional yet. but soon will be. problem, is setting the bool value of friendChecker.
                  onPressed: () =>{
                    removeOldFriend(doc),
                  },
                  icon: Icon(Icons.person_remove_alt_1_outlined, color: Colors.white),)
                :IconButton(
                  onPressed: () =>{
                     addNewFriend(doc),
                  },
                  icon: Icon(Icons.person_add_alt_1_outlined, color: Colors.white),),

          ],
        ),
      ),


    );
  }
  // adding a new friend. Should update Chat list page. adding new function is not working.
  addNewFriend(doc) async {
    var newFriend = FirebaseFirestore.instance.collection('users').doc(userID).collection('friends').doc(doc['id']);
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    friends!.add(doc['id']);
    print('adding as friend'+doc['id']);
    newFriend.set({ "id" : doc['id'], 'name': doc['name'],'profile_pic': doc['profile_pic'],"last_time" : DateTime.now(),'last_time_normal' : DateFormat('hh:mm').format(DateTime.now()), "friended" : DateTime.now()});
    userDoc.update({'friends' : friends});
    SharedPreferences x = await SharedPreferences.getInstance();
    x.setStringList('friends', friends!);
  }

  removeOldFriend(doc) async {
    FirebaseFirestore.instance.collection('users').doc(userID).collection('friends').doc(doc['id']).delete();
    print('removing as a frnd:'+doc['id']);
    var userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    friends!.remove(doc['id']);
    userDoc.update({'friends' : friends});
    SharedPreferences x = await SharedPreferences.getInstance();
    x.setStringList('friends', friends!);
  }

}