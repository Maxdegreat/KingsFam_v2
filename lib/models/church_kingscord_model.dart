import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';

class KingsCord extends Equatable {
  //class data
  final String? id;
  final String cordName;
  final String mode;
  final String tag;
  final List<Userr>? members;
  final String? rolesAllowed;
  final List<String>? subscribedIds;
  final bool? readStatus;
  final Map<String, dynamic>? recentActivity;
  final Map<String, dynamic>? metaData;
  // final Map<String, dynamic> memberInfo;

  //make a constructor for fields
  KingsCord({
    this.id,
    this.subscribedIds,
    required this.tag,
    required this.cordName,
    // required this.recentSender,
    this.members,
    required this.mode,
    this.rolesAllowed,
    this.readStatus,
    this.recentActivity,
    this.metaData
  });

  //gen the props
  @override
  List<Object?> get props => [
        id,
        tag,
        cordName,
        members,
        mode,
        rolesAllowed,
        subscribedIds,
        readStatus,
        recentActivity,
        metaData,
      ];

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
    Map<String, dynamic>? recentActivity,
    Map<String, dynamic>? metaData,
    // Map<String, dynamic>? memberInfo
  }) {
    return KingsCord(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      cordName: cordName ?? this.cordName,
      // recentSender: recentSender ?? this.recentSender,
      subscribedIds: subscribedIds ?? this.subscribedIds,
      members: members ?? this.members,
      mode: mode ?? this.mode,
      rolesAllowed: rolesAllowed ?? Roles.Member,
      readStatus: readStatus ?? this.readStatus,
      recentActivity: recentActivity ?? this.recentActivity,
      metaData: metaData?? this.metaData,
      // memberInfo: memberInfo ?? this.memberInfo,
    );
  }

  //make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'tag': tag,
      'cordName': cordName,
      // 'recentSender': recentSender,
      'subscribedIds': subscribedIds ?? [],
      'mode': mode,
      'rolesAllowed': rolesAllowed ?? Roles.Member,
      "metaData": metaData
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
      mode: data['mode'],
      rolesAllowed: data['rolesAllowed'] ?? Roles.Member,
      metaData: data['metaData'] ?? {},
    );
  }

  static Future<KingsCord?> fromDocAsync(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        subscribedIds: List<String>.from(data['subscribedIds']) ?? [],
        mode: data['mode'],
        metaData: data['metaData'] ?? {},
        rolesAllowed: data['rolesAllowed'] ?? Roles.Member);
  }
}
