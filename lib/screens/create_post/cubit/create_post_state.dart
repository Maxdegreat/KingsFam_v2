part of 'create_post_cubit.dart';

enum CreatePostStatus { initial, submitting, success, error }

class CreatePostState extends Equatable {
  //1
  final String? quote;
  final File? postImage; //  bc we are changing the post image
  final File? postVideo;
  final String caption; //because we are changing the caption
  final bool isImageView;
  final List<String> commuinitys;
  final CreatePostStatus status; //for different times in the sinario
  final Failure failure; //for failures
  //2
  const CreatePostState({
    required this.postImage,
    required this.postVideo,
    required this.quote,
    required this.caption,
    required this.isImageView,
    required this.commuinitys,
    required this.status,
    required this.failure,
  });
  //5
  factory CreatePostState.initial() {
    return CreatePostState(
        postImage: null,
        postVideo: null,
        quote: null,
        caption: '',
        isImageView: true,
        commuinitys: [],
        status: CreatePostStatus.initial,
        failure: Failure());
  }

  //3
  @override
  List<Object?> get props => [postVideo, postImage, caption, commuinitys, status, failure];
  //4
  CreatePostState copyWith({
    File? postImage,
    File? postVideo,
    String? quote,
    String? caption,
    bool? isImageView,
    List<String>? commuinitys,
    CreatePostStatus? status,
    Failure? failure,
  }) {
    return CreatePostState(
      postImage: postImage ?? this.postImage,
      postVideo: postVideo ?? this.postVideo,
      caption: caption ?? this.caption,
      isImageView: isImageView ?? this.isImageView,
      commuinitys: commuinitys ?? this.commuinitys,
      quote: quote ?? this.quote,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
