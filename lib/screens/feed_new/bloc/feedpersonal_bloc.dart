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
    } 
  }

  Stream<FeedpersonalState> _mapFeedLoadPostsInitToState(List<Post?> posts, int currIdx) async* {
    yield state.copyWith(posts: posts, startingIdx: currIdx);
  }

}
