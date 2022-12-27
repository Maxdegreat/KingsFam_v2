import 'package:flutter/material.dart';

class HollowCirclePainter extends CustomPainter {

  final Color c;

  HollowCirclePainter({required this.c});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = this.c
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}