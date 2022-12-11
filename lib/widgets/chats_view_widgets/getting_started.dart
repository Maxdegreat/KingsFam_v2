import 'package:flutter/material.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/update_role.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/church_display_column.dart';
import 'package:kingsfam/widgets/show_asset_image.dart';

import '../help_dialog_widget.dart';

class GettingStarted extends StatefulWidget {
  final ChatscreenBloc bloc;
  final ChatscreenState state;
  const GettingStarted({
    Key? key,
    required this.bloc,
    required this.state,
  });

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Align(
                alignment: Alignment.center,
                child: Text("Find A Community To Join",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40))),
          ),
          SizedBox(height: 10),
          Container(height: 400, child: carousel()),
          gettingStartedBtn(),
          _kfLogo()
        ],
      ),
    );
  }

  Widget carousel() {
    return CarouselSlider(
      options: _options(),
      items: widget.state.chsToJoin.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    CommunityHome.routeName,
                    arguments: CommunityHomeArgs(cm: i, cmB: null)),
                child: search_Church_container(church: i, context: context));
          },
        );
      }).toList(),
    );
  }

  CarouselOptions _options() => CarouselOptions(
        height: 285,
        aspectRatio: 16 / 9,
        viewportFraction: 0.5,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        onPageChanged: null,
        scrollDirection: Axis.vertical,
      );
}

class gettingStartedBtn extends StatelessWidget {
  const gettingStartedBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.white),
                onPressed: () async {
                  helpDialog(context);
                },
                child: Text(
                  "Getting Started",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.black),
                ))),
      ),
    );
  }
}

class _kfLogo extends StatelessWidget {
  const _kfLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text("KingsFam", style: Theme.of(context).textTheme.bodyText1),
    );
  }
}
