import 'package:flutter/material.dart';

snackBar(
    {required String snackMessage,
    required BuildContext context,
    Color? bgColor,
    bool? showLoading}) {
  bgColor = bgColor == null ? Colors.white : bgColor;
  return showLoading == null
      ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(snackMessage),
          backgroundColor: bgColor,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 30, left: 10, right: 10),
        ))
      : showLoading == true
          ? SnackBar(
              content: Container(
                  width: double.infinity,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 10)),
              backgroundColor: bgColor,
            )
          : SnackBar(
              content: Text(snackMessage),
              backgroundColor: bgColor,
            );
}
