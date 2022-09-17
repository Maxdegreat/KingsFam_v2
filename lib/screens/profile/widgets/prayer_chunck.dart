import 'package:flutter/material.dart';
import 'package:kingsfam/models/prayer_modal.dart';

import '../../../models/user_model.dart';

Future<void> PrayerChunk (BuildContext context, String pm, Userr userr) {
  return showModalBottomSheet(context: context, builder: (_) {
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(Icons.drag_handle_rounded)),
          Text(userr.username + "\'s Prayer"),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            child: Text(pm, softWrap: true,),
          )
        ],
      ),
    );
  });
}