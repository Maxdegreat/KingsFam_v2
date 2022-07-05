

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:kingsfam/helpers/helpers.dart';

import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';

mediaBottomSheet(
    {required KingscordCubit kingscordCubit,
    required BuildContext context,
    required String cmId,
    required String kcId}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    
      context: context,
      builder: (_) {
        
        return BlocProvider.value(
          value: BlocProvider.of<KingscordCubit>(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: double.infinity * .75,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImageHelper.pickVideoFromGallery();
                      if (pickedFile != null)
                        kingscordCubit.onUploadVideo(videoFile: pickedFile, cmId: cmId, kcId: kcId);
                    }, style: ElevatedButton.styleFrom(
                      primary: Colors.amber
                    ),
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
                    style: ElevatedButton.styleFrom(primary: Colors.red[800]),
                    child: FaIcon(FontAwesomeIcons.fileImage),
                  ))
            ],
          ),
        );
      });
}
