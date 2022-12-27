import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kingsfam/camera/bloc/camera_screen.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/helpers/vid_helper.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/create_post/cubit/create_post_cubit.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../helpers/image_helper.dart';
import '../../repositories/church/church_repository.dart';
import '../../repositories/storage/storage_repository.dart';
import '../search/search_screen.dart';

createMediaPopUpSheet({required BuildContext context}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(child: Icon(Icons.drag_handle)),
            columnView(context),
          ],
        ),
      );
    } 
  );
}

 Widget columnView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        GestureDetector(
          onTap: () async {

            List<CameraDescription> _cameras = <CameraDescription>[];
            _cameras = await availableCameras();
            Navigator.of(context).pushNamed(CameraScreen.routeName, arguments: CameraScreenArgs(cameras: _cameras));

            // final pickedFile = await ImageHelper.pickImageFromGallery(
            //     context: context,
            //     cropStyle: CropStyle.rectangle,
            //     title: "Croping Post");
            // if (pickedFile != null) {
            //   // NavHelper().navToImageEditor(context, File(pickedFile.path));
            //   // NavHelper().navToPostContent(context, pickedFile, "image");
            // }


          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 25,
                width: 75,
                child: Icon(Icons.camera_alt_outlined, color: Theme.of(context).iconTheme.color),
                decoration: (BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5))
                  ),
              ),
              Text(
                "Share whats happening",
                style: Theme.of(context).textTheme.bodyText1,
              )
            ],
          ),
        ),

        SizedBox(height: 20),

        GestureDetector(
          onTap: () async {
            final pickedFile = await ImageHelper.pickImageFromGallery(
                context: context,
                cropStyle: CropStyle.rectangle,
                title: "Croping Post");
            if (pickedFile != null) {
              // NavHelper().navToImageEditor(context, File(pickedFile.path));
              NavHelper().navToPostContent(context, pickedFile, "image");
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 25,
                width: 75,
                child: Icon(Icons.image, color: Theme.of(context).iconTheme.color),
                decoration: (BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5))),
              ),
              Text(
                "Upload image from gallery",
                style: Theme.of(context).textTheme.bodyText1,
              )
            ],
          ),
        ),
        // ------------------------------------------------> video from gall below image above <<<<<<<<<<<<<<<<<<< READ THAT B4 ATTEMPT TO READ CODE
        SizedBox(
          height: 20,
        ),
        // GestureDetector(
        //   onTap: () async {
        //     final pickedFile = await ImageHelper.pickVideoFromGallery(context);
        //     if (pickedFile != null) {
             
        //       // await NavHelper().navToVideoEditor(context, pickedFile) /* .then((value) => Navigator.of(context).pop())  */ ;
        //       // NavHelper().navToPostContent(context, pickedFile, 'video');
        //       NavHelper().navToPostContent(context, pickedFile, 'video');
        //       // await Future.delayed(Duration(seconds: 1));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
        //       // Navigator.of(context).pop();
        //     }
        //   },
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Container(
        //         height: 25,
        //         width: 75,
        //         child: Icon(Icons.video_library, color: Theme.of(context).iconTheme.color),
        //         decoration: (BoxDecoration(
        //             color: Colors.transparent,
        //             borderRadius: BorderRadius.circular(5))),
        //       ),
        //       Text("Upload video from gallery",
        //           style: Theme.of(context).textTheme.bodyText1)
        //     ],
        //   ),
        // ),
      ],
    );
  }