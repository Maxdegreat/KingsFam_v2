import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class Says extends Equatable {
  final String? id;
  final String? kcId;
  final String cmName;
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
    this.kcId,
    required this.cmName,
    required this.contentTxt,
    this.contentImgUrl,
    this.contentVidUrl,
    required this.likes,
    required this.commentsCount,
    required this.date,
    this.author,
  });

  static Says empty = Says(
      cmName: "---",
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
        cmName,
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
      'cmName': cmName,
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
    final data = doc.data() as Map<String, dynamic>;
    // grab the authorRef from author
    var authDoc = null;
    Userr author = Userr.empty;
    final authorRef = data['author'] as DocumentReference?;
    if (authorRef != null) {
      authDoc = await authorRef.get();
      author = Userr.fromDoc(authDoc);
    } else {
      author = Userr.empty;
    }
    // return
    return Says(
        kcId: data['kcId'] ?? null,
        cmName: data['cmName'] ?? "---",
        contentTxt: data['contentTxt'] ?? "---",
        contentImgUrl: data['contentImgUrl'] ?? null,
        contentVidUrl: data['contentVidUrl'] ?? null,
        likes: data["likes"] ?? 0,
        commentsCount: data["commentsCount"] ?? 0,
        date: data["date"] ?? Timestamp.now(),
        author: author);
  }

  Says copywith({
    String? id,
    String? cmName,
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
        cmName: cmName ?? this.cmName,
        contentTxt: contentTxt ?? this.contentTxt,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
        date: date ?? this.date,
        author: author ?? this.author);
  }
}
