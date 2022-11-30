part of 'commuinity_bloc.dart';

// if not a member then the cm will show armormed or shielded.
// this is because we want to show only a limited amount of info to 
// certian users based on the cm settings
enum CommuintyStatus { inital, loading, loaded, error, armormed, shielded}
enum RequestStatus { none, pending, }

class CommuinityState extends Equatable {
  final bool? isMember;
  final bool collapseCordColumn;
  final bool collapseVvrColumn;
  final List<Post?> postDisplay;
  final List<Event?> events;
  final List<KingsCord?> kingCords;
  final CommuintyStatus status;
  final Failure failure;
  final List<KingsCord?> mentionedCords;
  final Userr currUserr;
  final String themePack;
  final int boosted;
  final bool isBaned;
  final List<Userr> banedUsers;
  final RequestStatus requestStatus;
  final Map<String, dynamic> role;
  final String cmId;

  const CommuinityState({
    required this.isMember,
    required this.collapseCordColumn,
    required this.collapseVvrColumn,
    required this.postDisplay,
    required this.kingCords,
    required this.status,
    required this.failure,
    required this.events,
    required this.mentionedCords,
    required this.currUserr,
    required this.themePack,
    required this.boosted,
    required this.isBaned,
    required this.banedUsers,
    required this.requestStatus,
    required this.role,
    required this.cmId,
  });

  @override
  List<Object?> get props => [
        currUserr,
        mentionedCords,
        collapseCordColumn,
        collapseVvrColumn,
        events,
        kingCords,
        postDisplay,
        isMember,
        status,
        failure,
        themePack,
        boosted,
        isBaned,
        banedUsers,
        requestStatus,
        role,
        cmId,
      ];

  factory CommuinityState.inital() {
    return CommuinityState(
      role: {
        "roleName" : "Member", // default can be string Member or null
        "permissions" : ["0"] // string 0 means basic role
      },
        currUserr: Userr.empty,
        mentionedCords: [],
        collapseCordColumn: false,
        collapseVvrColumn: false,
        events: [],
        isMember: null,
        postDisplay: [],
        kingCords: [],
        status: CommuintyStatus.inital,
        failure: Failure(),
        themePack: 'none',
        boosted: 0,
        isBaned: false,
        banedUsers: [],
        cmId: "",
        requestStatus: RequestStatus.none,
    );
  }
  CommuinityState copyWith({
    Map<String, dynamic>? role,
    bool? isMember,
    List<Post?>? postDisplay,
    List<KingsCord?>? kingCords,
    CommuintyStatus? status,
    Failure? failure,
    List<KingsCord?>? mentionedCords,
    List<Event?>? events,
    bool? collapseCordColumn,
    bool? collapseVvrColumn,
    Userr? currUserr,
    String? themePack,
    int? boosted,
    bool? isBaned,
    List<Userr>? banedUsers,
    RequestStatus? requestStatus,
    String? cmId,
  }) {
    return CommuinityState(
      role: role ?? this.role,
        events: events ?? this.events,
        isMember: isMember ?? this.isMember,
        postDisplay: postDisplay ?? this.postDisplay,
        kingCords: kingCords ?? this.kingCords,
        failure: failure ?? this.failure,
        status: status ?? this.status,
        mentionedCords: mentionedCords ?? this.mentionedCords,
        collapseCordColumn: collapseCordColumn ?? this.collapseCordColumn,
        collapseVvrColumn: collapseVvrColumn ?? this.collapseVvrColumn,
        currUserr: currUserr ?? this.currUserr,
        themePack: themePack ?? this.themePack,
        boosted: boosted ?? this.boosted,
        isBaned: isBaned ?? this.isBaned,
        banedUsers: banedUsers ?? this.banedUsers,
        requestStatus: requestStatus ?? this.requestStatus,
        cmId: cmId ?? this.cmId,
    );
  }
}
