part of 'create_post_cubit.dart';

enum CreatePostStatus { initial, preview, submitting, success, error }

class CreatePostState extends Equatable {
  //1
  File? imageFile; //  bc we are changing the post image
  File? videoFile;
  String? caption; //because we are changing the caption
  final bool isRecording;
  final CreatePostStatus status; //for different times in the sinario
  final Failure failure; //for failures
  //2
  CreatePostState({
    this.imageFile,
    this.videoFile,
    this.caption,
    required this.isRecording,
    required this.status,
    required this.failure,
  });
  //5
  factory CreatePostState.initial() {
    return CreatePostState(
        imageFile: null,
        videoFile: null,
        caption: null,
        isRecording: false,
        status: CreatePostStatus.initial,
        failure: Failure());
  }

  //3
  @override
  List<Object?> get props => [videoFile, imageFile, caption, status, failure, isRecording];

  //4
  CreatePostState copyWith({
    File? imageFile,
    File? videoFile,
    String? caption,
    bool? isRecording,
    CreatePostStatus? status,
    Failure? failure,
  }) {
    return CreatePostState(
      imageFile: imageFile ?? this.imageFile, // ---------> so i will del the value of this.imagFile and this.videofile
      videoFile: videoFile ?? this.videoFile, // ---------> I do this because I need to rewrite and the copy with does not allow this
      caption: caption ?? this.caption,       //            The rewrite is done in the cubit function, I will change the value of state.file to null
      isRecording: isRecording ?? this.isRecording, //      will be seen when I do the onClear... atm called onRemovePostContent
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
