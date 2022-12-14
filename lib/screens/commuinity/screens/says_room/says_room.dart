import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/screens/create_says.dart';
import 'package:kingsfam/widgets/says_container.dart';

import 'bloc/says_bloc.dart';

class SaysRoomArgs {
  final Church cm;
  final String kcName;
  final String kcId;
  final Userr currUsr;
  const SaysRoomArgs(
      {required this.cm,
      required this.kcName,
      required this.kcId,
      required this.currUsr});
}

class SaysRoom extends StatefulWidget {
  final Church cm;
  final String kcName;
  final String kcId;
  final Userr currUsr;
  const SaysRoom(
      {Key? key,
      required this.cm,
      required this.kcName,
      required this.kcId,
      required this.currUsr})
      : super(key: key);

  static const String routeName = "saysRoom";
  static Route route({required SaysRoomArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return BlocProvider<SaysBloc>(
            create: (context) => SaysBloc(
              saysRepository: context.read<SaysRepository>(),
              authBloc: context.read<AuthBloc>(),
              likedPostCubit: context.read<LikedPostCubit>(),
            ),
            child: SaysRoom(
              kcId: args.kcId,
              cm: args.cm,
              kcName: args.kcName,
              currUsr: args.currUsr,
            ),
          );
        });
  }

  @override
  State<SaysRoom> createState() => _SaysRoomState();
}

class _SaysRoomState extends State<SaysRoom> {
  @override
  void initState() {
    context
        .read<SaysBloc>()
        .add(SaysFetchSays(cmId: widget.cm.id!, kcId: widget.kcId));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Says mockSays = Says(
        author: Userr.empty.copyWith(
          colorPref: "#FFC050",
          username: "mockTester",
        ),
        // contentImgUrl: "https://firebasestorage.googleapis.com/v0/b/kingsfam-9b1f8.appspot.com/o/images%2Fchurches%2FchurchAvatar_eb0c7061-a124-41b4-b948-60dcb0dffc49.jpg?alt=media&token=7e2fc437-9448-48bd-95bc-78e977fbcad8",
        contentTxt:
            "Mock Testing this feature, so lets see how it works withi a kinda long text. do note users will make this actually very long tho lol. thats no cappp",
        likes: 77,
        commentsCount: 29,
        date: Timestamp.now());

    return SafeArea(
      child: Scaffold(
               backgroundColor: Theme.of(context).colorScheme.secondary, //Color(hc.hexcolorCode("#141829")),

        appBar: AppBar(
          // backgroundColor: Color(hc.hexcolorCode("#141829")),
          title: Text(widget.kcName, style: Theme.of(context).textTheme.bodyText1),
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
          actions: [
            TextButton(
                onPressed: () {
                  Church _cmLim = Church.empty;
                  Navigator.of(context).pushNamed(CreateSays.routeName,
                      arguments: CreateSaysArgs(
                          currUsr: widget.currUsr,
                          chLim: _cmLim.copyWith(
                              id: widget.cm.id!, name: widget.cm.name),
                          kcId: widget.kcId));
                },
                child: Text("New Says", style: Theme.of(context).textTheme.bodyText1))
          ],
        ),
        body: BlocConsumer<SaysBloc, SaysState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1),
                child: Expanded(
                  child: ListView.builder(
                      // itemCount: state.status == SaysStatus.loading
                      // ? state.says.length + 1 : state.says.length,
                      itemCount: state.says.length,
                      itemBuilder: (context, index) {
                        Says says = state.says[index]!;
                        log("The val of says: !!!!!!!!: " + says.toString());
                        return Column(
                          children: [
                            SizedBox(height: 4),
                            SaysContainer(says: says, context: context,),
                            SizedBox(height: 4),
                          ],
                        );
                      }),
                ));
          },
        ),
      ),
    );
  }
}
