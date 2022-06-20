part of 'kingscord_cubit.dart';

enum KingsCordStatus { initial, loading, sucess, failure }
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
  });
  // props
  List<Object?> get props =>
      [isTyping, txtImgUrl, txtMsg, msgs, txtVidUrl, status, fileShareStatus, filesToBePosted, failure];
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
        failure: Failure()
      );
  }


}
