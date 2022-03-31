part of 'create_post_cubit.dart';

enum CreatePostStatus { initial, preview, submitting, success, error }

class CreatePostState extends Equatable {
  //1
  final File? imageFile; //  bc we are changing the post image
  final File? videoFile;
  final String? caption; //because we are changing the caption
  final bool isRecording;
  final CreatePostStatus status; //for different times in the sinario
  final Failure failure; //for failures
  //2
  const CreatePostState({
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
      imageFile: imageFile ?? this.imageFile,
      videoFile: videoFile ?? this.videoFile,
      caption: caption ?? this.caption,
      isRecording: isRecording ?? this.isRecording,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
