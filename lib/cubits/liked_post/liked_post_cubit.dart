
 
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
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
  
   // check to see if our ID is in the posts likes, if so display ui as such.
   void isLiked({required Post post }) async {
     var likeExist = await FirebaseFirestore.instance.collection(Paths.likes).doc(post.id).collection(Paths.postLikes).doc(_authBloc.state.user!.uid).get();
     emit(state.copyWith(isLiked: likeExist.exists));
   }


  // will update our liked post display for this session
  void updateLikedPosts({required Set<String?> postIds}) {
    emit(state.copyWith(likedPostsIds: Set<String?>.from(state.likedPostsIds)..addAll(postIds)));
  }

  // This will update our liked post fo this session, and actualy make a new post.
  void likePost({required Post post}) {
    _postsRepository.createLike(post: post, userId: _authBloc.state.user!.uid);

    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..add(post.id!),
        // recentlyLikedPostIds: Set<String>.from(state.likedPostsIds)..add(post.id!))
    ));
  }

  void unLikePost({required Post post}) {
    _postsRepository.deleteLike(postId: post.id!, userId: _authBloc.state.user!.uid);

    emit(state.copyWith(
        likedPostsIds: Set<String>.from(state.likedPostsIds)..remove(post.id!)));
        // recentlyLikedPostIds: Set<String>.from(state.likedPostsIds)..remove(post.id!)));
  }

  void clearAllLikedPosts() {
    emit(LikedPostState.initial());
  }
}
