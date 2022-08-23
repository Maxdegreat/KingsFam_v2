// used to help decluter pages for navigation

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/search/more_cm_screen.dart';

class NavHelper {
  Future<void> navToSnackBar(context) => Navigator.of(context).pushNamed(SnackTimeShopScreen.routeName);

  Future<void> navToCreateSpaces(BuildContext context) =>  Navigator.of(context).pushNamed(CreateComuinity.routeName);

  Future<void> navToCreatePost(BuildContext context) => Navigator.of(context).pushNamed(CreatePostScreen.routeName);

  Future<void> navToBuyPerk(BuildContext context, String type) => Navigator.of(context).pushNamed(BuyPerkScreen.routeName, arguments: BuyPerkArgs(type: type));

  Future<void> navToUpdateCmTheme(BuildContext context, CommuinityBloc commuinityBloc, String cmName, String cmId) => Navigator.of(context).pushNamed(UpdateCmThemePack.routeName, arguments: UpdateCmThemePackArgs(commuinityBloc: commuinityBloc, cmName: cmName, cmId: cmId));

  Future<void> navToMoreCm(BuildContext context, String type, SearchBloc bloc) => Navigator.of(context).pushNamed(MoreCm.routeName, arguments: MoreCmArgs(type: type, bloc: bloc));
}