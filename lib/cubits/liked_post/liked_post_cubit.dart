
 
import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

part 'liked_post_state.dart';

// logic for this cubit. I plan on basing the like display on this factor.
// if post.id not in liked posts OR not isLiked then display it as normal
// if post.id in recently liked posts OR isLiked (returns true, see below) then display a like

class LikedPostCubit extends Cubit<LikedPostState> {
  
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;

  LikedPostCubit({ required PostsRepository postsRepository, required AuthBloc authBloc})  
    : _postsRepository = postsRepository, _authBloc = authBloc,super(LikedPostState.initial());


  // will update our liked post display for this session
  void updateLikedPosts({required Set<String?> postIds}) {
    emit(state.copyWith(likedPostsIds: Set<String?>.from(state.likedPostsIds)..addAll(postIds)));
  }

  // This will update our liked post fo this session, and actualy make a new post.
  void likePost({required Post post}) {

    if (!state.likedPostsIds.contains(post.id)) {
        _postsRepository.createLike(post: post, userId: _authBloc.state.user!.uid);

      emit(state.copyWith(
          likedPostsIds: Set<String>.from(state.likedPostsIds)..add(post.id!),
          recentlyLikedPostIds: Set<String>.from(state.recentlyLikedPostIds)..add(post.id!)
      ));
    }
  }

  void unLikePost({required Post post}) {
    _postsRepository.deleteLike(postId: post.id!, userId: _authBloc.state.user!.uid);

    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..remove(post.id!),
        recentlyLikedPostIds: Set<String>.from(state.recentlyLikedPostIds)..remove(post.id!)
      ));
  }

  void clearAllLikedPosts() {
    emit(LikedPostState.initial());
  }
}
