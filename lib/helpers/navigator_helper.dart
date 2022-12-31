// used to help decluter pages for navigation

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/helpers/vid_helper.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/search/more_cm_screen.dart';

import '../screens/search/widgets/show_following.dart';


class NavHelper {
  Future<void> navToSnackBar(context, String currUserId) => Navigator.of(context).pushNamed(SnackTimeShopScreen.routeName, arguments: SnackTimeArgs(currUserId: currUserId));

  Future<void> navToBuyPerk(BuildContext context, String type) => Navigator.of(context).pushNamed(BuyPerkScreen.routeName, arguments: BuyPerkArgs(type: type));

  Future<void> navToUpdateCmTheme(BuildContext context, CommuinityBloc commuinityBloc, String cmName, String cmId) => Navigator.of(context).pushNamed(UpdateCmThemePack.routeName, arguments: UpdateCmThemePackArgs(commuinityBloc: commuinityBloc, cmName: cmName, cmId: cmId));

  Future<void> navToMoreCm(BuildContext context, String type, SearchBloc bloc) => Navigator.of(context).pushNamed(MoreCm.routeName, arguments: MoreCmArgs(type: type, bloc: bloc));

  Future<void> navToShowFollowing(BuildContext context, String usrIdToViewFollowing, ProfileBloc profileBloc, BuildContext ctxFromPf, String type) => Navigator.of(context).pushNamed(ShowFollowingList.routeName, arguments: ShowFollowingListArgs(usrId: usrIdToViewFollowing, bloc: profileBloc, ctxFromPf: ctxFromPf, type: type ));

  // Future<void> navToImageEditor(BuildContext context, File file) => Navigator.of(context).pushNamed(ImageEditorExample.routeName, arguments: ImageEditorArgs(file: file));

  Future<void> navToPostContent(BuildContext context, File editedImage, String type) => Navigator.of(context).pushNamed(PostContentScreen.routeName, arguments: PostContentArgs(content: editedImage, type: type));

  Future<void> navToVideoEditor(BuildContext context, File vidF) => Navigator.of(context).pushNamed(VideoEditor.routeName, arguments: VideoEditorArgs(file: vidF));
}