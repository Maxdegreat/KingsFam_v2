import 'package:cloud_firestore/cloud_firestore.dart';

class Mentioned {
  final String? id;
  final String communityName;
  final String messageBody;
  final String username;
  final List<String> token;

  Mentioned({
    this.id,
    required this.communityName,
    required this.messageBody,
    required this.token,
    required this.username,
  });

  Mentioned copyWith({
    String? id,
    String? communityName,
    String? messageBody,
    String? username,
    List<String>? token,
  }) {
    return Mentioned(
      id: id ?? this.id,
      communityName: communityName ?? this.communityName,
      messageBody: messageBody ?? this.messageBody,
      username: username ?? this.username,
      token: token ?? this.token,
    );
  }

  static Mentioned fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mentioned(
        communityName: data['communityName'] ?? null,
        messageBody: data['messageBody'] ?? null,
        token: List<String>.from(data['token'] ?? null),
        username: data['username'] ?? null);
  }
}
