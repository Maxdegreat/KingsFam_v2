import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';

mediaBottomSheet(
    {required KingscordCubit kingscordCubit,
    required BuildContext context,
    required String cmId,
    required String kcId}) {
  return showModalBottomSheet(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<KingscordCubit>(context),
          child: Column(
            children: [
              Container(
                height: 200,
                  width: double.infinity * .75,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImageHelper.pickVideoFromGallery();
                      if (pickedFile != null)
                        kingscordCubit.onUploadVideo(videoFile: pickedFile, cmId: cmId, kcId: kcId);
                    },
                    child: FaIcon(FontAwesomeIcons.film),
                  )),
              Container(
                  width: double.infinity * .75,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImageHelper.pickImageFromGallery(
                          context: context,
                          cropStyle: CropStyle.rectangle,
                          title: 'send');
                      if (pickedFile != null) {
                        kingscordCubit.onUploadImage(pickedFile);
                        kingscordCubit.onSendTxtImg(
                            churchId: cmId, kingsCordId: kcId);
                      }
                    },
                    child: FaIcon(FontAwesomeIcons.fileImage),
                  ))
            ],
          ),
        );
      });
}
