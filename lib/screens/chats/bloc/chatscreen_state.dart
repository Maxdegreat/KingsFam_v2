part of 'chatscreen_bloc.dart';

enum ChatStatus { initial, loading, sccuess, error }

enum FeedStatus_chats {inital, loading, success, paginating, error}

class ChatscreenState extends Equatable {
  //1 make class data
  final List<Chat?> chat;
  final bool inAChat;
  final bool isToggle;
  final ChatStatus status;
  final Failure failure;

  // ===== feed half =====

  final List<Post?>? posts;
  final FeedStatus_chats fstatus;
  final Set<String?> likedPostIds;

  //2 make the constructor
  const ChatscreenState({
    required this.chat,
    required this.inAChat,
    required this.isToggle,
    required this.status,
    required this.failure,
    //==== feed half ====
    required this.posts,
    required this.fstatus,
    required this.likedPostIds
  });

  //5 make the init
  factory ChatscreenState.initial() {
    return ChatscreenState(
        chat: [],
        inAChat: false,
        isToggle: true,
        status: ChatStatus.initial,
        failure: Failure(),
        posts: [], 
        likedPostIds: {}, 
        fstatus: FeedStatus_chats.inital,

    );
  }

  //3 make the props
  @override
  List<Object?> get props => [posts, likedPostIds,  fstatus, isToggle, chat, inAChat, status, failure];

  //4 gen the copy with
  ChatscreenState copyWith({
    List<Chat?>? chat,
    bool? inAChat,
    bool? isToggle,
    ChatStatus? status,
    List<Post?>? posts,
    Set<String?>? likedPostIds,
    FeedStatus_chats? fstatus,
    Failure? failure,

  }) {
    return ChatscreenState(
      posts: posts ?? this.posts,
      fstatus: fstatus ?? this.fstatus,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      chat: chat ?? this.chat,
      isToggle: isToggle ?? this.isToggle,
      inAChat: inAChat ?? this.inAChat,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
