part of 'calls_home_cubit.dart';

//enum for state changes
enum CallsHomeStatus {initial, loading, done, error, paginating}

class CallshomeState extends Equatable {
  //class data
  final bool currActive;

  final String callName;

  final Map<String, dynamic> memberInfo;

  final List<Userr> currFollowing;

  final List<Userr> currInCall;

  final CallsHomeStatus status;

  final Failure failure;

  //adding a constructor
  CallshomeState({
    required this.currActive,

    required this.callName,

    required this.memberInfo,

    required this.currFollowing,

    required this.currInCall,

    required this.status,

    required this.failure
  });

  
  //the props
  @override
  List<Object> get props => [currActive, callName, memberInfo, currFollowing, currInCall, status, failure];

  
  //an auto gened copy with
  CallshomeState copyWith({
    bool? currActive,
    String? callName,
    Map<String, dynamic>? memberInfo,
    List<Userr>? currFollowing,
    List<Userr>? currInCall,
    CallsHomeStatus? status,
    Failure? failure,
  }) {
    return CallshomeState(
      currActive: currActive ?? this.currActive,
      callName: callName ?? this.callName,
      memberInfo: memberInfo ?? this.memberInfo,
      currFollowing: currFollowing ?? this.currFollowing,
      currInCall: currInCall ?? this.currInCall,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  //the initial for the sake of the bloc, basically its the super
  factory CallshomeState.initial() {
    return CallshomeState(

      currActive: false,

      callName: 'name...',

      memberInfo: {},

      currFollowing: [],

      currInCall: [],

      status: CallsHomeStatus.initial,

      failure: Failure(),
    );
  }
}


