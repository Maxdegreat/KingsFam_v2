import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class KingsCord extends Equatable {
  //class data
  final String? id;
  final String tag;
  final String? cordName;
  final String recentSender;
  final String recentMessage;
  final List<String> memberIds;
  final Map<String, dynamic> memberInfo;


  //make a constructor for fields
  KingsCord({
    this.id,
    required this.tag,
    this.cordName,
    required this.memberInfo,
    required this.recentMessage,
    required this.recentSender,
    required this.memberIds,
  });
  //gen the props
  @override
  List<Object?> get props => [id, tag, cordName, recentMessage, recentMessage, memberIds];

  //gen the copy with
  KingsCord copyWith(
      {String? id,
      String? tag,
      String? cordName,
      String? recentSender,
      String? recentMessage,
      List<String>? memberIds,
      Map<String, dynamic>? memberInfo}) {
    return KingsCord(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      cordName: cordName ?? this.cordName,
      recentSender: recentSender ?? this.recentSender,
      recentMessage: recentMessage ?? this.recentMessage,
      memberIds: memberIds ?? this.memberIds,
      memberInfo: memberInfo ?? this.memberInfo,
    );
  }

  //make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'tag' : tag,
      'cordName' : cordName,
      'recentSender': recentSender,
      'recentMessage': recentMessage,
      'memberIds': memberIds,
      'memberInfo' : memberInfo, 
    };
  }

  //make the from doc
  static KingsCord? fromDoc(DocumentSnapshot doc)  {
    final data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        recentMessage: data['recentMessage'],
        recentSender: data['recentSender'],
        memberIds: List<String>.from(data['memberIds'] ?? []),
        memberInfo: Map<String, dynamic>.from(data['memberInfo'] ?? {} 
      ));
  }
}
