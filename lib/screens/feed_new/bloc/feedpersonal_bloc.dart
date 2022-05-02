import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'feedpersonal_event.dart';
part 'feedpersonal_state.dart';

class FeedpersonalBloc extends Bloc<FeedpersonalEvent, FeedpersonalState> {

  final LikedPostCubit _likedPostCubit;
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;  

  FeedpersonalBloc({
    required LikedPostCubit likedPostCubit,
    required AuthBloc authBloc,
    required PostsRepository postsRepository,
  }) : _likedPostCubit = likedPostCubit, _authBloc = authBloc, _postsRepository = postsRepository, super(FeedpersonalState.inital()); 
  
  @override
  Stream<FeedpersonalState> mapEventToState(FeedpersonalEvent event) async* {
    if (event is FeedLoadPostsInit) {
      yield* _mapFeedLoadPostsInitToState(event.posts, event.currIdx);
    } else if (event is FeedPersonalPaginatePosts) {
      yield* _mapFeedPaginatePostToState();
    } else if (event is FeedJumpTo) {
      yield* _mapUpdateJumpToState();
    }
  }

  Stream<FeedpersonalState> _mapFeedLoadPostsInitToState(List<Post?> posts, int currIdx) async* {
    yield state.copyWith(posts: posts, startingIdx: currIdx);
  }

  Stream<FeedpersonalState> _mapUpdateJumpToState() async* {
    yield state.copyWith(jumpTo: 1 == 1,);
  }



  Stream<FeedpersonalState> _mapFeedPaginatePostToState() async* {
    yield state.copyWith(status: FeedPersonalStatus.paginating);
    try {
      // get last post id to start paginating from here
      String? lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
      // get the new batch
      final posts = await _postsRepository.getUserFeed(userId: _authBloc.state.user!.uid, lastPostId: lastPostId, limit: 8);
      // add the new batch to the state.posts lists
      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

      // get the posts that we have liked
      final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
      // updates the liked posts from liked post cuit instance???
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
      
      yield state.copyWith(posts: updatedPosts, status: FeedPersonalStatus.success);
    } catch (e) {
      yield state.copyWith(failure: Failure(message: "dang, max messed up you're pagination code...", code: e.toString()), status: FeedPersonalStatus.error);
    }
  }
}

