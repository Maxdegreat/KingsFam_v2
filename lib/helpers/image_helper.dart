//This file helps with selecting images from gall and croping them

// second task select video from gallerey
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kingsfam/helpers/permission_helper.dart';


class ImageHelper {
  //IF WE ARE SELECTING A VIDEO FROM GALLERY
  static Future<File?> pickVideoFromGallery(BuildContext context) async {
    requestPhotoPermission(context);
    final pickedFileVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFileVideo != null) {
      // note. when you call picked file for a video in any other screen you should be sure that you call
      // the vid editor if you would like to edit a vdieo
      return File(pickedFileVideo.path);
    } else {
      return null;
    }
  }

  //IF WE ARE SLECTING A IMAGE FROM GALLEREY
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    //image helper works here
    requestPhotoPermission(context);
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final cropedFile = await ImageCropper().cropImage(
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
        compressQuality: 50,
      );

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
      final cropedFile = await ImageCropper().cropImage(
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
        compressQuality: 50,
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
    if (pickedFile != null) return File(pickedFile.path);

    return null;
  }
}
