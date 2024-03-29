import 'dart:developer';

import 'package:bloc/bloc.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
//import 'package:rxdart/rxdart.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final UserrRepository _userrRepository;
  final ChurchRepository _churchRepository;
  final AuthBloc _authBloc;
  SearchBloc(
      {required UserrRepository userrRepository,
      required ChurchRepository churchRepository,
      required AuthBloc authBloc})
      : _userrRepository = userrRepository,
        _authBloc = authBloc,
        _churchRepository = churchRepository,
        super(SearchState.initial());

  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    if (event is InitializeUser) {
      yield* _mapLoadUserToState(event);
    } else if (event is UserrSelected) {
      yield* _mapUserrSelectedToState(event);
    } else if (event is AddMember) {
      yield* _mapAddMemberToState(event);
    } else if (event is RemoveMember) {
      yield* _mapRemoveMemberToState(event);
    } else if (event is PaginateChList) {
      yield* _mapPaginateChList(event);
    }
  }



  Stream<SearchState> _mapPaginateChList(PaginateChList event) async* {
    yield state.copyWith(status: SearchStatus.pag);
    List<Church>? newCms = [];
    List<Church>? updatedCms = [];
    final String? lastCmId = state.chruchesNotEqualLocation.isNotEmpty ? state.chruchesNotEqualLocation.last.id : null;
    // log("the last cmId: $lastCmId");
    if (lastCmId != null) {
      newCms = await _churchRepository.grabChurches(limit: 7, lastPostId: lastCmId);
      // log("new cms: ${newCms.length}");
      updatedCms = state.chruchesNotEqualLocation..addAll(newCms);
      // log("updated cms len is: ${updatedCms.length}");
      yield state.copyWith(chruchesNotEqualLocation: updatedCms, status: SearchStatus.initial);
    }
  }

  Stream<SearchState> _mapLoadUserToState(InitializeUser event) async* {
    yield state.copyWith(status: SearchStatus.loading, );
    try {
      
      // CHURCHES IS NOT CURRENTLY BEING USED
      // CHURCHLLIST2 IS CURRENTLY NOT BEING USED
      // USER / LOCATION IS NOT CURRENTLY BEING USED
      List<Church> churchesList3 = await _churchRepository.grabChurches();

      yield state.copyWith(
          user: null,
          churches: [],
          churchesList2: [], //churchesList2,
          chruchesNotEqualLocation: churchesList3,
          status: SearchStatus.initial
      );

    } catch (e) {
      state.copyWith(
          failure: Failure(message: "Check your internet connection"),
          status: SearchStatus.error);
    }
  }

  Stream<SearchState> _mapUserrSelectedToState(UserrSelected event) async* {
    state.copyWith(isSelected: event.isSelected);
  }

  Stream<SearchState> _mapAddMemberToState(AddMember event) async* {
    state.selectedUsers.add(event.member);
    state.copyWith(status: SearchStatus.initial);
  }

  Stream<SearchState> _mapRemoveMemberToState(RemoveMember event) async* {
    state.selectedUsers.remove(event.member);
    state.copyWith(status: SearchStatus.initial);
  }

  void searchUsers(String query) async {
    if (query.isEmpty)
      emit(state.copyWith(users: [], status: SearchStatus.initial));
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final users = await _userrRepository.searchUsers(query: query);
      emit(state.copyWith(users: users, status: SearchStatus.success));
    } catch (e) {
      state.copyWith(
          failure: Failure(message: 'Some Thing went wrong'),
          status: SearchStatus.error);
    }
  }

  // void searchCommuinityUsers(String query, String doc) async {
  //   if (query.isEmpty)
  //     emit(state.copyWith(usersInCommuinity: [], status: SearchStatus.initial));
  //   emit(state.copyWith(status: SearchStatus.loading));
  //   try {
  //     final users = await _churchRepository.searchForUsersInCommuinity(
  //         query: query, doc: doc);
  //     emit(state.copyWith(usersInCommuinity: users));
  //   } catch (e) {
  //     state.copyWith(
  //         failure: Failure(message: 'Some Thing went wrong'),
  //         status: SearchStatus.error);
  //   }
  // }

  void searchUserAdvanced(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial));
    } else {
      try {
        final users = await _userrRepository.searchUsersadvanced(query: query);
        emit(state.copyWith(users: users, status: SearchStatus.success));
      } catch (e) {
        state.copyWith(
            failure: Failure(message: 'Some Thing went wrong'),
            status: SearchStatus.error);
      }
    }
  }

  void searchUserAdvancedAddToCommuinity(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial));
    } else {
      try {
        final users = await _userrRepository.searchUsersAdvancedFollowing(
            query: query, currUserId: _authBloc.state.user!.uid);
        emit(state.copyWith(users: users, status: SearchStatus.success));
      } catch (e) {
        print("Error: ${e.toString()}");
        state.copyWith(
            failure: Failure(message: 'Some Thing went wrong'),
            status: SearchStatus.error);
      }
    }
  }

  void followingUsersList({required String? lastStingId}) async {
    var followingList = await _userrRepository.followingList(
        currUserId: _authBloc.state.user!.uid, lastStringId: lastStingId);
    emit(state.copyWith(followingUsers: followingList));
  }

  void searchChurch(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial));
    } else {
      try {
        //mimick something simular to the search users but add complexity so the
        //search algo works better
        final churches = await _churchRepository.searchChurches(query: query);
        emit(state.copyWith(churches: churches, status: SearchStatus.success));
      } catch (e) {
        state.copyWith(
            failure: Failure(message: 'Some Thing went wrong'),
            status: SearchStatus.error);
      }
    }
  }

  void clearSearchBlocAll() {
    emit(state.copyWith(users: [], selectedUsers: {}));
  }

  void clearSearch() {
    emit(state.copyWith(users: [], status: SearchStatus.initial));
  }
}
