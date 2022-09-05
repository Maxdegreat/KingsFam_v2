part of 'create_post_cubit.dart';

class CreatePostState extends Equatable {
  final File? imgF;
  final File? vidF;
  final String caption;
  final String hashTags;
  
  const CreatePostState({ required this.imgF, required  this.vidF, required  this.caption, required  this.hashTags});

  factory CreatePostState.inital() {
    return CreatePostState(imgF: null, vidF: null, caption: "", hashTags: "");
  }

  @override
  List<Object?> get props => [imgF, vidF, caption, hashTags];

  CreatePostState copyWith({
    File? imgF,
    File? vidF,
    String? caption,
    String? hashTags,
  }) {
    return CreatePostState(
      imgF: imgF ?? this.imgF,
      vidF: vidF ?? this.vidF,
      caption: caption ?? this.caption,
      hashTags: hashTags ?? this.hashTags
    );
  }
}

