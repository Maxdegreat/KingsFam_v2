import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/fancy_list_tile.dart';

// a list view of commuinitys that i am a part of yeahhhh

// howto: ---> 1) i need user crdentials to access the users commuinty list
// 2) streambuilder????

class CommuinityContainer extends StatefulWidget {
  const CommuinityContainer({ required String this.userId, });
  final String userId;
  @override
  State<CommuinityContainer> createState() => _CommuinityContainerState();
}

class _CommuinityContainerState extends State<CommuinityContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(Paths.church).where('memberIds', arrayContains: widget.userId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (!snapshot.hasData) { // has no daat
            return Text("The snap has no data");
        } else if (snapshot.data!.docs.length <= 0) {// has data but no docs , bad
          return Text("The snap is bad, no data");
        } else { // is good
          // return the listtile 
          return CommuinityListTile(context, snapshot);
        }
      },
    );
  }
}

Padding CommuinityListTile(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  bool moreBtn = true;
  // make data for first two commuinitys
  Church commuinity1 = Church.fromDoc(snapshot.data!.docs[0]);
  Church? commuinity2 = snapshot.data!.docs.length >= 2 ? Church.fromDoc(snapshot.data!.docs[1]) : null;

  bool greaterThan2 = snapshot.data!.docs.length >= 2 ? true : false;


  var oneCommuinitys = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FancyListTile(username: commuinity1.name, imageUrl: commuinity1.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12),
        ],
      );
  
  var twoCommuinitys = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 10),
          child: FancyListTile(username: commuinity1.name, imageUrl: commuinity1.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12),),
          greaterThan2 ? FancyListTile(username: commuinity2!.name, imageUrl: commuinity2.imageUrl, onTap: null, isBtn: false, BR: 12, height: 12 , width: 12) : SizedBox.shrink() ,
        ],
      );

  
  // make data for the listtile (when moreBtn == true)

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0,),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton(onPressed:() {}, style: TextButton.styleFrom(primary: Colors.white), child: Text("See More", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),),
        Container(
          child: !moreBtn ? Container() : greaterThan2 ? twoCommuinitys : oneCommuinitys,
        ),
      ],
    ),
  );
}