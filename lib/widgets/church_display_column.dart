import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';

import '../models/church_model.dart';

Widget search_Church_container(
    {required Church church, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      // height: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.width * .70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0, left: 12, right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height / 10,
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(church.imageUrl),
                          fit: BoxFit.cover),
                    )),
                SizedBox(height: 10),
                Text(
                  church.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  church.about,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center
                ),
                SizedBox(height: 2),
                Text(
                  "Members: ${church.size}",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topRight,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.onPrimary,
              ]),
          // border:Border.all(color: Colors.amber, width: .5),
          borderRadius: BorderRadius.circular(10.0)),
    ),
  );

  // Column(
  //   mainAxisAlignment: MainAxisAlignment.start,
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
  //       child: Container(
  //         height: MediaQuery.of(context).size.height / 5,
  //         width: MediaQuery.of(context).size.width * .70,
  //         decoration: BoxDecoration(
  //             gradient: LinearGradient(),
  //             image: DecorationImage(
  //                 image: CachedNetworkImageProvider(church.imageUrl),
  //                 fit: BoxFit.cover),
  //             borderRadius: BorderRadius.circular(5.0)),
  //       ),
  //     ),
  //     Text("${church.name}",
  //         style: TextStyle(fontSize: 20), overflow: TextOverflow.fade),
  //     Text(
  //       "${church.size} members ~ ${church.location}",
  //       style: TextStyle(fontSize: 20),
  //       overflow: TextOverflow.fade,
  //     ),
  //   ],
  // );
}
