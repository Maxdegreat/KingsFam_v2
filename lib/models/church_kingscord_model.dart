import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';

class KingsCord extends Equatable {
  //class data
  final String? id;
  final String tag;
  final String cordName;
  final Timestamp recentTimestamp;
  final List<String> recentSender;
  final String recentMessage;
  final List<Userr>? members; // call this when opening the screen, get info from parent commuinity
  // final Map<String, dynamic> memberInfo;


  //make a constructor for fields
  KingsCord({
    this.id,
    required this.tag,
    required this.cordName,
    required this.recentTimestamp,
    required this.recentMessage,
    required this.recentSender,
    this.members,
  });
  //gen the props
  @override
  List<Object?> get props => [id, recentTimestamp, tag, cordName, recentMessage, members];

  //gen the copy with
  KingsCord copyWith(
      {String? id,
      String? tag,
      String? cordName,
      List<String>? recentSender,
      Timestamp? recentTimestamp,
      String? recentMessage,
      List<Userr>? members,
      // Map<String, dynamic>? memberInfo
  }) {
    return KingsCord(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      cordName: cordName ?? this.cordName,
      recentSender: recentSender ?? this.recentSender,
      recentTimestamp: recentTimestamp ?? this.recentTimestamp,
      recentMessage: recentMessage ?? this.recentMessage,
      members: members ?? this.members,
      // memberInfo: memberInfo ?? this.memberInfo,
    );
  }

  //make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'tag' : tag,
      'cordName' :  cordName,
      'recentSender': recentSender,
      'recentMessage': recentMessage,
      'recentTimestamp' : recentTimestamp
      // members, get members from parent commuinity, this is if a user sends msg store only then that way 
      // on leave it does not cause a null err on their msg
      // 'members': so null for now, I will add a func to do this.
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
        recentSender: List<String>.from(data['recentSender']), 
        recentTimestamp: data['recentTimestamp'],
      );
  }


  static Future<KingsCord?> fromDocAsync(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        recentMessage: data['recentMessage'],
        recentSender: List<String>.from(data['recentSender']), 
        recentTimestamp: data['recentTimestamp']
      );
  }
}
