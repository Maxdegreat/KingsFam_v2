
import 'package:flutter/material.dart';


// this is used when you select an image and want the image to scale instead of a plain page route.
class ScalePageRoute extends PageRouteBuilder {
  final Widget child;
  ScalePageRoute({required this.child}) : super(
    transitionDuration: Duration(seconds: 1),
    pageBuilder: (
      context, 
      animation, 
      secondaryAnimation
    ) => child
  );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}