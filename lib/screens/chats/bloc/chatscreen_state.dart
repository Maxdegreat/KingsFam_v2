part of 'chatscreen_bloc.dart';

enum ChatStatus { initial, loading, sccuess, error }

enum FeedStatus_chats { inital, loading, success, paginating, error }

class ChatscreenState extends Equatable {
  //1 make class data
  final List<Chat?> chat;
  final Userr currUserr;
  final List<Church?> chs;
  final List<Church> chsToJoin;
  final Map<String, dynamic> mentionedMap;
  final StreamingSharedPreferences? preferences;
  final bool inAChat;
  final bool isToggle;
  final ChatStatus status;
  final Failure failure;

  // ===== feed half =====

  final List<Post?> posts;
  final FeedStatus_chats fstatus;
  final Set<String?> likedPostIds;

  //2 make the constructor
  const ChatscreenState(
      {required this.chat,
      required this.currUserr,
      required this.chs,
      required this.chsToJoin,
      required this.inAChat,
      required this.isToggle,
      required this.status,
      required this.mentionedMap,
      required this.failure,
      required this.preferences,
      //==== feed half ====
      required this.posts,
      required this.fstatus,
      required this.likedPostIds});

  //5 make the init
  factory ChatscreenState.initial() {
    return ChatscreenState(
      chat: [],
      chs: [],
      chsToJoin: [],
      inAChat: false,
      isToggle: true,
      mentionedMap: {},
      currUserr: Userr.empty,
      status: ChatStatus.initial,
      preferences: null,
      failure: Failure(),
      posts: [],
      likedPostIds: {},
      fstatus: FeedStatus_chats.inital,
    );
  }

  //3 make the props
  @override
  List<Object?> get props => [
        posts,
        preferences,
        currUserr,
        likedPostIds,
        mentionedMap,
        fstatus,
        isToggle,
        chat,
        chs,
        chsToJoin,
        inAChat,
        status,
        failure
      ];

  //4 gen the copy with
  ChatscreenState copyWith({
    List<Chat?>? chat,
    bool? inAChat,
    bool? isToggle,
    Userr? currUserr,
    List<Church?>? chs,
    List<Church>? chsToJoin,
    ChatStatus? status,
    List<Post?>? posts,
    Set<String?>? likedPostIds,
    Map<String, dynamic>? mentionedMap,
    StreamingSharedPreferences? preferences,
    FeedStatus_chats? fstatus,
    Failure? failure,
  }) {
    return ChatscreenState(
      posts: posts ?? this.posts,
      currUserr: currUserr ?? this.currUserr,
      chs: chs ?? this.chs,
      chsToJoin: chsToJoin ?? this.chsToJoin,
      fstatus: fstatus ?? this.fstatus,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      chat: chat ?? this.chat,
      mentionedMap: mentionedMap ?? this.mentionedMap,
      isToggle: isToggle ?? this.isToggle,
      preferences: preferences ?? preferences,
      inAChat: inAChat ?? this.inAChat,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
