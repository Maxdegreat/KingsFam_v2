import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

class Message {
  //1 class data
  final String? id;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final Timestamp date;
  final Userr? sender;
  final List<String>? mentionedIds;

//2 gen the constructor
  Message({
    this.id,
    this.sender, // do not call this in the to doc bc 
    this.text,
    this.imageUrl,
    this.videoUrl,
    this.mentionedIds,
    required this.date
  });

  //3  make the props
  List<Object?> get props => [
        id, //3 make the props
        sender,
        text,
        imageUrl,
        videoUrl,
        date,
        mentionedIds,
      ];

  // 4 make the copy with
  Message copyWith({
    String? id,
    Userr? sender,
    String? text,
    String? imageUrl,
    String? videoUrl,
    Timestamp? date,
    List<String>? mentionedIds,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      date: date ?? this.date,
      mentionedIds: mentionedIds ?? this.mentionedIds,
    );
  }

  factory Message.empty() {
    return Message(date: Timestamp.now(), sender: Userr.empty, text: '',);
  }

  // 5 make the to doc
  Map<String, dynamic> ToDoc({required String senderId}) {
    return {
      'sender': FirebaseFirestore.instance.collection(Paths.users).doc(senderId),
      'text': text,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'date': date, 
      'mentionedIds' : mentionedIds
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
      text: data['text'] ?? null,
      imageUrl: data['imageUrl'] ?? null,
      videoUrl: data['videoUrl'] ?? null,
      date: (data['date']),
      mentionedIds:  List<String>.from(data['mentionedIds'] ?? [])
      
    );
  }
}
