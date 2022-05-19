import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/comment_model.dart';
import 'package:kingsfam/models/user_model.dart';

import 'church_model.dart';

// BELOW PREPOST IS A POST CLASS THE PRE POST IS USED IN CREATING A POST (THE CREATE_POST SCREEN TO BE EXACT WHEN PREVIEWING)

class PrePost extends Equatable {
  final Userr author;
  final Church? commuinity;
  final String? quote;
  final File? imageFile;
  final File? videoFile;
  final File?  thumbnailFile;
  final File? soundTrack;
  final String? caption;
  final int? height;
  PrePost({
    required this.author,
    required this.commuinity,
    this.quote,
    this.imageFile,
    this.videoFile,
    this.thumbnailFile,
    this.soundTrack,
    this.caption,
    this.height,
  });

  @override
  List<Object?> get props => [height, author, commuinity, quote, imageFile, videoFile, thumbnailFile, soundTrack, caption];

  PrePost copyWith({
    Userr? author,
    int? height,
    Church? commuinity,
    String? quote,
    File? imageFile,
    File? videoFile,
    File? thumbnailFile,
    File? soundTrack,
    String? caption,
  }) {
    return PrePost(
      author: author ?? this.author,
      commuinity: commuinity ?? null,
      quote: quote ?? this.quote,
      imageFile: imageFile ?? this.imageFile,
      videoFile: videoFile ?? this.videoFile,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      soundTrack: soundTrack ?? this.soundTrack,
      caption: caption ?? this.caption,
      height: height ?? this.height,
    );
  }
}


class Post extends Equatable {
  final String? id; //1 make the model
  final Userr author;
  final Church? commuinity;
  final String? quote; // String qoute that will be uploaded to fb
  final String? imageUrl; //img url uploaded to fb
  final String? videoUrl; // video url that will be uploaded to fb
  final String? thumbnailUrl;
  final String? soundTrackUrl; //bg sounds like tik tok
  final String? caption;
  final int likes;
  final Timestamp date;
  final int? height;
  Post({
    this.id,
    required this.author, //2 make the constructor
    this.commuinity,
    required this.quote,
    required this.imageUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.soundTrackUrl,
    required this.caption,
    required this.likes,
    required this.date,
    required this.height,
  });

  static Post empty = Post( author: Userr.empty, quote: null, imageUrl: null, videoUrl: null, thumbnailUrl: null, soundTrackUrl: null, caption: '', likes: 0, date: Timestamp(0, 0), height: 10);

  @override
  List<Object?> get props =>
      [id, height, author, commuinity,  quote, imageUrl, videoUrl, thumbnailUrl, soundTrackUrl, caption, likes, date]; //3 do props

  Post copyWith({
    String? id, //4 do the copy with
    Userr? author,
    Church? commuinity,
    String? quote,
    String? imageUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? soundTrackUrl,
    String? caption,
    int? likes,
    Timestamp? date,
    int? height,
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
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      date: date ?? this.date,
      height: height ?? this.height,
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
      'height': height,
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
      'height': height,
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
      print("_+_+_+_+_+_+_+_+_+_ COMM REFF IS NOT NULL");
         return Post(
            id: doc.id,
            author: Userr.fromDoc(authDoc),
            commuinity: null,
            quote: data['quote'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            thumbnailUrl: data['thumbnailUrl'] ?? null,
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            likes: data['likes'] ?? 77,
            caption: data['caption'] ?? null,
            date: (data['date'] ?? null ),
            height: (data['height']) ?? null,
        );
      } else {
      log("_+_+_+_+_+_+_+_+_+_ COMM REFF IS NULL FOUND OUT TOO LATE TO CATCH TRAIN THO");
        return Post(
            id: doc.id,
            author: Userr.fromDoc(authDoc),
            commuinity: null,
            quote: data['quote'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            thumbnailUrl: data['thumbnailUrl'] ?? null,
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            likes: data['likes'] ?? 77,
            caption: data['caption'] ?? null,
            date: (data['date'] ?? null ),
            height: (data['height']) ?? null,
        );
      }   
    }

    else if (authorRef != null) {
      print("_+_+_+_+_+_+_+_+_+_ COMM REFF IS NULL");

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
            height: (data['height']) ?? null,
        );
      }    
    }

  }

  //void elementAt(postIndex) {}
}


// old ... not working code below



