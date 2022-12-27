part of 'kingscord_cubit.dart';

enum KingsCordStatus { initial, loading, sucess, failure, getInitmsgs, pagMsgs }

enum FileShareStatus { inital, imgSharing, vidSharing, failure }

class KingscordState extends Equatable {
  // 1 class data
  final bool isTyping;
  final File? txtMsg;
  final File? txtImgUrl;
  final String? txtVidUrl;
  final KingsCordStatus status;
  final FileShareStatus fileShareStatus;
  final Failure failure;
  final List<Message?> msgs;
  final Queue<File> filesToBePosted;
  final String? replyMessage;
  final bool replying;
  final List<Userr> potentialMentions;
  final List<Userr> mentions;

  // used for sending notifications
  final List<String> recentNotifLst;
  final List<String> allNotifLst;
  final Map<String, dynamic> recentMsgIdToTokenMap;

  //gen constructor
  KingscordState({
    required this.isTyping,
    this.txtMsg,
    required this.msgs,
    this.txtImgUrl,
    this.txtVidUrl,
    required this.status,
    required this.fileShareStatus,
    required this.failure,
    required this.filesToBePosted,
    required this.replyMessage,
    required this.replying,
    required this.potentialMentions,
    required this.mentions,
    required this.recentNotifLst,
    required this.allNotifLst,
    required this.recentMsgIdToTokenMap,
  });
  // props
  List<Object?> get props => [
        isTyping,
        txtImgUrl,
        txtMsg,
        msgs,
        txtVidUrl,
        status,
        fileShareStatus,
        filesToBePosted,
        failure,
        replyMessage,
        replying,
        potentialMentions,
        mentions,
        recentNotifLst,
        allNotifLst,
        recentMsgIdToTokenMap,
      ];
  //copy with
  KingscordState copyWith({
    bool? isTyping,
    File? txtMsg,
    List<Message?>? msgs,
    File? txtImgUrl,
    String? txtVidUrl,
    KingsCordStatus? status,
    FileShareStatus? fileShareStatus,
    Queue<File>? filesToBePosted,
    Failure? failure,
    String? replyMessage,
    bool? replying,
    List<Userr>? potentialMentions,
    List<Userr>? mentions, // if mentions does not work add the final at front of line
    List<String>? recentNotifLst,
    List<String>? allNotifLst,
    Map<String, dynamic>? recentMsgIdToTokenMap,

  }) {
    return KingscordState(
      isTyping: isTyping ?? this.isTyping,
      txtMsg: txtMsg ?? this.txtMsg,
      msgs: msgs ?? this.msgs,
      txtImgUrl: txtImgUrl ?? this.txtImgUrl,
      txtVidUrl: txtVidUrl ?? this.txtVidUrl,
      status: status ?? this.status,
      fileShareStatus: fileShareStatus ?? this.fileShareStatus,
      failure: failure ?? this.failure,
      filesToBePosted: filesToBePosted ?? this.filesToBePosted,
      replying: replying ?? this.replying,
      replyMessage: replyMessage ?? this.replyMessage,
      potentialMentions: potentialMentions ?? this.potentialMentions,
      mentions: mentions ?? this.mentions,
      recentNotifLst: recentNotifLst ?? this.recentNotifLst,
      allNotifLst: allNotifLst ?? this.allNotifLst,
      recentMsgIdToTokenMap: recentMsgIdToTokenMap ?? this.recentMsgIdToTokenMap,
    );
  }

  //make the init phase
  factory KingscordState.initial() {
    return KingscordState(
      isTyping: false,
      txtMsg: null,
      msgs: [],
      txtImgUrl: null,
      txtVidUrl: null,
      status: KingsCordStatus.initial,
      fileShareStatus: FileShareStatus.inital,
      filesToBePosted: Queue<File>(),
      failure: Failure(),
      replyMessage: null,
      replying: true,
      potentialMentions: [],
      mentions: [],
      recentNotifLst: [],
      allNotifLst: [],
      recentMsgIdToTokenMap: {},
    );
  }
}
