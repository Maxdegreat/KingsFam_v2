//This file helps with selecting images from gall and croping them

// second task select video from gallerey
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  //IF WE ARE SELECTING A VIDEO FROM GALLERY
  static Future<File?> pickVideoFromGallery() async {
    final pickedFileVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFileVideo != null) return File(pickedFileVideo.path);
  }

  //IF WE ARE SLECTING A IMAGE FROM GALLEREY
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    //image helper works here

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final cropedFile = await ImageCropper.cropImage(
        maxHeight: 500,
        sourcePath: pickedFile.path,
        cropStyle: cropStyle,
        //aspectRatio: ,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Colors.red[400],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(),   
        compressQuality: 100,
      );
      // Image decodedImage = (await decodeImageFromList(cropedFile.readAsBytesSync())) as Image;
      // print("||||||||||||||||||||||\height: ${decodedImage.height}|||||||||||||||||||||||||||");
      return cropedFile;
    }
    return null;
  }

  // other stuff for dir from cam
  static Future<File?> pickImageFromCam({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    //imageHelper works here
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    //checks nullsafty if not null add crop properties
    if (pickedFile != null) {
      final cropedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        cropStyle: cropStyle,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Colors.red[400],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(),
        compressQuality: 100,
      );
      return cropedFile;
    }
    return null;
  }

  //FOR MAKEING VIDEO FROM CAMERA ROLL
  static Future<File?> pickVidFromCam({
    required BuildContext context,
  }) async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) 
      return File(pickedFile.path);
    
    return null;
  }
}
