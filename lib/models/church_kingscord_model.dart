import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';

class KingsCord extends Equatable {
  //class data
  final String? id;
  final String cordName;
  final String mode;
  final String tag;
  final List<Userr>? members;
  final bool? readStatus;
  final Map<String, dynamic>? recentActivity;
  final Map<String, dynamic>? metaData;
  // final Map<String, dynamic> memberInfo;

  //make a constructor for fields
  KingsCord({
    this.id,
    required this.tag,
    required this.cordName,
    // required this.recentSender,
    this.members,
    required this.mode,
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
    List<Userr>? members,
    String? mode,
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
      members: members ?? this.members,
      mode: mode ?? this.mode,
      readStatus: readStatus ?? this.readStatus,
      recentActivity: recentActivity ?? this.recentActivity,
      metaData: metaData?? this.metaData,
      // memberInfo: memberInfo ?? this.memberInfo,
    );
  }

  static KingsCord empty = KingsCord(tag: 'tag', cordName: '', mode: Mode.chat);

  //make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'tag': tag,
      'cordName': cordName,
      // 'recentSender': recentSender,
      'mode': mode,
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
      mode: data['mode'],
      metaData: data['metaData'] ?? {},
    );
  }

  static Future<KingsCord?> fromDocAsync(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return KingsCord(
        id: doc.id,
        tag: data['tag'],
        cordName: data['cordName'] ?? 'MainRoom',
        mode: data['mode'],
        metaData: data['metaData'] ?? {}
    );
  }
}
