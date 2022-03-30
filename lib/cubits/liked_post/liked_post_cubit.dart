import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

part 'liked_post_state.dart';

class LikedPostCubit extends Cubit<LikedPostState> {
  
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;

  LikedPostCubit({
    required PostsRepository postsRepository,
    required AuthBloc authBloc,
  })  : _postsRepository = postsRepository,
        _authBloc = authBloc,
        super(LikedPostState.initial());
  
  // takes
  void updateLikedPosts({required Set<String> postIds}) {
    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..addAll(postIds)));
  }

  void likePost({required Post post}) {
    _postsRepository.createLike(post: post, userId: _authBloc.state.user!.uid);

    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..add(post.id!),
        recentlyLikedPostIds: Set<String>.from(state.likedPostsIds)..add(post.id!))
    );
  }

  void unLikePost({required Post post}) {
    _postsRepository.deleteLike(postId: post.id!, userId: _authBloc.state.user!.uid);

    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..remove(post.id!),
        recentlyLikedPostIds: Set<String>.from(state.likedPostsIds)
          ..remove(post.id!)));
  }

  void clearAllLikedPosts() {
    emit(LikedPostState.initial());
  }
}
