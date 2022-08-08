// used to help decluter pages for navigation

import 'package:flutter/material.dart';
import 'package:kingsfam/config/type_of.dart';
import 'package:kingsfam/screens/screens.dart';

class NavHelper {
  Future<void> navToSnackBar(context) => Navigator.of(context).pushNamed(SnackTimeShopScreen.routeName);

  Future<void> navToCreateSpaces(BuildContext context) =>  Navigator.of(context).pushNamed(CreateComuinity.routeName);

  Future<void> navToCreatePost(BuildContext context) => Navigator.of(context).pushNamed(CreatePostScreen.routeName);

  Future<void> navToBuyPerk(BuildContext context, String type) => Navigator.of(context).pushNamed(BuyPerkScreen.routeName, arguments: BuyPerkArgs(type: type));
}