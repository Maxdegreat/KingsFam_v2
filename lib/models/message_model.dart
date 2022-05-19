import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';

class Message {
  //1 class data
  final String? id;
  final String? text;
  final String? imageUrl;
  final Timestamp date;
  final Userr? sender;

//2 gen the constructor
  Message({
    this.id,
    this.sender, // do not call this in the to doc bc 
    this.text,
    this.imageUrl,
    required this.date
  });

  //3  make the props
  List<Object?> get props => [
        id, //3 make the props
        sender,
        text,
        imageUrl,
        date,
      ];

  // 4 make the copy with
  Message copyWith({
    String? id,
    Userr? sender,
    String? text,
    String? imageUrl,
    Timestamp? date
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  factory Message.empty() {
    return Message(date: Timestamp.now(), sender: Userr.empty, text: '', imageUrl: null,);
  }

  // 5 make the to doc
  Map<String, dynamic> ToDoc({required String senderId}) {
    return {
      'sender': FirebaseFirestore.instance.collection(Paths.users).doc(senderId),
      'text': text,
      'imageUrl': imageUrl,
      'date': date 
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
      date: (data['date']),
      
    );
  }
}
