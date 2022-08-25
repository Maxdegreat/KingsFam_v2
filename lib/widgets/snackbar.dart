import 'package:flutter/material.dart';

 snackBar({required String snackMessage, required BuildContext context, Color? bgColor, bool? showLoading}){
    bgColor = bgColor == null ? Colors.white : bgColor;
    return showLoading == null ? ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text(snackMessage), backgroundColor: bgColor,)
    ) : showLoading == true ? 
      SnackBar(content: Container(width: double.infinity, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 10)), backgroundColor: bgColor,)
       : SnackBar(content: Text(snackMessage), backgroundColor: bgColor,);
  }