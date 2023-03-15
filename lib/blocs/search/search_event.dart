part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class GrabUsersPaginate extends SearchEvent {
  final String currId;
  const GrabUsersPaginate({required this.currId});
}

class PaginateChList1 extends SearchEvent {
  final String currId;
  const PaginateChList1({required this.currId});
}

class PaginateChList extends SearchEvent {
  final String currId;
  const PaginateChList({required this.currId});
}

class UserrSelected extends SearchEvent {
  final bool isSelected;
  UserrSelected({
    required this.isSelected,
  });

  @override
  List<Object?> get props => [isSelected];
}

class AddMember extends SearchEvent {
  final Userr member;
  AddMember({
    required this.member,
  });
  @override
  List<Object?> get props => [member];
}

class RemoveMember extends SearchEvent {
  final Userr member;
  RemoveMember({
    required this.member,
  });

  @override
  List<Object?> get props => [member];
}

class InitializeUser extends SearchEvent {
  final String currentUserrId;

  InitializeUser({
    required this.currentUserrId,
  });
}
