import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPhotoPermission() async {
  // status is enum w/ vals of: granted, restricted, permantly_restricted
  var status = await Permission.photos.status;
  if (status.isGranted)
    return true; // alredy have permission
  else if (status.isDenied) {
    if (await Permission.photos.request().isGranted) {
      return true;
    }
  } else if (await Permission.photos.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
  // app. The only way to change the permission's status now is to let the
  // user manually enable it in the system settings.
  openAppSettings();
  } else {
  openAppSettings();
  }

  return false;
}
