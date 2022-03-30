import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class Story extends Equatable {
  final String? id;
  final Userr author;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime date;

  Story(
      {this.id,
      required this.author,
      this.text,
      this.imageUrl,
      this.videoUrl,
      required this.date});

  @override
  List<Object?> get props => [id, author, text, imageUrl, videoUrl, date];

  Story copyWith({
    String? id,
    Userr? author,
    String? text,
    String? imageUrl,
    String? videoUrl,
    DateTime? date,
  }) {
    return Story(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'text': text,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'date': date,
    };
  }

  static Future<Story?> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference?;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return Story(
            id: doc.id,
            author: Userr.fromDoc(authorDoc),
            text: data['text'] ?? null,
            imageUrl: data['imageUrl'] ?? null,
            videoUrl: data['videoUrl'] ?? null,
            date: (data['date'] as Timestamp).toDate());
      }
    }
    return null;
  }
}
