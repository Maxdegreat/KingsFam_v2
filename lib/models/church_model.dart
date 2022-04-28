import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
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
  final List<String> memberIds;
  final Map<String, dynamic> memberInfo;
  final List<String> events;
  final int? size;
  // 2 gen the constructor
  Church({
    required this.searchPram,
    this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.memberIds,
    this.hashTags,
    required this.memberInfo,
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
        memberIds,
        memberInfo,
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
    List<String>? memberIds,
    Map<String, dynamic>? memberInfo,
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
      memberIds: memberIds ?? this.memberIds,
      memberInfo: memberInfo ?? this.memberInfo,
      events: events ?? this.events,
      size: size ?? this.size,
    );
  }

  //5 make the to doc
  Map<String, dynamic> toDoc() {
    
    return {
      'name': name,
      'location': location,
      'searchPram': searchPram,
      'hashTags': hashTags,
      'about': about,
      'imageUrl': imageUrl,
      'memberIds': memberIds,
      'memberInfo': memberInfo,
      'events': events,
      'size' : size,
    };
  }

  //6 from doc
  static Church fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Church(
        id: doc.id,
        size: data['size'] ?? 0,
        searchPram: List<String>.from(data['searchPram'] ?? []),
        hashTags: List<String>.from(data['hashTags'] ?? []),
        name: data['name'] ?? 'name',
        location: data['location'] ?? 'Heaven',
        about: data['about'] ?? 'bio',
        imageUrl: data['imageUrl'] ?? '',
        events: List<String>.from(data['events'] ?? []),
        memberIds: List<String>.from(data['memberIds'] ?? []),
        memberInfo: Map<String, dynamic>.from(data['memberInfo'] ?? {}));
  }

  //7 church. empty
  static Church empty = Church(
      searchPram: [],
      name: '...',
      location: '... ',
      imageUrl: '...',
      memberIds: [],
      memberInfo: {},
      events: [],
      about: '...',
      hashTags: [],
      size: 0,
    );
}
