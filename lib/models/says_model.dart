import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class Says extends Equatable {
  final String? id;
  final String? kcId;
  final String? title;
  final String contentTxt;
  // can be used for thumbnail. check if vidurl is null or not
  final String? contentImgUrl;
  final String? contentVidUrl;
  final int likes;
  final int commentsCount;
  final Timestamp date;
  final Userr? author;

  Says({
    this.id,
    this.title,
    this.kcId,
    required this.contentTxt,
    this.contentImgUrl,
    this.contentVidUrl,
    required this.likes,
    required this.commentsCount,
    required this.date,
    this.author,
  });

  static Says empty = Says(
      title: "Untitled",
      contentTxt: "...",
      likes: 0,
      commentsCount: 0,
      date: Timestamp.now(),
      author: Userr.empty);
  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        kcId,
        title,
        contentTxt,
        contentImgUrl,
        contentVidUrl,
        likes,
        commentsCount,
        date,
        author,
      ];

  Map<String, dynamic> toDoc() {
    return {
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author!.id),
      'title' : title ?? 'Untitled',
      "kcId": kcId,
      "contentTxt": contentTxt,
      "contentImgUrl": contentImgUrl,
      "contentVidUrl": contentVidUrl,
      "likes": likes,
      "commentsCount": commentsCount,
      "date": date,
    };
  }

  static Future<Says> fromDoc(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // grab the authorRef from author

    DocumentReference userDoc = data['author'] as DocumentReference;
    DocumentSnapshot userSnap = await userDoc.get();
    Userr user = await Userr.fromDoc(userSnap);
    log("user is: " + user.username);


    // return
    return Says(
        kcId: data['kcId'] ?? null,
        title: data['title'],
        contentTxt: data['contentTxt'] ?? "---",
        contentImgUrl: data['contentImgUrl'] ?? null,
        contentVidUrl: data['contentVidUrl'] ?? null,
        likes: data["likes"] ?? 0,
        commentsCount: data["commentsCount"] ?? 0,
        date: data["date"] ?? Timestamp.now(),
        author: user);
  }

  Says copywith({
    String? id,
    String? title,
    String? contentTxt,
    String? contentImgUrl,
    String? contentVidUrl,
    int? likes,
    int? commentsCount,
    Timestamp? date,
    String? authorRef,
    Userr? author,
  }) {
    return Says(
        title: title,
        contentTxt: contentTxt ?? this.contentTxt,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
        date: date ?? this.date,
        author: author ?? this.author);
  }
}
