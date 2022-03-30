import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/chat/chat_repository.dart';

part 'chatscreen_event.dart';
part 'chatscreen_state.dart';

class ChatscreenBloc extends Bloc<ChatscreenEvent, ChatscreenState> {
  final ChatRepository _chatRepository;
  final AuthBloc _authBloc;

  StreamSubscription<List<Future<Chat?>>>? _chatsStreamSubscription;

  ChatscreenBloc({
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
  })  : _chatRepository = chatRepository,
        _authBloc = authBloc,
        super(ChatscreenState.initial());

  @override
  Future<void> close() {
    _chatsStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<ChatscreenState> mapEventToState(
    ChatscreenEvent event,
  ) async* {
    if (event is LoadChats) {
      yield* _mapLoadChatsToState(event);
    } else if (event is HomeToggleScreen) {
      yield* _mapHomeToggleScreen(event);
    }
  }

  Stream<ChatscreenState> _mapHomeToggleScreen(HomeToggleScreen event) async* {
    yield state.copyWith(isToggle: event.isScreen);
  }

  Stream<ChatscreenState> _mapLoadChatsToState(event) async* {
    try {
      state.copyWith(status: ChatStatus.loading);

      _chatsStreamSubscription?.cancel();

      _chatsStreamSubscription = _chatRepository
          .getUserChats(userId: _authBloc.state.user!.uid)
          .listen((chat) async {
        final allChats = await Future.wait(chat);
        state.copyWith(chat: allChats);
      });
      state.copyWith(status: ChatStatus.sccuess);
    } catch (e) {
      state.copyWith(
          failure: Failure(
              message: 'error loading your chats, check ur connection fam'));
    }
  }
}
