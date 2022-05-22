part of 'commuinity_bloc.dart';
enum CommuintyStatus {inital, loading, loaded, error}

class CommuinityState extends Equatable {
  final bool isMember;
  final List<Post?> postDisplay;
  final List<KingsCord?> kingCords;
  final List<CallModel> calls;
  final CommuintyStatus status;
  final Failure failure;

  const CommuinityState({
    required this.isMember,
    required this.postDisplay,
    required this.kingCords,
    required this.calls,
    required this.status,
    required this.failure,
});
  
  @override
  List<Object> get props => [calls, kingCords, postDisplay, isMember, status, failure];
  
  factory CommuinityState.inital() {
    return CommuinityState(isMember: false, postDisplay: [], kingCords: [], calls: [], status: CommuintyStatus.inital, failure: Failure());
  }
  CommuinityState copyWith({
    bool? isMember,
    List<Post?>? postDisplay,
    List<KingsCord?>? kingCords,
    List<CallModel>? calls,
    CommuintyStatus? status,
    Failure? failure,
  }) {
    return CommuinityState(
      isMember: isMember ?? this.isMember,
      postDisplay: postDisplay ?? this.postDisplay,
      kingCords: kingCords ?? this.kingCords,
      calls: calls ?? this.calls, 
      failure: failure ?? this.failure, 
      status: status ?? this.status,
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