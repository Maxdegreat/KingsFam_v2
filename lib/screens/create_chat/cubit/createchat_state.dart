part of 'createchat_cubit.dart';

enum CreateChatStatus { initial, loading, success, error }

class CreatechatState extends Equatable {
  //1 make the class data
  final Chat chat;
  final File? chatAvatar;
  final String name;
  final String recentSender;
  final List<String> memberIds;
  final Map<String, dynamic> memberInfo;
  final Map<String, dynamic> readStatus;
  final List<String> usersList;
  final List<String> caseSearch;
  final CreateChatStatus status;
  final Failure failure;

  //5 make the init
  factory CreatechatState.initial() {
    return CreatechatState(
        chat: Chat.empty,
        chatAvatar: null,
        name: '',
        caseSearch: [],
        memberIds: [],
        recentSender: '',
        memberInfo: {},
        readStatus: {},
        usersList: [],
        
        failure: Failure(),
        status: CreateChatStatus.initial);
  }

  //2 gen the constructor
  const CreatechatState({
    required this.chat,
    required this.chatAvatar,
    required this.recentSender,
    required this.name,
    required this.memberIds,
    required this.memberInfo,
    required this.readStatus,
    required this.usersList,
    required this.caseSearch,
    required this.status,
    required this.failure,
  });
  //3 make the props
  @override
  List<Object?> get props => [
        chat,
        chatAvatar,
        name,
        recentSender,
        memberIds,
        memberInfo,
        readStatus,
        usersList,
        caseSearch,
        status,
        failure
      ];

  //4 gen copy with

  CreatechatState copyWith({
    Chat? chat,
    File? chatAvatar,
    String? name,
    String? recentSender,
    List<String>? memberIds,
    Map<String, dynamic>? memberInfo,
    Map<String, dynamic>? readStatus,
    List<String>? usersList,
    List<String>? caseSearch,
    CreateChatStatus? status,
    Failure? failure,
  }) {
    return CreatechatState(
      chat: chat ?? this.chat,
      chatAvatar: chatAvatar ?? this.chatAvatar,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      memberInfo: memberInfo ?? this.memberInfo,
      recentSender: recentSender ?? this.recentSender,
      readStatus: readStatus ?? this.readStatus,
      usersList: usersList ?? this.usersList,
      caseSearch: caseSearch ?? this.caseSearch,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
