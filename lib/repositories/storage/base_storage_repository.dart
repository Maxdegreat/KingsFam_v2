import 'dart:io';

abstract class BaseStorageRepository {
//========PROFILE =================================
  Future<String> uploadBannerImage({required String url, required File image});

  Future<String> uploadProfileImage({required String url, required File image});

//===================================================================
  Future<String> uploadChatAvatar({required File image, required String url});

  Future<String> uploadChatImage({required File image});

  //====CHURCH  / COMMUINITY =====================================

  Future<String> uploadChurchImage({required String url, required File image});
    //sub class in church / commuinity
  Future<String> uploadKingsCordImage({required File imageFile});
  //Future<String> uploadKingsCordVideo({required File videoFile});

  //--------POST----------------------------------------------------

  Future<String> uploadPostVideo({
    required File video,
  });

  Future<String> uploadPostImage({required File image});
}
