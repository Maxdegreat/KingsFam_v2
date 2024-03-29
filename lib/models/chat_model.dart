import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class Chat extends Equatable {
  final String? id; //1 make the class data
  final String chatName;
  final String? imageUrl; //if null just use creators image
  //final Map<String, dynamic> chatTheme;
  //final List<content> shared; learn shared pref and store on phones
  final Map<String, dynamic> recentMessage; // msg, sendername, time
  final List<String> activeMems;
  //final Timestamp timestamp;
  final List<Userr>? members; // ui use
  final List<DocumentReference>? memRefs; // db use
  final Map<String, bool> readStatus;
  final Map<String, List<dynamic>> memberTokens;
  final List<String> searchPram;

  Chat({
    this.id,
    this.imageUrl,
    required this.activeMems,
    required this.chatName,
    this.members,
    this.memRefs,
    required this.memberTokens,
    required this.readStatus,
    required this.recentMessage,
    required this.searchPram,
    //required this.timestamp,

  });

  static Chat empty = Chat(
      activeMems: [],
      chatName: '...',
      members: [],
      readStatus: {},
      recentMessage: {},
      searchPram: [],
      memberTokens: {}
      //timestamp: Timestamp(0,0)
  );


  @override
  List<Object?> get props => [
        id, //3 make the props
        chatName,
        imageUrl,
        activeMems,
        members,
        memRefs,
        readStatus,
        recentMessage,
        searchPram,
        memberTokens,
      //  timestamp,
      ];



  // 5 make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'chatName': chatName,
      'imageUrl': imageUrl ?? null,
      'activeMems': activeMems,
      'memRefs': memRefs,
      'readStatus': readStatus,
      'recentMessage': recentMessage,
      'searchPram': searchPram,
      'memberTokens': memberTokens
      //'timestamp': timestamp just use the time stamp from recent message
    };
  }

  //6 from doc
  static Future<Chat> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    // grab the members
    final List<Userr> members =[];
    List<DocumentReference> memRefs = List<DocumentReference>.from(data['memRefs']);
    for (var docRef in memRefs) {
      var snap = await docRef.get();
      if (snap != null && snap.exists) {
        Userr member = Userr.fromDoc(snap);
        members.add(member);
      }
    }
    return Chat(
    id: doc.id,
    activeMems: List<String>.from(data['activeMems']),
    imageUrl: data['imageUrl'] ?? null, 
    members: members,
    memRefs: List<DocumentReference>.from(data['memRefs']),
    chatName: data['chatName'] ?? 'not named?', 
    readStatus: Map<String, bool>.from(data['readStatus'] ?? {}), 
    recentMessage: Map<String, dynamic>.from(data['recentMessage']),  
    searchPram: List<String>.from(data['searchPram']), 
    memberTokens: Map<String,List<dynamic>>.from(data['memberTokens'])
   // timestamp: data['timestamp'] ?? Timestamp(0, 0),
  );
  }



  Chat copyWith({
    String? id,
    String? chatName,
    String? imageUrl,
    Map<String, dynamic>? recentMessage,
    List<String>? activeMems,
    //Timestamp? timestamp,
    List<Userr>? members,
    List<DocumentReference>? memRefs,
    Map<String, bool>? readStatus,
    Map<String, List<dynamic>>? memberTokens,
    List<String>? searchPram,
  }) {
    return Chat(
      id: id ?? this.id,
      chatName: chatName ?? this.chatName,
      imageUrl: imageUrl ?? this.imageUrl,
      recentMessage: recentMessage ?? this.recentMessage,
      activeMems: activeMems ?? this.activeMems,
   //   timestamp: timestamp ?? this.timestamp,
      members: members ?? this.members,
      memRefs: memRefs ?? this.memRefs,
      memberTokens: memberTokens ?? this.memberTokens,
      readStatus: readStatus ?? this.readStatus,
      searchPram: searchPram ?? this.searchPram,
    );
  }
}
