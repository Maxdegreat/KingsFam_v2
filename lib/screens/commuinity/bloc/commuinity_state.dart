part of 'commuinity_bloc.dart';

enum CommuintyStatus { inital, loading, loaded, error }

class CommuinityState extends Equatable {
  final bool? isMember;
  final bool collapseCordColumn;
  final bool collapseVvrColumn;
  final List<Post?> postDisplay;
  final List<KingsCord?> kingCords;
  final Map<String, List<String>> permissions;
  final List<CallModel> calls;
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
    required this.calls,
    required this.status,
    required this.failure,
    required this.permissions,
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
        permissions,
        calls,
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
        permissions: {},
        isMember: null,
        postDisplay: [],
        kingCords: [],
        calls: [],
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
    List<CallModel>? calls,
    CommuintyStatus? status,
    Failure? failure,
    Map<String, bool>? mentionedMap,
    Map<String, List<String>>? permissions,
    bool? collapseCordColumn,
    bool? collapseVvrColumn,
    Userr? currUserr,
    String? themePack,
    int? boosted,
    bool? isBaned,
    List<Userr>? banedUsers,
  }) {
    return CommuinityState(
      permissions: permissions ?? this.permissions,
      isMember: isMember ?? this.isMember,
      postDisplay: postDisplay ?? this.postDisplay,
      kingCords: kingCords ?? this.kingCords,
      calls: calls ?? this.calls,
      failure: failure ?? this.failure,
      status: status ?? this.status,
      mentionedMap: mentionedMap ?? this.mentionedMap,
      collapseCordColumn: collapseCordColumn ?? this.collapseCordColumn,
      collapseVvrColumn: collapseVvrColumn ?? this.collapseVvrColumn,
      currUserr: currUserr ?? this.currUserr,
      themePack: themePack ?? this.themePack,
      boosted: boosted ?? this.boosted,
      isBaned: isBaned ?? this.isBaned,
      banedUsers: banedUsers ?? this.banedUsers
    );
  }
}
