import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
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

  // void onTapedCommuinitys(String ids) {
  //   List<String> bucket = [];
  //    if (bucket.contains(ids))
  //      bucket.remove(ids);
  //    else
  //      bucket.add(ids);
  //   print("On taped fired ... yezirrr ");
  //   print(state.commuinitys.length);
  //   emit(state.copyWith(commuinitys: bucket ));
  // }

void onRemovePostContent() { 
  emit(state.copyWith(imageFile: null, videoFile: null, caption: null, isRecording: false, status: CreatePostStatus.initial));
  state.videoFile = null; state.caption = null; state.imageFile = null;
}

// ------------> FOR POST IMAGE
  void postImageOnChanged(File? file) => 
    emit(state.copyWith(imageFile: file, videoFile: null, status: CreatePostStatus.preview));
  
  void onRemovePostImmage() => emit(state.copyWith(imageFile: null, status: CreatePostStatus.initial));

  void onUplaodImageFile(File? file) => emit(state.copyWith(imageFile: file ));
  
// -------------------> FOR POST RECORDING
  void onStopPostRecording(File? file) => emit(state.copyWith(videoFile: file, isRecording: false, status: CreatePostStatus.preview));

  void onUploadVideoFile(File? file) => emit(state.copyWith(videoFile: file)); // -------- for the upload bottom sheet. it has a di

  void startRecording() => emit(state.copyWith(isRecording: true, status: CreatePostStatus.initial));
  

  void onRemoveVideoFile() => emit(state.copyWith(videoFile: null, status: CreatePostStatus.initial));

// ------------------> FOR CAPTION
  void captionOnChanged(String? caption) {
    emit(state.copyWith(caption: caption));
    print("ION REALLY CARE YEAH ${state.caption}");
  }

  void onBackToCameraView() => emit(state.copyWith(status: CreatePostStatus.initial));

  // THIS IS FOR THE PREVIEW POST IN THE CREATEPOST SCREEN. YOU SHOULD FIND A LINK TO THE FUNC IN APP BAR
  PrePost prePost() {
    final author = Userr.empty.copyWith(id: _authBloc.state.user!.uid);
    var prepost = PrePost(author: author, commuinitys: [], caption: null, imageFile: state.imageFile, videoFile: state.videoFile, soundTrack: null, quote: null, );
    return prepost;
  }




// --------------------------------- 4 submit
  Future<void> submit({required PrePost prePost}) async {
    print("called submit++++++++++++++++++++++++++");
    emit(state.copyWith(status: CreatePostStatus.submitting));

      try {

      final author = prePost.author; //Userr.empty.copyWith(id: _authBloc.state.user!.uid);
      print("passed the author");


      String? caption;
      if (state.caption != null)
        caption = state.caption;
      

      if (prePost.imageFile != null) {
        print("The image is not null");
        final postImageUrl = await _storageRepository.uploadPostImage(image: prePost.imageFile!);

        final post = Post(
            author: author,
            quote: null,
            imageUrl: postImageUrl,
            commuinity: null ,
            videoUrl: null,
            soundTrackUrl: null,
            caption: caption,
            likes: 0,
            date: Timestamp.now()
        );

        print("made the post");

        await _postsRepository.createPost(post: post);
        print(" created the post");
        emit(state.copyWith(status: CreatePostStatus.success));
        print("----------->posted<----------------");


        
      }  else if (prePost.videoFile != null) {
        final postVideoUrl =
            await _storageRepository.uploadPostVideo(video: prePost.videoFile!);
        final post = Post(
            author: author,
            quote: null,
            imageUrl: null,
            videoUrl: postVideoUrl,
            commuinity: null,
            soundTrackUrl: null,
            caption: caption,
            likes: 0,
            date: Timestamp.now()
        );
        //await _postsRepository.createPost(post: post);
        emit(state.copyWith(status: CreatePostStatus.success));
      }
     
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: 'sorry we are unable to compleat ur post'),
          status: CreatePostStatus.error));
    }

  }

  void reset() {
    emit(CreatePostState.initial());
  }
}
