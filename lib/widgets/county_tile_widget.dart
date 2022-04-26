import 'package:flutter/material.dart';


class SubCommuinityTile extends StatelessWidget {
  const SubCommuinityTile({ required this.title,  });
  final title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, width: double.infinity,
      child: Center(child: Text(title,)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[600],
      ),
    );
  }
}