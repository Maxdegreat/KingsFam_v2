
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/extraTools.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/build_church/roles_definition.dart';

part 'buildchurch_state.dart';

/*
  im thinking admin could be a string then i can also have a bool isAdmin
  if the string admin is equal to isAdmin then give special abilities like update the
  church name and about and location and image and that jazzz 
*/
class BuildchurchCubit extends Cubit<BuildchurchState> {
  final ChurchRepository _churchRepository;
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final UserrRepository _userrRepository;
  final CallRepository _callRepository;
  BuildchurchCubit({
    required ChurchRepository churchRepository,
    required StorageRepository storageRepository,
    required AuthBloc authBloc,
    required CallRepository callRepository,
    required UserrRepository userrRepository,
  })  : _churchRepository = churchRepository,
        _storageRepository = storageRepository,
        _authBloc = authBloc,
        _userrRepository = userrRepository,
        _callRepository = callRepository,
        super(BuildchurchState.initial());
  
  final _fb = FirebaseFirestore.instance;

  // void getKingsCords({required String commuinityId}) async {
  //   var lst = await _churchRepository.getCommuinityCords(churchId: commuinityId);
  //   emit(state.copyWith(kingsCords: lst));
  // }

  // void getCalls({required String commuinityId}) async {
  //   var lst = await _callRepository.getCommuinityCalls(commuinityId: commuinityId);
  //   emit(state.copyWith(calls: lst));
  // }

  Future<void> makeKingsCord({required Church commuinity, required String cordName}) async {
    if (state.kingsCords.length < 7) {
      KingsCord? kc = await  _churchRepository.newKingsCord2(ch: commuinity, cordName: cordName);
      var lst = state.kingsCords;
      lst.add(kc);
      emit(state.copyWith(kingsCords: lst ));
    }
  }

  Future<void> makeCallModel({required Church commuinity, required String callName}) async {
    if (state.calls.length < 7) {
      CallModel call = await _callRepository.createCall2(commuinity: commuinity , callName: callName);
      var lst = state.calls;
      lst.add(call);
      emit(state.copyWith(calls: lst ));
    }
  }

  // get commuinity posts
  Future<void> getCommuinityPosts(Church cm) async {

    List<Post?> posts = await _churchRepository.getCommuinityPosts(cm: cm);
    
    emit(state.copyWith(posts: posts));
  }

  //void function to update image url
  void onImageChanged(File image) {
    emit(state.copyWith(imageFile: image, status: BuildChurchStatus.initial));
  }

  //void function to update name
  void onNameChanged(String name) {
    emit(state.copyWith(name: name, status: BuildChurchStatus.initial));
  }

  //void function to update about
  void onAboutChanged(String about) {
    emit(state.copyWith(about: about, status: BuildChurchStatus.initial));
  }

  //void function to upadte hashTags list
  void onHashTag(String hashTags) {
    emit(state.copyWith(
        initHashTag: hashTags, status: BuildChurchStatus.initial));
  }

  //void function to update location
  void onLocationChanged(String location) {
    emit(state.copyWith(location: location, status: BuildChurchStatus.initial));
  }

  //void function to update the admin and on create the admin should init be the maker maybe do that outside cubit
  void onAdminsAdded(Set<String> ids) => emit(state.copyWith(adminIds: ids));
  
  void onAdminAdded(String id) {
    var lst = state.adminIds;
    lst.add(id);
    emit(state.copyWith(adminIds: lst));
  }
  
  void onAdminRemoved(String id) {
    var lst = state.adminIds;
    lst.remove(id);
    emit(state.copyWith(adminIds: lst));
  }

  //void function to add the users to the members list
  //TODO
  void onMemberIdsAdded(List<String> userrIds) {
    emit(state.copyWith(memberIds: userrIds, status: BuildChurchStatus.initial));
  }

  void onSubmiting() {
    emit(state.copyWith(isSubmiting: true));
  }

  //void functoion to invite users A.K.A populate list
  // future bool to see if a user is in commuinity or not
   isCommuinityMember (Church commuinity) async {
     final userId = _authBloc.state.user!.uid;
     bool isMember = await  _churchRepository.isCommuinityMember(commuinity: commuinity, authorId: userId);
     print("Member status :$isMember for checking if commuinity member");
     emit(state.copyWith( isMember: isMember ));
     print("state member status: ${state.isMember}");
   }


  //void function to upload church
  void submit() async {
    print("We are in the submit function");
    emit(state.copyWith(status: BuildChurchStatus.loading));
    try {
      final imageUrl = await _storageRepository.uploadChurchImage(url: '', image: state.imageFile!);
      //handels casing for search prams
      List<String> caseList = AdvancedQuerry().advancedSearch(query: state.name);
      emit(state.copyWith(caseSearchList: caseList, status: BuildChurchStatus.loading));

      //handel the making of hash tags
      if (state.initHashTag != null) {
        List<String> hashTags = AdvancedQuerry().advancedHashTags(hashTags: state.initHashTag!);
        emit(state.copyWith(hashTags: hashTags, status: BuildChurchStatus.loading));
      }

      //============================================================
      //populate the member info

      Map<Userr, Timestamp> mems = {};
      for (int i = 0; i < state.memberIds.length; i++) {
        final user = await _userrRepository.getUserrWithId(userrId: state.memberIds[i]);
        mems[user]=Timestamp(0, 0); // may not work so maybe make a list then emit list o
      
      }


      emit(state.copyWith(members: mems));
      //-----------------------------------
      //----------------------------------------------------------
      
      //===========================================================
      //the build of the initial church
      final commuinity = Church(
          searchPram: state.caseSearchList!,
          hashTags: state.hashTags ?? null,
          name: state.name,
          location: state.location,
          imageUrl: imageUrl,
          members: state.members,
          events: [],
          about: state.about,
          size: state.memberIds.length,
          recentMsgTime: Timestamp(1,0),
        );
        // build the church mem 
        //final ChurchMembers churchMemberIds = ChurchMembers(ids: state.memberIds);


      // make a kings cord on the init of making the church, this is the default room
      final recentSender = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);
      


      
      //call my church repo and use the upload method to launch commuinity to firestore
      await _churchRepository.newChurch(church: commuinity, recentSender: recentSender);
      
      //-------------------------------------------------------
      print("The church is made my boi");
      emit(state.copyWith(status: BuildChurchStatus.success));
    } catch (err) {
      emit(state.copyWith(status: BuildChurchStatus.error ,failure: Failure(message: 'check your internet connection fam')));
    }
    
  }

  Future <void> lightUpdate(commuinityId) async {

    emit(state.copyWith(status: BuildChurchStatus.loading));

    FirebaseFirestore.instance.collection(Paths.church).doc(commuinityId).update({'name': state.name});

    emit(state.copyWith(status: BuildChurchStatus.success));
  }


