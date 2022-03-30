import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:kingsfam/repositories/storage/base_storage_repository.dart';
import 'package:uuid/uuid.dart';

class StorageRepository extends BaseStorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({
    FirebaseStorage? firebaseStorage,
  }) : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  //steps to upload a new image to firebase
  // 1 - we will be returning a String downloadUrl -----------------
  // 2 - requires a File image and a String ref ----------------------
  // 3 - set final downloadUrl = await _firebaseStorage.ref(PATH AKA ORU VAR REF).putFile( THE IMAGE AS A FILE OR WHATEVER ).then(  (tasksnapshot) => tasksnapshot.ref.getDownllaodUrl() )
  // 4 -  lastly return  the download url
  Future<String> _uploadImage({required File image, required String ref}) async {
    final downloadUrl = await _firebaseStorage
        .ref(ref)
        .putFile(image)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());
    return downloadUrl;
  }

  @override
  Future<String> uploadBannerImage(
      {required String url, required File image}) async {
    var imageId = Uuid().v4();
    //update user pfp image by getting the id
    if (url.isNotEmpty) {
      final exp = RegExp(r'userBanner_(.*).jpg');
      imageId = exp.firstMatch(url)![1]!;
    }
    final downloadUrl = await _uploadImage(
        image: image, ref: 'images/users/userBanner_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadProfileImage(
      {required String url, required File image}) async {
    var imageId = Uuid().v4();
    //update user pfp image by getting the id
    if (url.isNotEmpty) {
      final exp = RegExp(r'userProfile_(.*).jpg');
      imageId = exp.firstMatch(url)![1]!;
    }
    final downloadUrl = await _uploadImage(
        image: image, ref: 'images/users/userProfile_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadPostImage({required File image}) async {
    final imageId = Uuid().v4();
    final downloadUrl =
        await _uploadImage(image: image, ref: 'images/posts/post_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadChatAvatar(
      {required File image, required String url}) async {
    var imageId = Uuid().v4();

    if (url.isNotEmpty) {
      final exp = RegExp(r'chatAvatar_(.*).jpg');
      imageId = exp.firstMatch(url)![1]!;
    }

    final downloadUrl = await _uploadImage(
        image: image, ref: 'images/chats/chatAvatar_$imageId.jpg');
    return downloadUrl;
  }

  //----------------------------------------------------------------------
  @override
  Future<String> uploadChurchImage(
      {required String url, required File image}) async {
    var imageId = Uuid().v4();

    if (url.isNotEmpty) {
      final exp = RegExp(r'churchAvatar_(.*).jpg');
      imageId = exp.firstMatch(url)![1]!;
    }
    final downloadUrl = await _uploadImage(
        image: image, ref: 'images/churches/churchAvatar_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadChatImage({required File image}) async {
    var imageId = Uuid().v4;
    final downloadUrl = await _uploadImage(
        image: image, ref: 'images/chats/chatImage_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadPostVideo({required File video}) async {
    final imageId = Uuid().v4();
    final downloadUrl =
        await _uploadImage(image: video, ref: 'videos/posts/post_$imageId.jpg');
    return downloadUrl;
  }

  @override
  Future<String> uploadKingsCordImage({required File imageFile}) async {
    final imageId = Uuid().v4();
    final downloadUrl = await _uploadImage(
        image: imageFile, ref: 'images/kings_cord/kingsCordImage_$imageId.jpg');
    return downloadUrl;
  }
}
