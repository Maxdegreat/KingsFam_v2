import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

shutterLoadingSearchScreen(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _searchContainer(context),
      const SizedBox(height: 10),
      _textDiscover(context),
      const SizedBox(height: 10),
      _communityShutter(context),
      const SizedBox(height: 10),
      _communityShutter(context),
      const SizedBox(height: 10),
      _communityShutter(context),
      const SizedBox(height: 10),
      _communityShutter(context),

    ],
  );
}

_searchContainer(BuildContext context) {
  return Container(
    height: 20,
    width: double.infinity,
    color: Theme.of(context).colorScheme.secondary,
  );
}

_textDiscover(BuildContext context) {
  return Container(
    height: 20,
    width: MediaQuery.of(context).size.width / 1.7,
    color: Theme.of(context).colorScheme.secondary,
  );
}

_communityShutter(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(width: 25),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _t1(context),
          const SizedBox(height: 10),
          _t2(context),
        ],
      )
    ],
  );
}

_t1(context) => Container(
    width: 70, height: 35, color: Theme.of(context).colorScheme.secondary);
_t2(context) => Container(
    width: 90, height: 45, color: Theme.of(context).colorScheme.secondary);
