part of 'commuinity_bloc.dart';

// if not a member then the cm will show armormed or shielded.
// this is because we want to show only a limited amount of info to 
// certian users based on the cm settings
enum CommuintyStatus { inital, loading, loaded, error, armormed, shielded, requestPending}

class CommuinityState extends Equatable {
  final bool? isMember;
  final bool collapseCordColumn;
  final bool collapseVvrColumn;
  final List<Post?> postDisplay;
  final List<Event?> events;
  final List<KingsCord?> kingCords;
  final CommuintyStatus status;
  final Failure failure;
  final Map<String, bool> mentionedMap;
  final Userr currUserr;
  final String themePack;
  final int boosted;
  final bool isBaned;
  final List<Userr> banedUsers;

  const CommuinityState({
    required this.isMember,
    required this.collapseCordColumn,
    required this.collapseVvrColumn,
    required this.postDisplay,
    required this.kingCords,
    required this.status,
    required this.failure,
    required this.events,
    required this.mentionedMap,
    required this.currUserr,
    required this.themePack,
    required this.boosted,
    required this.isBaned,
    required this.banedUsers,
  });

  @override
  List<Object?> get props => [
        currUserr,
        mentionedMap,
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
      ];

  factory CommuinityState.inital() {
    return CommuinityState(
        currUserr: Userr.empty,
        mentionedMap: {},
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
        banedUsers: []);
  }
  CommuinityState copyWith({
    bool? isMember,
    List<Post?>? postDisplay,
    List<KingsCord?>? kingCords,
    CommuintyStatus? status,
    Failure? failure,
    Map<String, bool>? mentionedMap,
    List<Event?>? events,
    bool? collapseCordColumn,
    bool? collapseVvrColumn,
    Userr? currUserr,
    String? themePack,
    int? boosted,
    bool? isBaned,
    List<Userr>? banedUsers,
  }) {
    return CommuinityState(
        events: events ?? this.events,
        isMember: isMember ?? this.isMember,
        postDisplay: postDisplay ?? this.postDisplay,
        kingCords: kingCords ?? this.kingCords,
        failure: failure ?? this.failure,
        status: status ?? this.status,
        mentionedMap: mentionedMap ?? this.mentionedMap,
        collapseCordColumn: collapseCordColumn ?? this.collapseCordColumn,
        collapseVvrColumn: collapseVvrColumn ?? this.collapseVvrColumn,
        currUserr: currUserr ?? this.currUserr,
        themePack: themePack ?? this.themePack,
        boosted: boosted ?? this.boosted,
        isBaned: isBaned ?? this.isBaned,
        banedUsers: banedUsers ?? this.banedUsers);
  }
}
