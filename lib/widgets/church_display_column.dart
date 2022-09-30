import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/church_model.dart';

Widget search_Church_container({required Church church, required BuildContext context}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Container(
            height: 135,
            width: MediaQuery.of(context).size.width * .70,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 102, 102, 103),
                image: DecorationImage(
                    image: CachedNetworkImageProvider(church.imageUrl),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        Text("${church.name}",
            style: TextStyle(fontSize: 20), overflow: TextOverflow.fade),
        Text(
          "${church.members.length} members ~ ${church.location}",
          style: TextStyle(fontSize: 20),
          overflow: TextOverflow.fade,
        ),
      ],
    );
  }