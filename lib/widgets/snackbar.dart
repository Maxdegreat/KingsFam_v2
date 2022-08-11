import 'package:flutter/material.dart';

 snackBar({required String snackMessage, required BuildContext context, Color? bgColor}){
    bgColor = bgColor == null ? Colors.white : bgColor;
    return ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text(snackMessage), backgroundColor: bgColor,)
    );
  }