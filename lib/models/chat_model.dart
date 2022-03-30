import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String? id; //1 make the class data
  final String name;
  final String imageUrl;
  final String recentSender;
  final String recentMessage;
  final List<String> searchPram;
  //final Map<String, dynamic> chatTheme;
  final DateTime date;
  final List<String> memberIds;
  final Map<String, dynamic> memberInfo;
  final Map<String, dynamic> readStatus;

  Chat({
    this.id,
    required this.name,
    required this.recentMessage,
    required this.searchPram,
    required this.imageUrl,
    required this.recentSender, //2 gen the constructor
    required this.date,
    required this.memberIds,
    required this.memberInfo,
    required this.readStatus,
  });

  static Chat empty = Chat(
      name: '',
      imageUrl: '',
      recentMessage: '',
      searchPram: [],
      recentSender: '',
      date: DateTime.now(),
      memberIds: [],
      memberInfo: {},
      readStatus: {});

  @override
  List<Object?> get props => [
        id, //3 make the props
        name,
        recentMessage,
        imageUrl,
        recentSender,
        date,
        searchPram,
        memberIds,
        memberInfo,
        readStatus
      ];

  Chat copyWith({
    String? id, //4 do the copy with
    String? name,
    String? imageUrl,
    String? recentSender,
    String? recentMessage,
    List<String>? searchPram,
    DateTime? date,
    List<String>? memberIds,
    Map<String, dynamic>? memberInfo,
    Map<String, dynamic>? readStatus,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      recentSender: recentSender ?? this.recentSender,
      date: date ?? this.date,
      searchPram: searchPram ?? this.searchPram,
      recentMessage: recentMessage ?? this.recentMessage,
      memberIds: memberIds ?? this.memberIds,
      memberInfo: memberInfo ?? this.memberInfo,
      readStatus: readStatus ?? this.readStatus,
    );
  }

  // 5 make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'recentSender': recentSender,
      'recentMessage': recentMessage,
      'searchPram': searchPram,
      'date': date,
      'memberIds': memberIds,
      'memberInfo': memberInfo,
      'readStatus': readStatus
    };
  }

  //6 from doc
  static Chat fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
        id: doc.id,
        searchPram: List<String>.from(data['searchPram'] ?? []),
        name: data['name'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        recentSender: data['recentSender'] ?? '',
        recentMessage: data['recentMessage'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        memberIds: List<String>.from(data['memberIds'] ?? []),
        memberInfo: Map<String, dynamic>.from(data['memberInfo'] ?? {}),
        readStatus: Map<String, dynamic>.from(data['readStatus'] ?? {}));
  }

  //extra from doc for cgat repository
  static Future<Chat> fromDocAsync(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
        id: doc.id,
        name: data['name'] ?? '',
        searchPram: List<String>.from(data['searchPram'] ?? []),
        imageUrl: data['imageUrl'] ?? '',
        recentSender: data['recentSender'] ?? '',
        recentMessage: data['recentMessage'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        memberIds: List<String>.from(data['memberIds'] ?? []),
        memberInfo: Map<String, dynamic>.from(data['memberInfo'] ?? {}),
        readStatus: Map<String, dynamic>.from(data['readStatus'] ?? {}));
  }
}
