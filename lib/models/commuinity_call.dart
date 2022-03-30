import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommuinityCall extends Equatable {
  final String? id;
  final String name;
  final List<String>? memberIds; // to know how many are active in call.
  final String channelId; // every channel needs an id in agora
  bool active;

  CommuinityCall(
      {this.id,
      required this.name,
      required this.memberIds,
      required this.channelId,
      required this.active,
    });

  @override
  List<Object?> get props => [id, name, memberIds, channelId, active];

  static CommuinityCall empty =
      CommuinityCall(name: 'null', memberIds: [], channelId: 'null', active: false);

  Map<String, dynamic> toDoc() {
    return {
      'name': name,
      'memberIds': memberIds,
      'channelId': channelId,
      'active': active,
    };
  }

  static CommuinityCall formDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommuinityCall(
        id: doc.id,
        name: data['name'],
        memberIds: List.from(data['memberIds'] ?? []), // when 3 strings are in call then it will activate. the temp, and two calers
        channelId: data['channelId'],
        active: data['active']
      );
  }
}
