import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

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
  }) :_postsRepository = postsRepository, _authBloc = authBloc, super(CommentInital());
  
  @override
  Future<void> close() {
    _streamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<CommentState> mapEventToState(CommentEvent event) async* {
    yield CommentLoading();
    if (event is CommentFtechComments) {
      yield* _mapCommentFetchCommentsToState(event);
    } else if (event is CommentUpdateComments) {
      yield* _mapCommentUpdateComments(event);
    }  else if (event is CommentPostComment) {
      yield* _mapCommentPostComent(event);
    }
  }

  Stream<CommentState> _mapCommentFetchCommentsToState(CommentFtechComments event) async* {
    yield CommentLoading();
    try {
       _streamSubscription?.cancel();
       _streamSubscription = _postsRepository
        .getPostComments(postId: event.post!.id!)
        .listen((comments) async {
        final allComments = await Future.wait(comments);
        // log(allComments.toString());
        add(CommentUpdateComments(comments: allComments, post: event.post));
      });
    } catch (e) {
      yield CommentError(failure: Failure(message: "Hmmm, unable to load the comments", code: e.toString()));
    }
  }

  Stream<CommentState> _mapCommentUpdateComments(CommentUpdateComments event) async* {
      yield CommentLoaded(post: event.post, comments: event.comments);
    log(event.comments.length.toString());
  }

  Stream<CommentState> _mapCommentPostComent(CommentPostComment event) async* {
    try {
      //posts = List<Post?>.from(state.post)..addAll(event.post);
      
      final user = Userr.empty.copyWith(id: _authBloc.state.user!.uid);
      final comment = Comment(postId: event.post!.id!, author: user, content: event.content, date: Timestamp.now());
      _postsRepository.createComment(comment: comment, post: event.post!);
      List<Comment?> commentsList = List<Comment?>.from(event.comments)..insert(0, comment);
      yield CommentLoaded(post: event.post, comments: commentsList);
      
    } catch (e) {
    }
  }
  
}
