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
  SearchBloc({
    required UserrRepository userrRepository,
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
    }
  }

  // In mapLoadUserToState we also init the instances of commuinitys and the user explore in the search page
  Stream<SearchState> _mapLoadUserToState(InitializeUser event) async* {
    yield state.copyWith(status: SearchStatus.loading);
    try {
      print("Now in the map load user to state");
      Userr user = await _userrRepository.getUserrWithId(userrId: event.currentUserrId);
      print("we now have the user");
      List<Church> churches = await _churchRepository.grabChurchWithLocation(location: user.location);
      
      // CHURCHLLIST2 IS CURRENTLY NOT BEING USED
      // List<Church> churchesList2 =
          // await _churchRepository.grabChurchWithSpecial(special: "#tiktok");
      List<Church> churchesList3 = await _churchRepository.grabChurchAllOver(location: user.location);
      print("just grabed some churches");

      // final userExploreController = BehaviorSubject<List<DocumentSnapshot>>();
      List<Userr> userExploreList = await _userrRepository.grabUserExploreListFirst10(user, 5, event.currentUserrId);
      print("just grabed the users");
      
      // await _userrRepository.grabUserExploreListNext10(ownerId);
      print("now setting state to init ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      yield state.copyWith(
          user: user,
          churches: churches,
          churchesList2: [], //churchesList2,
          churchesList3: churchesList3,
          userExploreList: userExploreList,//userExploreList,
          status: SearchStatus.initial);
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
    state.users.remove(event.member);
    state.copyWith(status: SearchStatus.initial);
  }

  Stream<SearchState> _mapRemoveMemberToState(RemoveMember event) async* {
    state.selectedUsers.remove(event.member);
    state.users.insert(0, event.member);
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

  void clearSearch() {
    emit(state.copyWith(users: [], status: SearchStatus.initial));
  }
}
