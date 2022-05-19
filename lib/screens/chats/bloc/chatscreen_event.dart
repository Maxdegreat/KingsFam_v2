part of 'chatscreen_bloc.dart';

abstract class ChatscreenEvent extends Equatable {
  const ChatscreenEvent();

  @override
  List<Object> get props => [];
}

class HomeToggleScreen extends ChatscreenEvent {
  final bool isScreen;
  HomeToggleScreen({required this.isScreen});
  List<Object> get props => [isScreen];
}

class LoadChats extends ChatscreenEvent {
  final String chatId;
  LoadChats({
    required this.chatId,
  });
}

class LoadCms extends ChatscreenEvent {
}

class ChatScreenFetchPosts extends ChatscreenEvent {}


class ChatScreenPaginatePosts extends ChatscreenEvent{}
