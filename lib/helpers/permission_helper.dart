import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPhotoPermission(BuildContext context) async {
  bool granted = false;
  // status is enum w/ vals of: granted, restricted, permantly_restricted
  var status = await Permission.photos.status;
  if (status.isGranted)
    return true; // alredy have permission
  else if (status.isLimited) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Column(
              children: [
                Text(
                    "Some images or videos can not be selected because you limited photo access to KingsFam"),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    granted = true;
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok")),
              TextButton(
                  onPressed: () {
                    openAppSettings().then((value) {
                      granted = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text("Grant Full Acess"))
            ],
          );
        });
    return true;
  } 
  
  else if (await Permission.photos.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    // openAppSettings();
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Permissions"),
            content: Text(
                "Allow KingsFam Access To Your Photos For The Purpose Of Sharing Post"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Not Now")),
              TextButton(
                  onPressed: () {
                    openAppSettings().then((value) {
                      granted = true;
                    });
                  },
                  child: Text("Ok"))
            ],
          );
        });
    return granted;
  } else {
    
  }

  return granted;
}
