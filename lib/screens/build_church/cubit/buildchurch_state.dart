part of 'buildchurch_cubit.dart';

enum BuildChurchStatus { initial, loading, success, error }

class BuildchurchState extends Equatable {
  //1 class data
  final File? imageFile;
  final List<String>? caseSearchList;
  final String? initHashTag;
  final List<String>? hashTags;
  final String name;
  final String about;
  final String location;
  final List<String> memberIds;
  final List<String> adminIds; // this will work by adding the certin ids into this list. when making user map if the key (an id) is found in the adminIds then pass isAdmin True in the map. i think this is better because it writes less.
  final Map<String, dynamic> memberInfo;
  final bool isSubmiting;
  final bool isMember;
  final BuildChurchStatus status;
  final Failure failure;
  // 2 constructor
  BuildchurchState({
    required this.isSubmiting,
    required this.imageFile,
    required this.caseSearchList,
    this.initHashTag,
    this.hashTags,
    required this.name,
    required this.about,
    required this.adminIds,
    required this.location,
    required this.memberIds,
    required this.memberInfo,
    required this.isMember,
    required this.status,
    required this.failure,
  });
  // 3 the props
  @override
  List<Object?> get props => [
        imageFile,
        isSubmiting,
        name,
        caseSearchList,
        initHashTag,
        hashTags,
        about,
        adminIds,
        location,
        memberIds,
        memberInfo,
        isMember,
        status,
        failure
      ];

  //4 copy with
  BuildchurchState copyWith(
      {List<String>? caseSearchList,
      bool? isSubmiting,
      String? initHashTag,
      List<String>? hashTags,
      File? imageFile,
      String? name,
      String? about,
      String? location,
      List<String>? memberIds,
      Map<String, dynamic>? memberInfo,
      List<String>? adminIds,
      bool? isAdmin,
      bool? isMember,
      BuildChurchStatus? status,
      Failure? failure}) {
    return BuildchurchState(
        isSubmiting: isSubmiting ?? this.isSubmiting,
        caseSearchList: caseSearchList ?? this.caseSearchList,
        initHashTag: initHashTag ?? this.initHashTag,
        hashTags: hashTags ?? this.hashTags,
        imageFile: imageFile ?? this.imageFile,
        adminIds: adminIds ?? this.adminIds,
        name: name ?? this.name,
        about: about ?? this.about,
        location: location ?? this.location,
        memberIds: memberIds ?? this.memberIds,
        memberInfo: memberInfo ?? this.memberInfo,
        isMember: isMember ?? this.isMember,
        status: status ?? this.status,
        failure: failure ?? this.failure);
  }

  // 5 the initial
  factory BuildchurchState.initial() {
    return BuildchurchState(
        isSubmiting: false,
        caseSearchList: [],
        initHashTag: null,
        hashTags: null,
        imageFile: null,
        name: '',
        adminIds: [],
        about: '',
        location: '',
        memberIds: [],
        memberInfo: {},
        isMember: false,
        status: BuildChurchStatus.initial,
        failure: Failure());
  }
}
