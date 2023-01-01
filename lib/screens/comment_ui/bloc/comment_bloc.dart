import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:uuid/uuid.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  // ignore: unused_field
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;
  StreamSubscription<List<Future<Comment?>>>? _streamSubscription;

  CommentBloc({
    required PostsRepository postsRepository,
    required AuthBloc authBloc,
  })  : _postsRepository = postsRepository,
        _authBloc = authBloc,
        super(CommentState.inital());

  @override
  Future<void> close() {
    _streamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<CommentState> mapEventToState(CommentEvent event) async* {
    if (event is CommentFtechComments) {
      yield* _mapCommentFetchCommentsToState(event);
    } else if (event is CommentUpdateComments) {
      yield* _mapCommentUpdateComments(event);
    } else if (event is CommentPostComment) {
      yield* _mapCommentPostComent(event);
    }
  }

  Stream<CommentState> _mapCommentFetchCommentsToState(
      CommentFtechComments event) async* {
    yield state.CopyWith(status: CommentStatus.loading);
    try {
      _streamSubscription?.cancel();
      _streamSubscription = _postsRepository
          .getPostComments(postId: event.post!.id!)
          .listen((comments) async {
        final allComments = await Future.wait(comments);
        add(CommentUpdateComments(comments: allComments, post: event.post));
      });
      yield state.CopyWith(status: CommentStatus.success);
    } catch (e) {
      yield state.CopyWith(
          failure: Failure(
              message: "Hmmm, unable to load the comments",
              code: e.toString()));
    }
  }

  Stream<CommentState> _mapCommentUpdateComments(
      CommentUpdateComments event) async* {
    yield state.CopyWith(post: event.post, comments: event.comments);
  }

  Stream<CommentState> _mapCommentPostComent(CommentPostComment event) async* {
    try {
      //posts = List<Post?>.from(state.post)..addAll(event.post);

      final user = Userr.empty.copyWith(id: _authBloc.state.user!.uid);
      final comment = Comment(
          postId: event.post!.id!,
          author: user,
          content: event.content,
          date: Timestamp.now(),
          highId: null,
      );
      _postsRepository.createComment(comment: comment, post: event.post!);
      List<Comment> commentsList = List<Comment>.from(state.comments)
        ..insert(0, comment);
      yield state.CopyWith(comments: commentsList, post: event.post);
    } catch (e) {}
  }

  void onAddReply(
      {required Comment comment,
      required Post post,
      required String content}) {

    emit(state.CopyWith(status: CommentStatus.loading));
    _postsRepository.onAddReply(comment: comment, post: post, content: content).then((value) {
      onViewReplys(comment, post.id!);
      emit(state.CopyWith(status: CommentStatus.success));
    } );
    
  }

  void onReply() {
    emit(state.CopyWith(isReplys: true));
  }

  Future<void> onViewReplys(Comment comment, String postId) async {
    emit(state.CopyWith(status: CommentStatus.loading));
    String? lastCommentId;
    if (state.replys[comment.id] != null &&
        state.replys[comment.id]!.length > 0) {
      lastCommentId = state.replys[comment.id]!.last!.id;
    }
    // get list of replyed post
    final replys = await _postsRepository.getCommentReplys(
        comment, postId, lastCommentId);
    // make the map w/ the replys
    if (state.replys[comment.id] != null) {
      state.replys[comment.id]!.addAll(replys);
      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.CopyWith(replys: state.replys));
    } else {
      state.replys[comment.id!] = replys;
      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.CopyWith(replys: state.replys));
    }
    await Future.delayed(Duration(milliseconds: 500));
    emit(state.CopyWith(status: CommentStatus.success));
  }
}
