//obj for array of recievers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class CallModel extends Equatable {
  //data for caller and recievers
  final String? id;
  final String name;
  final String? callerId;
  final String? callerUsername;
  final String? callerPicUrl;
  final Map<String, dynamic> memberInfo;
  final List<String> allMembersIds;
  final String channelId;
  bool hasDilled;

  CallModel({
    this.id,
    this.callerId,
    required this.name,
    this.callerUsername,
    this.callerPicUrl,
    required this.memberInfo,
    required this.allMembersIds,
    required this.channelId,
    required this.hasDilled,
  });

  @override
  List<Object?> get props => [
        id,
        callerId,
        name,
        callerUsername,
        allMembersIds,
        callerPicUrl,
        memberInfo,
        channelId,
        hasDilled
      ];

  static CallModel empty = CallModel(
    callerId: '',
    callerUsername: '',
    allMembersIds: [],
    name: 'This call may not exist',
    callerPicUrl: '',
    memberInfo: {},
    channelId: '',
    hasDilled: false,
  );

  CallModel copyWith({
    String? id,
    String? callerId,
    String? name,
    String? callerUsername,
    List<String>? allMembersIds,
    String? callerPicUrl,
    Map<String, dynamic>? memberInfo ,
    String? channelId,
    bool? hasDilled,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      name: name ?? this.name,
      allMembersIds: allMembersIds ?? this.allMembersIds,
      callerUsername: callerUsername ?? this.callerUsername,
      callerPicUrl: callerPicUrl ?? this.callerPicUrl,
      memberInfo: memberInfo ?? this.memberInfo,
      channelId: channelId ?? this.channelId,
      hasDilled: hasDilled ?? this.hasDilled,
    );
  }

  Map<String, dynamic> toMap({required CallModel call}) {
    return {
      'callerId': callerId,
      'callerUsername': callerUsername,
      'name': name,
      'callerPicUrl': callerPicUrl,
      'memberInfo': memberInfo,
      'allMembersIds': allMembersIds,
      'channelId': channelId,
      'hasDilled': hasDilled,
    };
  }

  Map<String, dynamic> toDoc() {
    return {
      'callerId': callerId,
      'callerUsername': callerUsername,
      'name': name,
      'callerPicUrl': callerPicUrl,
      'memberInfo': memberInfo,
      'allMembersIds': allMembersIds,
      'channelId': channelId,
      'hasDilled': hasDilled,
    };
  }

  Map<String, dynamic> ringToDoc() {
    return {
      'name': name,
      'callerUsername': callerUsername,
      'callerPicUrl': callerPicUrl,
      'channelId': channelId,
    };
  }
  static CallModel fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallModel(
      id: doc.id,
      callerId: data['callerId'] ?? null,
      name: data['name'] ?? null,
      callerUsername: data['callerUsername'] ?? null,
      callerPicUrl: data['callerPicUrl'] ?? null,
      allMembersIds: List<String>.from(data['allMembersIds'] ?? []),
      memberInfo: Map<String, dynamic>.from(data['memberInfo'] ?? {}),
      channelId: data['channelId'] ?? null,
      hasDilled: data['hasDilled'] ?? false,
    );
  }


}