/* 

  import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

import 'church_model.dart';

// BELOW PREPOST IS A POST CLASS THE PRE POST IS USED IN CREATING A POST (THE CREATE_POST SCREEN TO BE EXACT WHEN PREVIEWING)

class PrePost extends Equatable {
  final Userr author;
  final Church? commuinity;
  final String? quote;
  final File? imageFile;
  final File? videoFile;
  final File?  thumbnailFile;
  final File? soundTrack;
  final String? caption;
  final int? height;
  PrePost({
    required this.author,
    required this.commuinity,
    this.quote,
    this.imageFile,
    this.videoFile,
    this.thumbnailFile,
    this.soundTrack,
    this.caption,
    this.height,
  });

  @override
  List<Object?> get props => [height, author, commuinity, quote, imageFile, videoFile, thumbnailFile, soundTrack, caption];

  PrePost copyWith({
    Userr? author,
    int? height,
    Church? commuinity,
    String? quote,
    File? imageFile,
    File? videoFile,
    File? thumbnailFile,
    File? soundTrack,
    String? caption,
  }) {
    return PrePost(
      author: author ?? this.author,
      commuinity: commuinity ?? null,
      quote: quote ?? this.quote,
      imageFile: imageFile ?? this.imageFile,
      videoFile: videoFile ?? this.videoFile,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      soundTrack: soundTrack ?? this.soundTrack,
      caption: caption ?? this.caption,
      height: height ?? this.height,
    );
  }
}


class Post extends Equatable {
  final String? id; //1 make the model
  final Userr author;
  final Church? commuinity;
  final String? quote; // String qoute that will be uploaded to fb
  final String? imageUrl; //img url uploaded to fb
  final String? videoUrl; // video url that will be uploaded to fb
  final String? thumbnailUrl;
  final String? soundTrackUrl; //bg sounds like tik tok
  final String? caption;
  final int likes;
  final Timestamp date;
  final int? height;
  Post({
    this.id,
    required this.author, //2 make the constructor
    this.commuinity,
    required this.quote,
    required this.imageUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.soundTrackUrl,
    required this.caption,
    required this.likes,
    required this.date,
    required this.height,
  });

  static Post empty = Post(author: Userr.empty, quote: null, imageUrl: null, videoUrl: null, thumbnailUrl: null, soundTrackUrl: null, caption: 'This post has been ctrl + alt + del ...', likes: 0, date: Timestamp.now(), height: 10);

  @override
  List<Object?> get props =>
      [id, height, author, commuinity,  quote, imageUrl, videoUrl, thumbnailUrl, soundTrackUrl, caption, likes, date]; //3 do props

  Post copyWith({
    String? id, //4 do the copy with
    Userr? author,
    Church? commuinity,
    String? quote,
    String? imageUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? soundTrackUrl,
    String? caption,
    int? likes,
    Timestamp? date,
    int? height,
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
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      date: date ?? this.date,
      height: height ?? this.height,
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
      'height': height,
    };
  }

  Map<String, dynamic> toDocNoCommuinitys() =>{
    'author': FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'quote' : quote,
      'imageUrl': imageUrl,
      'videoUrl' : videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'soundTrackUrl' : soundTrackUrl,
      'caption': caption,
      'likes': likes,
      'date': Timestamp.now(),
      'height': height,
  };

  static Future<Post?> fromDoc(DocumentSnapshot doc) async {
    //6 from doc
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference?;
    final commRef = data['commuinity'] as DocumentReference?;

    print("The data at comm: ${commRef == null}");
    if (commRef != null)
      var commDoc = await commRef.get();
    

    if (authorRef != null && commRef != null) {
      final authorDoc = await authorRef.get();
      final commDoc = await commRef.get();
    
      if (authorDoc.exists && commDoc.exists) {
        return Post(
            id: doc.id,
            
            author: Userr.fromDoc(authorDoc),

            commuinity: Church.fromDoc(commDoc),
            
            quote: data['quote'] ?? null,
            
            imageUrl: data['imageUrl'] ?? null,
            
            videoUrl: data['videoUrl'] ?? null,

            thumbnailUrl: data['thumbnailUrl'] ?? null,
            
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            
            //likes: (data['likes'] ?? 0).toInt,
            likes: (data['likes'] ?? 0).toInt(),
            caption: data['caption'] ?? null,
            
            date: (data['date'] ?? null ),

            height: data['height'] ?? null,
          );
      }
    } else if (authorRef != null) {
      final authorDoc = await authorRef.get();
      return Post(
            id: doc.id,
            
            author: Userr.fromDoc(authorDoc),

            commuinity: null,
            
            quote: data['quote'] ?? null,
            
            imageUrl: data['imageUrl'] ?? null,
            
            videoUrl: data['videoUrl'] ?? null,

             thumbnailUrl: data['thumbnailUrl'] ?? null,
            
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            
            //likes: data['likes'] ?? 0,
            likes: (data['likes'] ?? 0).toInt(),

            caption: data['caption'] ?? null,
            
            date: (data['date'] ?? null ),

            height: (data['height']) ?? null,
          );
    }
    return Post.empty;
  }

  //void elementAt(postIndex) {}
}





*/