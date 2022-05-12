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
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;

  StreamSubscription<List<Future<Comment?>>>? _commentSubscription;

  CommentBloc({
    required PostsRepository postsRepository,
    required AuthBloc authBloc,
  }) : _authBloc = authBloc, _postsRepository = postsRepository,
      super(CommentState.inital());
  @override
  Future<void> close() {
    _commentSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<CommentState> mapEventToState(CommentEvent event) async* {
    if (event is CommentFetchComments) {
      yield* _mapCommentFetchCommentToState(event);
    } else if (event is CommentUpdateComments) {
      yield* _mapCommentUpdateCommentsToState(event);
    } else if (event is CommentPostComment) {
      yield* _mapCommentPostCommentsToState(event);
    }
  }

  // stream<state> to states below +++++++++++++++++++++++++++++++++++++

  Stream<CommentState> _mapCommentFetchCommentToState(CommentFetchComments event) async* {
    log(state.copyWith().toString());
    yield state.copyWith(status: CommentStatus.loading);
    try {
     _commentSubscription?.cancel();
     _commentSubscription = _postsRepository
       .getPostComments(postId: event.post!.id!)
       .listen((comments) async {
         final allComments = await Future.wait(comments);
         add(CommentUpdateComments(comments: allComments));
       });
    log(state.copyWith().toString());
    log("============================================================================");
    log( event.post!.id.toString());
    yield state.copyWith(post: event.post!, status: CommentStatus.loaded);
    yield state.copyWith(post: event.post!, status: CommentStatus.loaded);

    log(state.copyWith().toString());

    // event.post == null ? log("null") : log(event.post!.toString());
    } catch (err) {
      yield state.copyWith(
        status: CommentStatus.error,
        failure:  Failure(
          message: 'uhhh fam we were unable to load this post\'s comments.',
        ),
      );
    }
  }

  Stream<CommentState> _mapCommentUpdateCommentsToState(CommentUpdateComments event) async* {
    yield state.copyWith(comments: state.comments);
  }

  Stream<CommentState>  _mapCommentPostCommentsToState(CommentPostComment event) async* {
    yield state.copyWith(status: CommentStatus.submitting);
    try {
      log("in comment post comment");
      log("post is ${state.post}");
      final author = Userr.empty.copyWith(id: _authBloc.state.user!.uid);
      final comment = Comment(
        author: author, 
        postId: state.post.id!,
        content: event.content,
        date: Timestamp.now(),
      );
      log("awaiting the post repo");
      await _postsRepository.createComment(comment: comment, post: state.post);
      yield state.copyWith(status: CommentStatus.loaded);
    } catch (err) {
      yield state.copyWith(
        status: CommentStatus.error,
        failure: Failure(
          message: 'Comment post was a miss :/'
        )
      );
    }
  }

}
