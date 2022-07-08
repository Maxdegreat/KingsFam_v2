import 'package:flutter/material.dart';

 snackBar({required String snackMessage, required BuildContext context}){
    return ScaffoldMessenger.of(context).showSnackBar( 
      SnackBar(content: Text(snackMessage))
    );
  }