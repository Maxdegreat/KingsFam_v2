import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

import 'church_model.dart';


// stings for promoted: promotedL1

class Post extends Equatable {
  final String? id; //1 make the model
  final Userr author;
  final Church? commuinity;
  final String? quote; // String qoute that will be uploaded to fb
  final String? imageUrl; //img url uploaded to fb
  final String? videoUrl; // video url that will be uploaded to fb
  final String? thumbnailUrl;
  final String? assetVideoPath;
  final String? assetImgPath;
  final String? soundTrackUrl; //bg sounds like tik tok
  final String? caption;
  final int likes;
  final Timestamp date; 
  final int commentCount;
  Post({
    this.id,
    required this.author, //2 make the constructor
    this.commuinity,
    required this.quote,
    required this.imageUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.assetVideoPath,
    this.assetImgPath,
    required this.soundTrackUrl,
    required this.caption,
    required this.likes,
    required this.date,
    required this.commentCount,
  });

  static Post empty = Post( author: Userr.empty, quote: null, imageUrl: null, videoUrl: null, thumbnailUrl: null, soundTrackUrl: null, caption: '', likes: 0, date: Timestamp(0, 0), commentCount: 0);
  
  static Post mockImg = Post(id: "mockID77", author: Userr.mock, quote: null, imageUrl: "https://github.com/amagalla1394/odin-recipe-git-test/blob/main/recipes/images/Steamed_Pork_Buns.jpg?raw=true", videoUrl: null, thumbnailUrl: null, soundTrackUrl: null, caption: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum', commuinity: Church.mock, likes: 0, date: Timestamp(0, 0), commentCount: 10);

  static Post mockVid = Post(id: "mockID77", author: Userr.mock, quote: null, imageUrl: null, videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", thumbnailUrl: "https://github.com/amagalla1394/odin-recipe-git-test/blob/main/recipes/images/Steamed_Pork_Buns.jpg?raw=true", soundTrackUrl: null, caption: 'This is a mock caption. I am making this caption long so that I can see how kingsfam post looks with a long cpation. really i do not care how this caption looks. anyways Thsi is just for mocking pleae remember this and it should not make any sence. letys see how fast I can type.', commuinity: Church.mock, likes: 0, date: Timestamp(0, 0), commentCount: 10);

  @override
  List<Object?> get props =>
      [id, author, commuinity,  quote, imageUrl, videoUrl, thumbnailUrl, soundTrackUrl, caption, likes, date, commentCount]; //3 do props

  Post copyWith({
    String? id, //4 do the copy with
    Userr? author,
    Church? commuinity,
    String? quote,
    String? imageUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? soundTrackUrl,
    String? assetVideoPath,
    String? assetImgPath,
    String? caption,
    int? likes,
    Timestamp? date,
    int? height,
    int? commentCount,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      commuinity: commuinity ?? this.commuinity,
      quote: quote ?? this.quote,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      soundTrackUrl: soundTrackUrl ?? this.soundTrackUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      assetImgPath: assetImgPath ?? this.assetImgPath,
      assetVideoPath: assetVideoPath ?? this.assetVideoPath,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      date: date ?? this.date,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toDocWithCommuinitys() {
    return {
      'author': //5 write to doc
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'commuinity' : 
          FirebaseFirestore.instance.collection(Paths.church).doc(commuinity!.id),
      'quote' : quote,
    
      'imageUrl': imageUrl,
      'videoUrl' : videoUrl,
      'thumbnailUrl' : thumbnailUrl,
      'soundTrackUrl' : soundTrackUrl,
      'caption': caption,
      'likes': likes,
      'date': Timestamp.now(),
      'commentCount': 0
    };
  }

  Map<String, dynamic> toDocNoCommuinitys() =>{
    'author': FirebaseFirestore.instance.collection(Paths.users).doc(author.id),

      'imageUrl': imageUrl,
      'videoUrl' : videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'soundTrackUrl' : soundTrackUrl,
      'caption': caption,
      'likes': likes,
      'date': Timestamp.now(),
      'commentCount': 0,
  };

  

  static Future<Post?> fromDoc(DocumentSnapshot doc) async {

    //6 from doc
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference?;
    final commRef = data['commuinity'] as DocumentReference?;

      if (authorRef != null && commRef != null) {
      var authDoc = await authorRef.get();
      var commDoc = await commRef.get();
      if (authDoc.data() != null && commDoc.data() != null) {
      final Church cm = await Church.fromDoc(commDoc);
         return Post(
            id: doc.id,
            author: Userr.fromDoc(authDoc),
            commuinity: cm,
            quote: data['quote'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            thumbnailUrl: data['thumbnailUrl'] ?? null,
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            likes: data['likes'] ?? 0,
            caption: data['caption'] ?? null,
            date: (data['date'] ?? null ),
            commentCount: data['commentCount'] ?? 0
        );
      } else {
        return Post(
            id: doc.id,
            author: Userr.fromDoc(authDoc),
            commuinity: null,
            quote: data['quote'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            thumbnailUrl: data['thumbnailUrl'] ?? null,
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            likes: data['likes'] ?? 0,
            caption: data['caption'] ?? null,
            date: (data['date'] ?? null ),
            commentCount: data['commentCount'] ?? 0
        );
      }   
    }

    else if (authorRef != null) {

      var authDoc = await authorRef.get();
      if (authDoc.data() != null ) {
         return Post(
            id: doc.id,
            author: Userr.fromDoc(authDoc),
            commuinity: null,
            quote: data['quote'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            thumbnailUrl: data['thumbnailUrl'] ?? null,
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            likes: (data['likes']).toInt() ?? 77,
            caption: data['caption'] ?? null,
            date: (data['date'] ?? null ),
            commentCount: data['commentCount'] ?? 0
        );
      }    
    }
      return null;

  }

  //void elementAt(postIndex) {}
}

