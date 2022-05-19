
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class Church extends Equatable {
  //1 make the church class data
  final String? id;
  final String name;
  final String location;
  final List<String>? hashTags;
  final String imageUrl;
  final String about;
  final List<String> searchPram;
  final List<Userr> members;
  final List<String> events;
  final int? size;
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
    List<Userr>? members,
    List<String>? events,
    int? size,
  }) {
    return Church(
      id: id ?? this.id,
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
  Map<String, dynamic> toDoc() {
    List<String> ids = members.map((x) => x.id).toList();
    List<DocumentReference<Map<String, dynamic>>> memRefs = [];
    for (String id in ids) {
      DocumentReference<Map<String, dynamic>> ref = 
        FirebaseFirestore.instance.collection(Paths.users).doc(id);
      memRefs.add(ref);
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
    };
  }

  //6 from doc
  static Future<Church> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    List<Userr> members = [];
    final memRefs = data['members'];
  
    if (memRefs == null) return Church.empty;
    for (DocumentReference doc in memRefs) {
      var snap = await doc.get();
      if (snap.exists && snap.data() != null) {
        Userr user = Userr.fromDoc(snap);
        members.add(user);
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
        events: List<String>.from(data['events'] ?? []), 
        
      );
  }

  //7 church. empty
  static Church empty = Church(
      searchPram: [],
      name: '...',
      location: '... ',
      imageUrl: '...',
      members: [],
      events: [],
      about: '...',
      hashTags: [],
      size: 0,
    );
}
