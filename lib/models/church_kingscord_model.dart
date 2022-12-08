import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';

class KingsCord extends Equatable {
  //class data
  final String? id;
  final String tag;
  final String cordName;
  final List<Userr>? members;
  final String? mode;
  final String? rolesAllowed;
  final List<String>? subscribedIds;
  final bool? readStatus;
  // final Map<String, dynamic> memberInfo;

  //make a constructor for fields
  KingsCord({
    this.id,
    required this.subscribedIds,
    required this.tag,
    required this.cordName,
    // required this.recentSender,
    this.members,
    this.mode,
    this.rolesAllowed,
    this.readStatus,
  });
  
  //gen the props
  @override
  List<Object?> get props => [id, tag, cordName, members, mode, rolesAllowed, subscribedIds, readStatus];

  //gen the copy with
  KingsCord copyWith({
    String? id,
    String? tag,
    String? cordName,
    // List<String>? recentSender,
    Timestamp? recentTimestamp,
    List<String>? subscribedIds,
    List<Userr>? members,
    String? mode,
    String? rolesAllowed,
    bool? readStatus,
    // Map<String, dynamic>? memberInfo
  }) {
    return KingsCord(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      cordName: cordName ?? this.cordName,
      // recentSender: recentSender ?? this.recentSender,
      subscribedIds: subscribedIds ?? this.subscribedIds,
      members: members ?? this.members,
      mode: mode ?? "chat",
      rolesAllowed: rolesAllowed ?? Roles.Member,
      readStatus: readStatus ?? this.readStatus,
      // memberInfo: memberInfo ?? this.memberInfo,
    );
  }

  //make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'tag': tag,
      'cordName': cordName,
      // 'recentSender': recentSender,
      'subscribedIds' : subscribedIds ?? [],
      'mode': mode ?? 'chat',
      'rolesAllowed': rolesAllowed ?? Roles.Member,
      // members, get members from parent commuinity, this is if a user sends msg store only then that way
      // on leave it does not cause a null err on their msg
      // 'members': so null for now, I will add a func to do this.
    };
  }

  //make the from doc
  static KingsCord? fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        subscribedIds: List<String>.from(data['subscribedIds']) ?? [],
        mode: data['mode'] ?? 'chat',
        rolesAllowed: data['rolesAllowed'] ?? Roles.Member,
        );
  }

  static Future<KingsCord?> fromDocAsync(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        subscribedIds: List<String>.from(data['subscribedIds']) ?? [],
        mode: data['mode'] ?? 'chat',
        rolesAllowed: data['rolesAllowed'] ?? Roles.Member);
  }
}
