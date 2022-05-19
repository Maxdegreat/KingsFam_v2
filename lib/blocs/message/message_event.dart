part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class MessageSentEvent extends MessageEvent {
  final Message? msg;
  final String cmId;
  final String kcId;
  MessageSentEvent({required this.msg, required this.cmId, required this.kcId});
  @override
  List<Object?> get props => [msg];
}