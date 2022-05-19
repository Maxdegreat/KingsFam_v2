part of 'message_bloc.dart';

class MessageState extends Equatable {
  final List<Message?> msg;
  const MessageState({
    required this.msg,
  });
  
  @override
  List<Object?> get props => [msg];

  factory MessageState.inital() {
    return MessageState(msg: []);
  }

  MessageState copyWith({
    List<Message?>? msg,
  }) {
    return MessageState(
      msg: msg ?? this.msg,
    );
  }
}

