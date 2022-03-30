part of 'chatroom_cubit.dart';

enum ChatRoomStatus { inital, loading, success, failure }

class ChatroomState extends Equatable {
  //1 class data
  final bool isTyping;
  final String? textMesage;
  final File? chatImage;
  final ChatRoomStatus status;
  //2 gen constructor
  ChatroomState(
      {required this.isTyping,
      required this.chatImage,
      required this.status,
      required this.textMesage});

  //5 the init
  factory ChatroomState.initial() {
    return ChatroomState(
        textMesage: null,
        isTyping: false,
        chatImage: null,
        status: ChatRoomStatus.inital);
  }
//3 the props
  @override
  List<Object?> get props => [isTyping, textMesage, chatImage, status];

  //4 the copy with
  ChatroomState copyWith(
      {String? textMessage,
      bool? isTyping,
      File? chatImage,
      ChatRoomStatus? status}) {
    return ChatroomState(
      textMesage: textMesage ?? this.textMesage,
      isTyping: isTyping ?? this.isTyping,
      chatImage: chatImage ?? this.chatImage,
      status: status ?? this.status,
    );
  }
}
