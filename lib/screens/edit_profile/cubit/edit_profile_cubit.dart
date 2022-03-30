import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/extraTools.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  //user repo, storage repo, profile bloc
  final UserrRepository _userrRepository;
  final StorageRepository _storageRepository;
  final ProfileBloc _profileBloc;

  EditProfileCubit({
    required UserrRepository userrRepository,
    required StorageRepository storageRepository,
    required ProfileBloc profileBloc,
  })  : _userrRepository = userrRepository,
        _storageRepository = storageRepository,
        _profileBloc = profileBloc,
        super(EditProfileState.initial()) {
    final userr = _profileBloc.state.userr;
    emit(state.copyWith(username: userr.username, bio: userr.bio));
  }

  void bannerImageChanged(File image) {
    emit(state.copyWith(bannerImage: image, status: EditProfileStatus.initial));
  }

  void profileImageChanged(File image) {
    emit(
        state.copyWith(profileImage: image, status: EditProfileStatus.initial));
  }

  void bioChanged(String bio) {
    emit(state.copyWith(bio: bio, status: EditProfileStatus.initial));
  }

  void usernameChanged(String username) {
    emit(state.copyWith(username: username, status: EditProfileStatus.initial));
  }

  void locationChanged(String location) {
    emit(state.copyWith(location: location, status: EditProfileStatus.initial));
  }

  void updateColorPreff(String hexcolor) {
    emit(state.copyWith(colorPref: hexcolor, status: EditProfileStatus.submitting));

    final userr = _profileBloc.state.userr;
    FirebaseFirestore.instance.collection(Paths.users).doc(userr.id).update({'colorPref': state.colorPref});

    emit(state.copyWith( status: EditProfileStatus.initial ));
  }

  void submit() async {
    emit(state.copyWith(status: EditProfileStatus.submitting));

    try {

      final userr = _profileBloc.state.userr;

      var colorPref = userr.colorPref;
      // ignore: unnecessary_null_comparison
      if (state.colorPref != "" || state.colorPref != null) {
        colorPref = state.colorPref;
      }

      var profileImageUrl = userr.profileImageUrl;
      if (state.profileImage != null) {
        profileImageUrl = await _storageRepository.uploadProfileImage(
            image: state.profileImage!, url: profileImageUrl);
      }

      var bannerImageUrl = userr.bannerImageUrl;
      if (state.bannerImage != null) {
        bannerImageUrl = await _storageRepository.uploadBannerImage(
            image: state.bannerImage!, url: bannerImageUrl);
      }

      List<String> usernameSearchCase = 
      AdvancedQuerry().advancedSearch(query: state.username);

      print("The user color preff is ${userr.colorPref}");

      final updatedUserr = userr.copyWith(
          username: state.username,
          usernameSearchCase: usernameSearchCase ,
          bio: state.bio,
          profileImageUrl: profileImageUrl,
          bannerImageUrl: bannerImageUrl,
          location: state.location,
          colorPref: colorPref,
        );

      await _userrRepository.updateUserr(userr: updatedUserr);
      _profileBloc.add(ProfileLoadUserr(userId: userr.id));
      emit(state.copyWith(status: EditProfileStatus.success));
    } catch (e) {
      emit(state.copyWith(
          status: EditProfileStatus.error,
          failure:
              Failure(message: 'mmm, there\'s an error updating ur profile')));
    }
  }
}
