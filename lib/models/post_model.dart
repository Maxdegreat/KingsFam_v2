import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

import 'church_model.dart';

class Post extends Equatable {
  final String? id; //1 make the model
  final Userr author;
  final Church? commuinity;
  final String? quote; // String qoute that will be uploaded to fb
  final String? imageUrl; //img url uploaded to fb
  final String? videoUrl; // video url that will be uploaded to fb
  final String? soundTrackUrl; //bg sounds like tik tok
  final String? caption;
  final int likes;
  final Timestamp date;
  Post({
    this.id,
    required this.author, //2 make the constructor
    this.commuinity,
    required this.quote,
    required this.imageUrl,
    required this.videoUrl,
    required this.soundTrackUrl,
    required this.caption,
    required this.likes,
    required this.date,
  });

  @override
  List<Object?> get props =>
      [id, author, commuinity,  quote, imageUrl, videoUrl, soundTrackUrl, caption, likes, date]; //3 do props

  Post copyWith({
    String? id, //4 do the copy with
    Userr? author,
    Church? commuinity,
    String? quote,
    String? imageUrl,
    String? videoUrl,
    String? soundTrackUrl,
    String? caption,
    int? likes,
    Timestamp? date,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      commuinity: commuinity ?? this.commuinity,
      quote: quote ?? this.quote,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      soundTrackUrl: soundTrackUrl ?? this.soundTrackUrl,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'author': //5 write to doc
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'commuinity' : 
          FirebaseFirestore.instance.collection(Paths.church).doc(commuinity!.id),
      'quote' : quote,
      'imageUrl': imageUrl,
      'videoUrl' : videoUrl,
      'soundTrackUrl' : soundTrackUrl,
      'caption': caption,
      'likes': likes,
      'date': Timestamp.now()
    };
  }

  static Future<Post?> fromDoc(DocumentSnapshot doc) async {
    //6 from doc
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference?;
    final commRef = data['commuinity'] as DocumentReference?;

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
            
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            
            //likes: (data['likes'] ?? 0).toInt,
            likes: (data['likes'] ?? 0).toInt(),
            caption: data['caption'] ?? null,
            
            date: (data['date'] ?? null )
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
            
            soundTrackUrl: data['soundTrackUrl'] ?? null,
            
            //likes: data['likes'] ?? 0,
            likes: (data['likes'] ?? 0).toInt(),

            caption: data['caption'] ?? null,
            
            date: (data['date'] ?? null )
          );
    }
    return null;
  }

  //void elementAt(postIndex) {}
}
