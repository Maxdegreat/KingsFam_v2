

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/roles_definition.dart';

class Church extends Equatable {
  //1 make the church class data
  final String? id;
  final String name;
  final String location;
  final List<String>? hashTags;
  final String imageUrl;
  final String about;
  final List<String> searchPram;
  final Map<Userr, dynamic> members;
  final List<String> events;
  final int? size;
  final Timestamp recentMsgTime;
  // 2 gen the constructor
  Church({
    required this.searchPram,
    this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    this.hashTags,
    required this.members,
    required this.events,
    required this.about,
    required this.recentMsgTime,
    this.size,
  });
  // 3 make the props
  @override
  List<Object?> get props => [
        id,
        searchPram,
        name,
        location,
        hashTags,
        imageUrl,
        about,
        members,
        events,
        recentMsgTime,
        size,
      ];
  //generate the copy with
  Church copyWith({
    String? id,
    List<String>? searchPram,
    List<String>? hashTags,
    String? name,
    String? location,
    String? imageUrl,
    String? about,
    Timestamp? recentMsgTime,
    Map<Userr, dynamic>? members,
    List<String>? events,
    int? size,
  }) {
    return Church(
      id: id ?? this.id,
      recentMsgTime: recentMsgTime ?? this.recentMsgTime,
      searchPram: searchPram ?? this.searchPram,
      hashTags: hashTags ?? this.hashTags,
      name: name ?? this.name,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      members: members ?? this.members,
      events: events ?? this.events,
      size: size ?? this.size,
    );
  }

  //5 make the to doc
  Map<String, dynamic> toDoc({required Map<String, String> roles}) {
  
    List<String> ids = members.keys.map((u) => u.id).toList();
    
    //DocumentReference<Map<String, dynamic>>
    Map< String, dynamic > memRefs = {};

    for (String id in ids) {
      if (roles.containsKey(id)) {
        memRefs[id] = {
        'userReference': FirebaseFirestore.instance.collection(Paths.users).doc(id),
        'timestamp': Timestamp.now(),
        'role' : roles[id] == '' || roles[id] == null ? Roles.Member : roles[id],
      } ;
      } else {
        memRefs[id] = {
        'userReference': FirebaseFirestore.instance.collection(Paths.users).doc(id),
        'timestamp': Timestamp.now(),
        'role' : Roles.Member,
      } ;
      }
    }

    return {
      'name': name,
      'location': location,
      'searchPram': searchPram,
      'hashTags': hashTags,
      'about': about,
      'imageUrl': imageUrl,
      'members' : memRefs,
      'events': events,
      'size' : size,
      'recentMsgTime': Timestamp.now(),
    };
  }


  Map<String, dynamic> toDocUpdate({required Map<String, String> roles}) {
  
    List<String> ids = members.keys.map((u) => u.id).toList();
    
    //DocumentReference<Map<String, dynamic>>
    Map< String, dynamic > memRefs = {};

    //! We only update the users who have a new role. otherwise the user would not have been updated.
    //! if you want to remove a user or add a user this is done through a different method
    for (String id in ids) {
      if (roles.containsKey(id)) {
        memRefs[id] = {
        'userReference': FirebaseFirestore.instance.collection(Paths.users).doc(id),
        'timestamp': Timestamp.now(),
        'role' : roles[id] == '' || roles[id] == null ? Roles.Member : roles[id],
      } ;
      } 
    }

    return {
      'name': name,
      'location': location,
      'searchPram': searchPram,
      'hashTags': hashTags,
      'about': about,
      'imageUrl': imageUrl,
      'members' : memRefs,
      'events': events,
      'size' : size,
      'recentMsgTime': Timestamp.now(),
    };
  }

  static Set<String> getCommunityMemberIds(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final memRefs = Map<String, dynamic>.from(data['members']);
    // ignore: unnecessary_null_comparison
    if (memRefs == null) return {}; 
    return memRefs.keys.toSet();
  }

  //6 from doc
  static Future<Church> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    Map< Userr, dynamic > members = {};
    final memRefs = Map<String, dynamic>.from(data['members']);//data['members'];
    
    // log("about to show you data in the mems ref");
    // for (var id in memRefs.keys) {
    //   log("id: $id, userRef: ${memRefs[id]['userReference']}, timeStamp: ${memRefs[id]['timestamp']}");
    // }
  
    if (memRefs == null) return Church.empty;
    for (String idFromDoc in memRefs.keys) {
      // ignore: unnecessary_null_comparison
      if (idFromDoc.isNotEmpty && idFromDoc != null) {
        var docRef = memRefs[idFromDoc]['userReference'] as DocumentReference;
        var snap = await docRef.get();
        Userr user = Userr.fromDoc(snap);
        //end goal is to have <user, time>
        members[user] = {
          'timestamp' : memRefs[idFromDoc]['timestamp'],
          'role' : memRefs[idFromDoc]['role'],
        };
      }
    }

    return Church(
        members: members,
        id: doc.id,
        size: data['size'] ?? 0,
        searchPram: List<String>.from(data['searchPram'] ?? []),
        hashTags: List<String>.from(data['hashTags'] ?? []),
        name: data['name'] ?? 'name',
        location: data['location'] ?? 'Heaven',
        about: data['about'] ?? 'bio',
        imageUrl: data['imageUrl'] ?? '',
        recentMsgTime: data['recentMsgTime'] ?? Timestamp(0, 0),
        events: List<String>.from(data['events'] ?? [],
      ), 
        
      );
  }

  //7 church. empty
  static Church empty = Church(
      searchPram: [],
      name: '...',
      location: '... ',
      imageUrl: '...',
      members: {},
      events: [],
      about: '...',
      recentMsgTime: Timestamp(0, 0),
      hashTags: [],
      size: 0,
    );
}
