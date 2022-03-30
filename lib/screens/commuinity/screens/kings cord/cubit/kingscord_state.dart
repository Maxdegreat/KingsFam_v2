part of 'kingscord_cubit.dart';

enum KingsCordStatus { initial, loading, sucess, failure }

class KingscordState extends Equatable {
  // 1 class data
  final bool isTyping;
  final File? txtMsg;
  final File? txtImgUrl;
  final String? txtVidUrl;
  final KingsCordStatus status;
  final Failure failure;
  //gen constructor
  KingscordState({
    required this.isTyping,
    this.txtMsg,
    this.txtImgUrl,
    this.txtVidUrl,
    required this.status,
    required this.failure,
  });
  // props
  List<Object?> get props =>
      [isTyping, txtImgUrl, txtMsg, txtVidUrl, status, failure];
  //copy with
    KingscordState copyWith({
      bool? isTyping,
      File? txtMsg,
      File? txtImgUrl,
      String? txtVidUrl,
      KingsCordStatus? status,
      Failure? failure,
    }) {
      return KingscordState(
        isTyping: isTyping ?? this.isTyping,
        txtMsg: txtMsg ?? this.txtMsg,
        txtImgUrl: txtImgUrl ?? this.txtImgUrl,
        txtVidUrl: txtVidUrl ?? this.txtVidUrl,
        status: status ?? this.status,
        failure: failure ?? this.failure,
      );
    }
  //make the init phase
  factory KingscordState.initial() {
    return KingscordState(
        isTyping: false,
        txtMsg: null,
        txtImgUrl: null,
        txtVidUrl: null,
        status: KingsCordStatus.initial,
        failure: Failure());
  }


}
