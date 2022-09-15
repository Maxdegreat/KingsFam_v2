import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/helpers/vid_helper.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/create_post/cubit/create_post_cubit.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../helpers/image_helper.dart';
import '../../repositories/church/church_repository.dart';
import '../../repositories/storage/storage_repository.dart';
import '../search/search_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();

  //1 make route name
  static const String routeName = '/createPost';
  //2 make the route function
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => CreatePostScreen(),
    );
  }
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: columnView(),
      ),
    );
  }

  // =======================================================================================================================================

  Widget columnView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
            children: [
              Container(
                height: 25,
                width: 75,
                child: Icon(Icons.image),
                decoration: (BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(5))),
              ),
              Text(
                "Upload Image From Gallery",
                style: GoogleFonts.aBeeZee(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              )
            ],
          ),
        ),
        // ------------------------------------------------> video from gall below image above <<<<<<<<<<<<<<<<<<< READ THAT B4 ATTEMPT TO READ CODE
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () async {
            final pickedFile = await ImageHelper.pickVideoFromGallery();
            if (pickedFile != null) {
              log("we can see that the picked file is not null, moving to the vid editor");
              // await NavHelper().navToVideoEditor(context, pickedFile) /* .then((value) => Navigator.of(context).pop())  */ ;
              // NavHelper().navToPostContent(context, pickedFile, 'video');
              NavHelper().navToPostContent(context, pickedFile, 'video');
              // await Future.delayed(Duration(seconds: 1));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
              // Navigator.of(context).pop();
            }
          },
          child: Row(
            children: [
              Container(
                height: 25,
                width: 75,
                child: Icon(Icons.video_library),
                decoration: (BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(5))),
              ),
              Text("Upload Video From Gallery",
                  style: GoogleFonts.aBeeZee(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20))
            ],
          ),
        ),
      ],
    );
  }
}