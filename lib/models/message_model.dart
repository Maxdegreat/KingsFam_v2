import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  //1 class data
  final String? id;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final Timestamp date;

//2 gen the constructor
  Message({
    this.id,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.date
  });

  //3  make the props
  List<Object?> get props => [
        id, //3 make the props
        senderId,
        text,
        imageUrl,
        date,
      ];

  // 4 make the copy with
  Message copyWith({
    String? id,
    String? senderId,
    String? text,
    String? imageUrl,
    Timestamp? date
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  // 5 make the to doc
  Map<String, dynamic> ToDoc() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'date': date 
    };
  }

  //6 make the fromDoc
  static Message fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? null,
      imageUrl: data['imageUrl'] ?? null,
      date: (data['date']),
      
    );
  }
}
