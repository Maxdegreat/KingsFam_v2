import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';

import 'package:kingsfam/models/user_model.dart';

class Comment extends Equatable {
  final String? id;
  final String postId;    //first declear the vars in the model
  final Userr author;
  final String content;
  final Timestamp date;

  Comment({
    this.id,                    //2nd make the constructor
    required this.postId,
    required this.author,
    required this.content,
    required this.date,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id, postId, author, content, date];     //3do the props

  Comment copyWith({
    String? id,
    String? postId,
    Userr? author,
    String? content,
    Timestamp? date,   //forth do the copy with
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'postId': postId,
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),  //5 do the copy with
      'content': content,
      'date': Timestamp.now()
    };
  }

  static Future<Comment?> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;                //5ith do factory or reference fac
    final authorRef = data['author'] as DocumentReference?;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return Comment(
            id: doc.id,
            postId: data['postId'] ?? '',
            author: Userr.fromDoc(authorDoc),
            content: data['content'] ?? '',
            date: (data['date'] as Timestamp));
      }
    }
    return null;
  }
}
