import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Userr extends Equatable {
  final String id;
  final String username;
  final List<String> usernameSearchCase;
  final String email;
  final List<String> token;
  final String bio;
  final String location;
  final String profileImageUrl;
  final String bannerImageUrl;
  final int following;
  final int followers;
  final List<String> friends;
  final String colorPref;
  final int? turbo;

  Userr(
      {required this.id,
      required this.username,
      required this.usernameSearchCase,
      required this.email,
      required this.token,
      required this.bio,
      required this.location,
      required this.profileImageUrl,
      required this.bannerImageUrl,
      required this.following,
      required this.followers,
      required this.friends,
      required this.colorPref,
      this.turbo});

  static Userr empty = Userr(
      id: 'del_not_found0987654321',
      username: 'not found',
      usernameSearchCase: [],
      email: '',
      location: '',
      token: [],
      following: 0,
      followers: 0,
      profileImageUrl: '',
      bannerImageUrl: '',
      bio: '',
      friends: [],
      colorPref: '#9814F4' // set the default to 'real purple'
      );

  static Userr mock = Userr(
    email: '',
    location: '',
    token: [],
    following: 0,
    followers: 0,
    usernameSearchCase: [],
    bio: '',
    friends: [],
    colorPref: '#9814F4',
    id: "777MockId21",
    profileImageUrl:
        "https://github.com/amagalla1394/odin-recipe-git-test/blob/main/recipes/images/Steamed_Pork_Buns.jpg?raw=true",
    bannerImageUrl: "",
    username: "WalkByFaith27",
  );

  @override
  List<Object?> get props => [
        id,
        username,
        usernameSearchCase,
        email,
        bio,
        location,
        token,
        profileImageUrl,
        bannerImageUrl,
        following,
        followers,
        friends,
        colorPref,
        turbo
      ];

  Userr copyWith({
    String? id,
    String? username,
    List<String>? usernameSearchCase,
    String? email,
    String? bio,
    List<String>? token,
    String? location,
    String? profileImageUrl,
    String? bannerImageUrl,
    int? following,
    int? followers,
    List<String>? friends,
    String? colorPref,
    int? turbo,
  }) {
    return Userr(
      id: id ?? this.id,
      username: username ?? this.username,
      usernameSearchCase: usernameSearchCase ?? this.usernameSearchCase,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      token: token ?? this.token,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      friends: friends ?? this.friends,
      colorPref: colorPref ?? this.colorPref,
      turbo: turbo ?? turbo,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'username': username,
      'usernameSearchCase': usernameSearchCase,
      'email': email,
      'bio': bio,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'bannerImageUrl': bannerImageUrl,
      'followers': followers,
      'following': following,
      'friends': friends,
      'colorPref': colorPref,
      'turbo': turbo
    };
  }

  factory Userr.getId(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Userr(
        id: doc.id,
        username: '',
        usernameSearchCase: [],
        email: '',
        token: [],
        bio: 'bio',
        location: '',
        profileImageUrl: '',
        bannerImageUrl: '',
        following: 0,
        followers: 0,
        friends: [],
        colorPref: '');
  }

  factory Userr.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Userr(
      id: doc.id,
      username: data['username'] ?? '',
      usernameSearchCase: List<String>.from(data['usernameSearchCase'] ?? []),
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      bannerImageUrl: data['bannerImageUrl'] ?? '',
      bio: data['bio'] ?? '',
      following: (data['following'] ?? 0).toInt(),
      followers: (data['followers'] ?? 0).toInt(),
      token: List<String>.from(data['token']),
      friends: List<String>.from(data['friends'] ?? []),
      colorPref: data['colorPref'] ?? '#9814F4',
      turbo: data['turbo'] ?? null,
    );
  }
}
