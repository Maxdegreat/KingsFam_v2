part of 'says_cubit.dart';

enum SaysStatus {inital, error, pag, loading, success,}
class SaysState extends Equatable {
  // state properties
  final isTyping;
  final Failure failure;
  final List<Message?> msgs;
  final Message? replyMessage;
  final bool replying;
  final List<Userr> potentialMentions;
  final List<Userr> initPM;
  final List<Userr> mentions;
  final bool showHidden;
  final SaysStatus saysStatus;

  const SaysState({
    required this.isTyping,
    required this.failure,
    required this.msgs,
    required this.replyMessage,
    required this.replying,
    required this.potentialMentions,
    required this.initPM,
    required this.mentions,
    required this.showHidden,
    required this.saysStatus,
  });

  @override
  List<Object?> get props => [
        isTyping,
        failure,
        msgs,
        replyMessage,
        replying,
        potentialMentions,
        initPM,
        mentions,
        showHidden,
        saysStatus,
      ];

  SaysState copyWith({
    bool? isTyping,
    Failure? failure,
    List<Message?>? msgs,
    Message? replyMessage,
    bool? replying,
    List<Userr>? potentialMentions,
    List<Userr>? initPM,
    List<Userr>? mentions,
    bool? showHidden,
    SaysStatus? saysStatus,
  }) {
    return SaysState(
        isTyping: isTyping ?? this.isTyping,
        failure: failure ?? this.failure,
        msgs: msgs ?? this.msgs,
        replyMessage: replyMessage ?? this.replyMessage,
        replying: replying ?? this.replying,
        potentialMentions: potentialMentions ?? this.potentialMentions,
        initPM: initPM ?? this.initPM,
        mentions: mentions ?? this.mentions,
        showHidden: showHidden ?? this.showHidden,
        saysStatus: saysStatus ?? this.saysStatus,);
  }

  factory SaysState.inital() => SaysState(
      isTyping: false,
      failure: Failure(),
      msgs: [],
      replyMessage: null,
      replying: false,
      potentialMentions: [],
      initPM: [],
      mentions: [],
      showHidden: false,
      saysStatus: SaysStatus.inital);

}
