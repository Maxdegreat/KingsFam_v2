part of 'chatscreen_bloc.dart';

enum ChatStatus { initial, loading, sccuess, error }

class ChatscreenState extends Equatable {
  //1 make class data
  final List<Chat?> chat;
  final bool inAChat;
  final bool isToggle;
  final ChatStatus status;
  final Failure failure;
  //2 make the constructor
  const ChatscreenState({
    required this.chat,
    required this.inAChat,
    required this.isToggle,
    required this.status,
    required this.failure,
  });

  //5 make the init
  factory ChatscreenState.initial() {
    return ChatscreenState(
        chat: [],
        inAChat: false,
        isToggle: true,
        status: ChatStatus.initial,
        failure: Failure());
  }

  //3 make the props
  @override
  List<Object?> get props => [isToggle, chat, inAChat, status, failure];

  //4 gen the copy with
  ChatscreenState copyWith({
    List<Chat?>? chat,
    bool? inAChat,
    bool? isToggle,
    ChatStatus? status,
    Failure? failure,
  }) {
    return ChatscreenState(
      chat: chat ?? this.chat,
      isToggle: isToggle ?? this.isToggle,
      inAChat: inAChat ?? this.inAChat,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
