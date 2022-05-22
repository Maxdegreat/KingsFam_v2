import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
class KFCrownV2 extends StatelessWidget {
  const KFCrownV2();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      color: Colors.black,
      child: RiveAnimation.asset('assets/crown/KFCrownV2.riv'),
    );
  }
}