part of 'search_bloc.dart';

enum SearchStatus { initial, pag, loading, success, error }

class SearchState extends Equatable {
  final Userr user; // curr uuser
  final List<Userr> users; // list of users
  final List<Userr> followingUsers;
  final Set<Userr> selectedUsers; // list of selected users

  //final List<Userr> usersInCommuinity;

  final List<Church> churches; // list of churches
  final List<Church> churchesList2; // rn ppl from tik tok
  final List<Church> chruchesNotEqualLocation; // new churches


  final bool isSelected; // bool for ?
  final SearchStatus status; //the enum status
  final Failure failure; // for failure

  factory SearchState.initial() {
    return SearchState(
        user: Userr.empty,
        users: [],
        //usersInCommuinity: [],
        followingUsers: [],
        selectedUsers: {},
        churches: [],
        chruchesNotEqualLocation: [],
        churchesList2: [],

        isSelected: false,
        status: SearchStatus.initial,
        failure: Failure());
  }

  const SearchState({
    required this.user,
    required this.users,
    //required this.usersInCommuinity,
    required this.followingUsers,
    required this.selectedUsers,
    required this.churches,
    required this.churchesList2,
    required this.chruchesNotEqualLocation,

    required this.isSelected,
    required this.status,
    required this.failure,
  });

  @override
  List<Object?> get props => [
        users,
        user,
        //usersInCommuinity,
        followingUsers,
        selectedUsers,
        churches,
        churchesList2,
        chruchesNotEqualLocation,

        isSelected,
        status,
        failure
      ];

  SearchState copyWith({
    Userr? user,
    List<Userr>? users,
    //List<Userr>? usersInCommuinity,
    List<Userr>? followingUsers,
    Set<Userr>? selectedUsers,
    bool? isSelected,
    List<Church>? churches,
    List<Church>? churchesList2,
    List<Church>? chruchesNotEqualLocation,

    SearchStatus? status,
    Failure? failure,
  }) {
    return SearchState(
      user: user ?? this.user,
      users: users ?? this.users,
      //usersInCommuinity: usersInCommuinity ?? this.usersInCommuinity,
      followingUsers: followingUsers ?? this.followingUsers,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      churches: churches ?? this.churches,
      churchesList2: churchesList2 ?? this.churchesList2,
      chruchesNotEqualLocation: chruchesNotEqualLocation ?? this.chruchesNotEqualLocation,

      isSelected: isSelected ?? this.isSelected,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
