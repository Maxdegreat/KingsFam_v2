import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';

import '../models/church_model.dart';

Widget search_Church_container(
    {required Church church, required BuildContext context}) {
  return Container(
    // color: Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 10),
    // width: MediaQuery.of(context).size.shortestSide ,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cmImgae(church.imageUrl),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (MediaQuery.of(context).size.shortestSide / 1.65),
              padding: const EdgeInsets.only(right: 16),
              child: _cmName(church.name, context)),
            const SizedBox(height: 10),
            Container(
              width: (MediaQuery.of(context).size.shortestSide / 1.65),
              padding: const EdgeInsets.only(right: 16),
              child: _cmAbout(church.about, context)),
          ],
        )
      ],
    ),
  );
}

_cmImgae(imgUrl) => Container(
  height: 100,
  width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
          image: DecorationImage(
              image: CachedNetworkImageProvider(imgUrl), fit: BoxFit.cover)),
    );

Text _cmName(name, context) => Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w700));
Text _cmAbout(about, context) => Text(about, maxLines: 2, overflow: TextOverflow.fade,  style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w400));


Widget churchDisplayContainer(BuildContext context, Church cm) {
  return Container(
    padding: EdgeInsets.only(top: 3, right: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(7)
    ),
    child: Container(
      padding: const EdgeInsets.all(7),
     decoration: BoxDecoration(
       color: Theme.of(context).colorScheme.secondary,
       borderRadius: BorderRadius.circular(7)
     ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cmImgae(cm.imageUrl),
          const SizedBox(height: 20),
          _cmName(cm.name, context),
          const SizedBox(height: 10),
          _cmAbout(cm.about, context),
        ],
      ),
    )
  );
}
