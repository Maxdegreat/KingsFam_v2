import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/chat/chat_repository.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final ChurchRepository _churchRepository;
  // ignore: unused_field
  final ChatRepository _chatRepository;
  StreamSubscription<List<Future<Message?>>>? _msgStreamSubscription;
  MessageBloc({
    required ChurchRepository churchRepository,
    required ChatRepository chatRepository,
  }) : _churchRepository = churchRepository,
       _chatRepository = chatRepository,
       super(MessageState.inital());

  @override
  Future<void> close() {
    _msgStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<MessageState> mapEventToState(MessageEvent event) async* {
    if (event is MessageSentEvent) {
      yield* _mapMessageToState(event);
    }
  }

  Stream<MessageState> _mapMessageToState(MessageSentEvent event) async* {
    int limit = 20;
    _msgStreamSubscription?.cancel();
    _msgStreamSubscription = _churchRepository.
     getMsgStream(cmId: event.cmId, kcId: event.kcId, limit: limit, lastPostDoc: null)
     .listen((msgs) async { 
       final allMsgs = await Future.wait(msgs);
       // ignore: invalid_use_of_visible_for_testing_member
       emit(state.copyWith(msg: allMsgs));
     });
  }
  
}