/*
  this is information that will come after the commuinity has been made.
  for example, we will call the create main room or events. so basically in layman terms
  everything under here will come after the initial call
*/  

  // ignore: non_constant_identifier_names
  // Future<void> make_main_room(Church commuinity, String cordName) async {
  //   //=============================================================
  //   //geters
  //   print("we are in the make main room");
  //   final recentSenderGetter = await _userrRepository.getUserrWithId(
  //       userrId: _authBloc.state.user!.uid);

  //   final kingsCord = KingsCord(
  //       tag: commuinity.id!,
  //       cordName: cordName,
  //       // memberInfo: commuinity.memberInfo,
  //       recentMessage: "whats good Gods People!",
  //       recentSender: recentSenderGetter.username,
  //     );
  //       //send off the repo
  //       await _churchRepository.newKingsCord(
  //       church: commuinity, kingsCord: kingsCord);

  //   //--------------------------------------------------------------
  // }

  //this is for the commuinity screen, this is used if we need to find all users in the commuinity
  // we will paginatee... eventually, but basically we will grab all users via their id and return back 
  // a bucket with the users 

  Future<List<Userr>> commuinityParcticipatents({required List<String> ids}) async {
    
    List<Userr> bucket =[];

    Future<void> wait() async {
      for (int i = 0; i < ids.length; i++) {
        final user = await _userrRepository.getUserrWithId(userrId: ids[i]);
        bucket.add(user);
      }
    }

      await wait();
      return bucket;
  }

  bool isAdmin({required Church commuinity}) {
    var ids = commuinity.members.keys.map((e) => e.id).toList();
    return ids.contains(_authBloc.state.user!.uid);
  }

  void makeAdmin({required Userr user, required Church commuinity}) async  {
    //TODO just make admin set and add the user id to the admin set.
    // Map<String, dynamic> usermap = {
    //   'isAdmin' : true,
    //   'username': user.username,
    //   'pfpImageUrl': user.profileImageUrl,
    //   'colorPref' : user.colorPref,
    //   'email': user.email,
    //   'token': user.token,
    // };
    // //memberInfo[userrId] = userMap;  //prob best to actually check that the id exist in the map...
    // commuinity.memberInfo[user.id] = usermap;
    // final Church updatedCommuinity = commuinity.copyWith(memberInfo: state.memberInfo[_authBloc.state.user!.uid]);
    // _churchRepository.updateCommuinity(commuinity: updatedCommuinity);
  }

 

  void updateCommuinityName({required Church commuinity, required String name}) async {
    emit(state.copyWith(status: BuildChurchStatus.loading));
    try {
      String imageUrl = commuinity.imageUrl;
      if (state.imageFile != null) {
        imageUrl = await _storageRepository
          .uploadChatAvatar(image: state.imageFile!, url: commuinity.imageUrl);
      }

      var commuinityName = commuinity.name;
      if (state.name.isNotEmpty) 
        commuinityName = state.name;

      Church updatedCommuinity = commuinity.copyWith(name: commuinityName, imageUrl: imageUrl);
      await _churchRepository.updateCommuinity(commuinity: updatedCommuinity);
      
    } catch (e) {
      print("error: $e");
    }
    FirebaseFirestore.instance.collection(Paths.church).doc(commuinity.id).update(commuinity.copyWith(name: name).toDoc());
  }

  Future < List<Userr> >grabCurrFollowing () async {
    final uid = _authBloc.state.user!.uid;
    final currFollowingIds = await _userrRepository.listOfIdsCurrFollowing(uid: uid);
    List<Userr> bucket = [];
    Future<void> populateBucket () async {
      
      for ( String x in currFollowingIds ) {
        final user = await _userrRepository.getUserrWithId(userrId: x);
        bucket.add(user);
      }

    }

    await populateBucket();
    return bucket;
  }

  Future<void> inviteToCommuinity({required String toUserId, required Church commuinity}) async {
    final currid = _authBloc.state.user!.uid;
    final fromUser = await _userrRepository.getUserrWithId(userrId: currid);
    _churchRepository.inviteUserToCommuinity(fromUser: fromUser, toUserId: toUserId, commuinity: commuinity);
  }

  Future<void> onJoinCommuinity ({required Church commuinity }) async {
    final userrId = _authBloc.state.user!.uid;
    final user = await _userrRepository.getUserrWithId(userrId: userrId);
    
    _churchRepository.onJoinCommuinity(commuinity: commuinity, user: user);
  }

  Future<void> onLeaveCommuinity( {required Church commuinity}) async {
    final userrId = _authBloc.state.user!.uid;
    _churchRepository.leaveCommuinity(commuinity: commuinity, currId: userrId);
  }
}
