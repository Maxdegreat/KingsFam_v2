part of 'commuinity_bloc.dart';
enum CommuintyStatus {inital, loading, loaded, error}

class CommuinityState extends Equatable {
  final bool isMember;
  final bool collapseCordColumn;
  final bool collapseVvrColumn;
  final List<Post?> postDisplay;
  final List<KingsCord?> kingCords;
  final Map<String, List<String>> permissions;
  final List<CallModel> calls;
  final CommuintyStatus status;
  final Failure failure;
  final Map<String, bool> mentionedMap;

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
});
  
  @override
  List<Object> get props => [mentionedMap, collapseCordColumn, collapseVvrColumn, permissions, calls, kingCords, postDisplay, isMember, status, failure];
  
  factory CommuinityState.inital() {
    return CommuinityState(mentionedMap: {}, collapseCordColumn: false, collapseVvrColumn: false, permissions: {}, isMember: false, postDisplay: [], kingCords: [], calls: [], status: CommuintyStatus.inital, failure: Failure());
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
    bool? collapseVvrColumn  ,
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
    );
  }
}

// class CommuinityInitial extends CommuinityState {
//   CommuinityInitial();
// }

// class CommuinityLoading extends CommuinityState {
//   CommuinityLoading();
// }

// class CommuinityLoaded extends CommuinityState {
//   final bool isMember;
//   final List<Post?> postDisplay;
//   final List<KingsCord?> kingCords;
//   final List<CallModel> calls;
//   CommuinityLoaded({
//     required this.isMember,
//     required this.calls, 
//     required this.kingCords, 
//     required this.postDisplay,
//   });
//   @override
//   List<Object> get props => [calls, kingCords, postDisplay, isMember];
// }

// class CommuinityError extends CommuinityState {
//   final Failure failure;
//   CommuinityError({required this.failure});
//   @override
//   List<Object> get props => [failure ];
// }

// class CommuinityJoinLeaveState extends CommuinityState {
//   final bool isMember;
//   final List<Post?> postDisplay;
//   final List<KingsCord?> kingCords;
//   final List<CallModel> calls;
//   CommuinityJoinLeaveState({
//     required this.isMember,
//     required this.calls, 
//     required this.kingCords, 
//     required this.postDisplay,
//   });
//   @override
//   List<Object> get props => [calls, kingCords, postDisplay, isMember];
// }