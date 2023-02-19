part of 'commuinity_bloc.dart';

// if not a member then the cm will show armormed or shielded.
// this is because we want to show only a limited amount of info to
// certian users based on the cm settings
enum CommuintyStatus {
  inital,
  loading,
  loaded,
  error,
  armormed,
  shielded,
  updated
}

enum RequestStatus {
  none,
  pending,
}

class CommuinityState extends Equatable {
  final bool? isMember;
  final List<Post?> postDisplay;
  final List<KingsCord?> pinedRooms;
  final List<KingsCord?> yourRooms;
  final List<KingsCord?> otherRooms;
  final CommuintyStatus status;
  final Failure failure;
  final Userr currUserr;
  final int boosted;
  final bool isBaned;
  final List<Userr> banedUsers;
  final RequestStatus requestStatus;
  final Map<String, dynamic> role;
  final String cmId;
  final List<String> badges;

  const CommuinityState({
    required this.isMember,
    required this.postDisplay,
    required this.pinedRooms,
    required this.yourRooms,
    required this.otherRooms,
    required this.status,
    required this.failure,
    required this.currUserr,
    required this.boosted,
    required this.isBaned,
    required this.banedUsers,
    required this.requestStatus,
    required this.role,
    required this.cmId,
    required this.badges,
  });

  @override
  List<Object?> get props => [
    isMember,
    postDisplay,
    pinedRooms,
    yourRooms,
    otherRooms,
    status,
    failure,
    currUserr,
    boosted,
    isBaned,
    banedUsers,
    requestStatus,
    role,
    cmId,
    badges,
      ];

  factory CommuinityState.inital() {
    return CommuinityState(
      role: { // MIGRATE NAME LATER TO CMMEMBERINFO
        "kfRole": "Member", // default can be string Member or null
        "badges" : ["member"],
      },
      currUserr: Userr.empty,
      otherRooms: [],
      pinedRooms: [],
      yourRooms: [],
      isMember: null,
      postDisplay: [],
      status: CommuintyStatus.inital,
      failure: Failure(),
      boosted: 0,
      isBaned: false,
      banedUsers: [],
      cmId: "",
      requestStatus: RequestStatus.none,
      badges: ["members"]
    );
  }
  CommuinityState copyWith({
  bool? isMember,
  List<Post?>? postDisplay,
  List<KingsCord?>? pinedRooms,
  List<KingsCord?>? yourRooms,
  List<KingsCord?>? otherRooms,
  CommuintyStatus? status,
  Failure? failure,
  Userr? currUserr,
  int? boosted,
  bool? isBaned,
  List<Userr>? banedUsers,
  RequestStatus? requestStatus,
  Map<String, dynamic>? role,
  String? cmId,
  List<String>? badges,
  }) {
    return CommuinityState(
      role: role ?? this.role,
      badges: badges ?? this.badges,
      banedUsers: banedUsers ?? this.banedUsers,
      boosted: boosted ?? this.boosted,
      cmId: cmId ?? this.cmId,
      currUserr: currUserr ?? this.currUserr,
      failure: failure ?? this.failure,
      isBaned: isBaned ?? this.isBaned,
      isMember: isMember ?? this.isMember,
      otherRooms: otherRooms ?? this.otherRooms,
      pinedRooms: pinedRooms ?? this.pinedRooms,
      postDisplay: postDisplay ?? this.postDisplay,
      requestStatus: requestStatus ?? this.requestStatus,
      status: status ?? this.status,
      yourRooms: yourRooms ?? this.yourRooms,

    );
  }
}
