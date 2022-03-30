import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  final PostsRepository _postsRepository; //1 class data
  final StorageRepository _storageRepository; //we will need this bc we are making the submit func is in here to reduce code in ui
  final ChurchRepository _churchRepository;
  final AuthBloc _authBloc;

  CreatePostCubit({
      required PostsRepository postsRepository,
      required StorageRepository storageRepository, //2 constructor
      required ChurchRepository churchRepository,
      required AuthBloc authBloc
  })
      : _postsRepository = postsRepository,
        _storageRepository = storageRepository,
        _churchRepository = churchRepository,
        _authBloc = authBloc,
        super(CreatePostState.initial());

  //3 on changed
  void onQuoteChanged(String quote) {
    emit(state.copyWith(quote: quote, status: CreatePostStatus.initial));
  }

  void onTapedCommuinitys(String ids) {
    List<String> bucket = [];
     if (bucket.contains(ids))
       bucket.remove(ids);
     else
       bucket.add(ids);
    print("On taped fired ... yezirrr ");
    print(state.commuinitys.length);
    emit(state.copyWith(commuinitys: bucket ));
  }

  void postImageOnChanged(File file) => 
    emit(state.copyWith(postImage: file, status: CreatePostStatus.submitting));
    
  

  void postVideoOnChanged(File file) {
    emit(state.copyWith(postVideo: file, status: CreatePostStatus.initial));
  }

  void captionOnChanged(String caption) {
    emit(state.copyWith(caption: caption, status: CreatePostStatus.initial));
  }

  void gallViewChanged(bool currentView) {
    emit(state.copyWith(isImageView: currentView, status: CreatePostStatus.initial));
  }

//4 submit
  void submit() async {
    //print("bet, now we are in the actual submit cubit method");
    emit(state.copyWith(status: CreatePostStatus.submitting));
    //print("we passed a conditional test, and now we are heading to the create post cubit");

    if (state.commuinitys.length >= 1) {
      try {
        print("passed the inti test 1");
      final author = Userr.empty.copyWith(id: _authBloc.state.user!.uid);
      final commuinity = await _churchRepository.grabChurchWithIdStr(commuinity: state.commuinitys[0]);
      print("grabed the commuinity, 2");
      //starting of if conditionals 
      //only run this variant of code if uploaded with an image
      print("${state.postImage == null}");
      if (state.postImage != null) {
        final postImageUrl = await _storageRepository.uploadPostImage(image: state.postImage!);
        print("The post is made x");
        final post = Post(
            author: author,
            quote: null,
            imageUrl: postImageUrl,
            commuinity: commuinity ,
            videoUrl: null,
            soundTrackUrl: null,
            caption: state.caption,
            likes: 0,
            date: Timestamp.now());
        // awaiting the creation of the post!
        print("We are in the img sec of submit - awaiting postrepo.create post");
        await _postsRepository.createPost(post: post);
        emit(state.copyWith(status: CreatePostStatus.success));
      } else if (state.quote != null) {
        final post = Post(
            author: author,
            quote: state.quote,
            imageUrl: null,
            videoUrl: null,
            soundTrackUrl: null,
            caption: state.caption,
            likes: 0,
            date: Timestamp.now());

        await _postsRepository.createPost(post: post);
        emit(state.copyWith(status: CreatePostStatus.success));
      } else if (state.postVideo != null) {
        final postVideoUrl =
            await _storageRepository.uploadPostVideo(video: state.postVideo!);
        final post = Post(
            author: author,
            quote: null,
            imageUrl: null,
            videoUrl: postVideoUrl,
            commuinity: commuinity,
            soundTrackUrl: null,
            caption: state.caption,
            likes: 0,
            date: Timestamp.now());
        await _postsRepository.createPost(post: post);
        emit(state.copyWith(status: CreatePostStatus.success));
      }
      //----------------ending of if conditionals
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: 'sorry we are unable to compleat ur post'),
          status: CreatePostStatus.error));
    }
    } else {
      emit(state.copyWith(failure: Failure(message: "You have to add a commuinity first fam"), status: CreatePostStatus.error ));
    }
  }

  void reset() {
    emit(CreatePostState.initial());
  }
}
