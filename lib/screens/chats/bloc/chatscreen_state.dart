part of 'chatscreen_bloc.dart';

enum ChatStatus { initial, loading, sccuess, error, setState, setStateKc }

enum FeedStatus_chats { inital, loading, success, paginating, error }

class ChatscreenState extends Equatable {
  //1 make class data
  final List<Chat?> chat;
  final List<Church?>? chs;
  final Church? selectedCh;
  final KingsCord? selectedKc;
  final Church pSelectedCh;
  final List<Church> chsToJoin;
  final Map<String, dynamic> mentionedMap;
  final bool inAChat;
  final bool isToggle;
  final ChatStatus status;
  final Failure failure;
  final bool unreadChats;

  // ===== feed half =====

  final List<Post?> posts;
  final FeedStatus_chats fstatus;
  final Set<String?> likedPostIds;

  //2 make the constructor
  const ChatscreenState({
    required this.chat,
    required this.chs,
    required this.selectedCh,
    required this.selectedKc,
    required this.pSelectedCh,
    required this.chsToJoin,
    required this.inAChat,
    required this.isToggle,
    required this.status,
    required this.mentionedMap,
    required this.failure,
    required this.unreadChats,
    //==== feed half ====
    required this.posts,
    required this.fstatus,
    required this.likedPostIds,
  });

  //5 make the init
  factory ChatscreenState.initial() {
    return ChatscreenState(
      chat: [],
      chs: null,
      chsToJoin: [],
      inAChat: false,
      isToggle: true,
      mentionedMap: {},
      selectedCh: null,
      selectedKc: null,
      pSelectedCh: Church.empty,
      status: ChatStatus.initial,
      failure: Failure(),
      posts: [],
      likedPostIds: {},
      fstatus: FeedStatus_chats.inital,
      unreadChats: false,
    );
  }

  //3 make the props
  @override
  List<Object?> get props => [
        posts,
        likedPostIds,
        mentionedMap,
        fstatus,
        isToggle,
        chat,
        chs,
        selectedCh,
        selectedKc,
        pSelectedCh,
        chsToJoin,
        inAChat,
        status,
        failure,
        unreadChats,
      ];

  //4 gen the copy with
  ChatscreenState copyWith({
    List<Chat?>? chat,
    bool? inAChat,
    bool? isToggle,
    List<Church?>? chs,
    Church? selectedCh,
    KingsCord? selectedKc,
    Church? pSelectedCh,
    List<Church>? chsToJoin,
    ChatStatus? status,
    List<Post?>? posts,
    Set<String?>? likedPostIds,
    Map<String, dynamic>? mentionedMap,
    FeedStatus_chats? fstatus,
    Failure? failure,
    bool? unreadChats,
  }) {
    return ChatscreenState(
      posts: posts ?? this.posts,
      chs: chs ?? this.chs,
      selectedCh: selectedCh ?? this.selectedCh,
      selectedKc: selectedKc ?? this.selectedKc,
      pSelectedCh: pSelectedCh ?? this.pSelectedCh,
      chsToJoin: chsToJoin ?? this.chsToJoin,
      fstatus: fstatus ?? this.fstatus,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      chat: chat ?? this.chat,
      mentionedMap: mentionedMap ?? this.mentionedMap,
      isToggle: isToggle ?? this.isToggle,
      inAChat: inAChat ?? this.inAChat,
      status: status ?? this.status,
      failure: failure ?? this.failure,
      unreadChats: unreadChats ?? this.unreadChats,
    );
  }
}
