// this is the commuinity screen here we shold be able to acess many screens including some settings maybe if ur admin tho
// on the main room we need to pass a list of member ids which this, the church / commuinity contains. so will extract it and make the main room

//esentally this has the main room, events, storyes ,calls

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/camera/bloc/camera_screen.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/helpers/clipboard.dart';
import 'package:kingsfam/helpers/cm_perm_handler.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';

import 'package:kingsfam/helpers/helpers.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/build_church/cubit/buildchurch_cubit.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
// ignore: unused_import
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/screens/commuinity/wrapers/cm_widgets.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';

import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/main_drawer.dart';
import 'package:kingsfam/widgets/main_drawer_end.dart';
import 'package:kingsfam/widgets/show_alert_dialog.dart';
import 'package:kingsfam/widgets/widgets.dart';
// ignore: unused_import
import 'package:flutter/src/painting/gradient.dart' as paint;
import 'package:kingsfam/screens/commuinity/actions.dart';

// ignore: unused_import
import '../profile/bloc/profile_bloc.dart';
// ignore: unnecessary_import
import 'screens/kings cord/widgets/display_msg.dart';

part 'wrapers/community_screen_wraper.dart';
part 'wrapers/community_screen_methods.dart';

class CommuinityScreenArgs {
  final Church commuinity;
  final bool showDrawer;
  CommuinityScreenArgs({required this.commuinity, this.showDrawer = false});
}

class CommuinityScreen extends StatefulWidget {
  final Church commuinity;
  final bool showDrawer;
  final ChatscreenBloc? chatScreenBloc;

  const CommuinityScreen(
      {Key? key,
      required this.commuinity,
      required this.showDrawer,
      this.chatScreenBloc})
      : super(key: key);
  static const String routeName = '/CommuinityScreen';
  static Route route({required CommuinityScreenArgs args}) {
    // log("do we reach the bloc stuff???"); done later down in file
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => CommuinityScreen(
              commuinity: args.commuinity,
              showDrawer: args.showDrawer,
            ));
  }
  @override
  _CommuinityScreenState createState() => _CommuinityScreenState();
}

class _CommuinityScreenState extends State<CommuinityScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _txtController;
  late ScrollController _scrollController;

  late NativeAd _nativeAd;
  bool _isNativeAdLoaded = false;
  void _createNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        factoryId: "listTile",
        listener: NativeAdListener(onAdLoaded: (_) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("chatsScreen ad error: ${error.toString()}");
        }),
        request: const AdRequest());
    _nativeAd.load();
  }

  @override
  void initState() {
    _createNativeAd();
    
    context.read<BottomnavbarCubit>().showBottomNav(true);
    super.initState();
    _txtController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _nativeAd.dispose();
    _txtController.dispose();
    _scrollController.dispose();
    // context.read<CommuinityBloc>().close();
    // context.read<CommuinityBloc>().dispose();
    super.dispose();
  }
  //String _currentCmId = widget.commuinity.id!;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userId = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider<CommuinityBloc>(
      create: (context) {
        log("Passing through bloc consumer");
        return CommuinityBloc(
          authBloc: context.read<AuthBloc>(),
          churchRepository: context.read<ChurchRepository>(),
          storageRepository: context.read<StorageRepository>(),
          userrRepository: context.read<UserrRepository>(),
        );
      },
      child: BlocConsumer<CommuinityBloc, CommuinityState>(
          listener: (context, state) {
        if (state.status == CommuintyStatus.updated) {
          log("we are updating the state of the cm ya dig");
          setState(() {});
        }
        if (state.status == CommuintyStatus.error) {
          ErrorDialog(
            content:
                'hmm, something went worong. check your connection - ecode: commuinityScreenError: ${state.failure.code}',
          );
        }
        if (state.status == CommuintyStatus.armormed) {
          AlertDialogKf(
              title: "Request access to join",
              content:
                  "This is a armormed community. You must be admitted to join this community",
              cb: () {
                context
                    .read<CommuinityBloc>()
                    .requestToJoin(widget.commuinity, userId)
                    .then((value) => snackBar(
                        snackMessage: "Your request to join has been sent.",
                        context: context));
              },
              cbTxt: "Request");
        } else if (state.status == CommuintyStatus.shielded) {
          AlertDialogKf(
              title: "Request access to join",
              content:
                  "This is a armormed shielded. You can look around but you must be admitted to join this community",
              cb: () {
                context
                    .read<CommuinityBloc>()
                    .requestToJoin(widget.commuinity, userId)
                    .then((value) => snackBar(
                        snackMessage: "Your request to join has been sent.",
                        context: context));
              },
              cbTxt: "Request");
        } else if (state.requestStatus == RequestStatus.pending) {
          AlertDialogKf(
              title: "Request Pending",
              content:
                  "Hey, your request to join is currently pending. You will recieve a notification when there is an update",
              cb: () => Navigator.of(context).pop(),
              cbTxt: "Thanks");
        }
      }, builder: (context, state) {
        if (context.read<CommuinityBloc>().state.cmId !=
            widget.commuinity.id!) {
          context
              .read<CommuinityBloc>()
              .updateCmId(widget.commuinity.id!, widget.commuinity);
        }
        return Scaffold(
            drawerEdgeDragWidth: MediaQuery.of(context).size.width / 1.7,
            drawer: widget.showDrawer
                ? MainDrawer()
                : null,
            endDrawer: MainDrawerEnd(
              memberBtn(
                  cmBloc: context.read<CommuinityBloc>(),
                  cm: widget.commuinity,
                  context: context),
              settingsBtn(
                  cmBloc: context.read<CommuinityBloc>(),
                  cm: widget.commuinity,
                  context: context),
              context,
            ),
              body: SafeArea(
              child: state.status == CommuintyStatus.armormed
                  ?
                  // status is armormed
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "This is a armormed community so it is entirley private. Please wait for your request to be approved in order to join",
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 7),
                            Icon(Icons.health_and_safety_outlined, size: 50),
                            SizedBox(height: 7),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  state.requestStatus == RequestStatus.pending
                                      ? snackBar(
                                          snackMessage:
                                              "Your Request is pending",
                                          context: context)
                                      : context
                                          .read<CommuinityBloc>()
                                          .requestToJoin(
                                              widget.commuinity,
                                              context
                                                  .read<AuthBloc>()
                                                  .state
                                                  .user!
                                                  .uid);
                                },
                                child:
                                    state.requestStatus == RequestStatus.pending
                                        ? Text(
                                            "Pending ...",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          )
                                        : Text(
                                            "Request To Join",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          )),
                          ],
                        ),
                      ),
                    )
                  : state.status == CommuintyStatus.shielded
                      ?
                      // status is shielded
                      _mainScrollView(context, state, widget.commuinity,
                          nativeAdWidget(_nativeAd, _isNativeAdLoaded, context),
                          () {
                          if (mounted)
                            setState(() {});
                          else
                            log("not mounted so not setting state in cmscreen mainScrollWheel");
                        },
                        _scrollController)
                      : _mainScrollView(context, state, widget.commuinity,
                          nativeAdWidget(_nativeAd, _isNativeAdLoaded, context),
                          () {
                          if (mounted)
                            setState(() {});
                          else
                            log("not mounted so not setting state in cmscreen mainScrollWheel");
                        }, _scrollController),
            ));
      }),
    );
  }

 
}
