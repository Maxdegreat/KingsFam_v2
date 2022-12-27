import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

class Message {
  //1 class data
  final String? id;
  final String? text;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? videoUrl;
  final Timestamp date;
  final Userr? sender;
  final String? senderUsername;
  final List<String>? mentionedIds;
  final Map<String, int>? reactions;
  final String? reply; 

//2 gen the constructor
  Message({
    this.id,
    this.sender, // do not call this in the to doc bc 
    this.senderUsername,
    this.text,
    this.imageUrl,
    this.thumbnailUrl,
    this.videoUrl,
    this.mentionedIds,
    required this.date,
    this.reactions,
    this.reply,
  });

  //3  make the props
  List<Object?> get props => [
        id, //3 make the props
        sender,
        senderUsername,
        text,
        imageUrl,
        thumbnailUrl,
        videoUrl,
        date,
        mentionedIds,
        reactions,
        reply,
      ];

  // 4 make the copy with
  Message copyWith({
    String? id,
    Userr? sender,
    String? senderUsername,
    String? text,
    String? imageUrl,
    String? thumbnailUrl,
    String? videoUrl,
    Timestamp? date,
    List<String>? mentionedIds,
    Map<String, int>? reactions,
    String? reply,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderUsername: senderUsername ?? this.senderUsername,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      date: date ?? this.date,
      mentionedIds: mentionedIds ?? this.mentionedIds,
      reply: reply ?? this.reply,
    );
  }

  factory Message.empty() {
    return Message(date: Timestamp.now(), sender: Userr.empty, text: '',);
  }

  // 5 make the to doc
  Map<String, dynamic> ToDoc({required String senderId}) {
    return {
      'sender': FirebaseFirestore.instance.collection(Paths.users).doc(senderId),
      'senderUsername': senderUsername,
      'text': text,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'date': date, 
      'mentionedIds' : mentionedIds,
      'reactions' : {},
      'reply' : reply, // This should be a string where the value is the ID of the og message.
    };
  }

  //6 make the fromDoc
  static Future<Message> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    Userr? user;
    DocumentReference? userRef = data['sender'] as DocumentReference;
    var docSnap = await userRef.get();
    user = Userr.fromDoc(docSnap);
    
    return Message(
      id: doc.id,
      sender: user,
      senderUsername: data['senderUsername'] ?? null,
      text: data['text'] ?? null,
      imageUrl: data['imageUrl'] ?? null,
      thumbnailUrl: data['thumbnailUrl'] ?? null,
      videoUrl: data['videoUrl'] ?? null,
      date: (data['date']),
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
      mentionedIds:  List<String>.from(data['mentionedIds'] ?? []),
      reply: data['reply'] ?? null,
      
    );
  }
}
