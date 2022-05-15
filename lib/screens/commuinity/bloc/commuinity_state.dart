part of 'commuinity_bloc.dart';

abstract class CommuinityState extends Equatable {
  const CommuinityState();
  
  @override
  List<Object> get props => [];
}

class CommuinityInitial extends CommuinityState {
  CommuinityInitial();
}

class CommuinityLoading extends CommuinityState {
  CommuinityLoading();
}

class CommuinityLoaded extends CommuinityState {
  final bool isMember;
  final List<Post?> postDisplay;
  final List<KingsCord?> kingCords;
  final List<CallModel> calls;
  CommuinityLoaded({
    required this.isMember,
    required this.calls, 
    required this.kingCords, 
    required this.postDisplay,
  });
  @override
  List<Object> get props => [calls, kingCords, postDisplay, isMember];
}

class CommuinityError extends CommuinityState {
  final Failure failure;
  CommuinityError({required this.failure});
  @override
  List<Object> get props => [failure ];
}

class CommuinityJoinLeaveState extends CommuinityState {
  final bool isMember;
  final List<Post?> postDisplay;
  final List<KingsCord?> kingCords;
  final List<CallModel> calls;
  CommuinityJoinLeaveState({
    required this.isMember,
    required this.calls, 
    required this.kingCords, 
    required this.postDisplay,
  });
  @override
  List<Object> get props => [calls, kingCords, postDisplay, isMember];
}