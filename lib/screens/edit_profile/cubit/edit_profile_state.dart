part of 'edit_profile_cubit.dart';

enum EditProfileStatus { initial, submitting, success, error }

class EditProfileState extends Equatable {
  final File? bannerImage;
  final File? profileImage;
  final String username;
  final String location;
  final String bio;
  final String colorPref;
  final EditProfileStatus status;
  final Failure failure;

  EditProfileState({
    required this.bannerImage,
    required this.profileImage,
    required this.username,
    required this.location,
    required this.bio,
    required this.colorPref,
    required this.status,
    required this.failure,
  });

  factory EditProfileState.initial() {
    return EditProfileState(
      bannerImage: null,
      profileImage: null,
      username: '',
      location: '',
      bio: '',
      colorPref: '',
      status: EditProfileStatus.initial,
      failure: Failure(),
    );
  }

  @override
  List<Object?> get props => [
        bannerImage,
        profileImage,
        username,
        location,
        bio,
        colorPref,
        status,
        failure,
      ];

  EditProfileState copyWith({
    File? bannerImage,
    File? profileImage,
    String? username,
    String? location,
    String? bio,
    String? colorPref,
    EditProfileStatus? status,
    Failure? failure,
  }) {
    return EditProfileState(
      bannerImage: bannerImage ?? this.bannerImage,
      profileImage: profileImage ?? this.profileImage,
      username: username ?? this.username,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      colorPref: colorPref ?? this.colorPref,
      status: status ?? this.status,
      failure: failure ?? this.failure,

    );
  }
}
