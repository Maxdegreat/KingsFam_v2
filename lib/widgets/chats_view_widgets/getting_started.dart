import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/church_display_column.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Christian Communities For This Generation!",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 25),
                    textAlign: TextAlign.center,
                  )),
            ),
            SizedBox(height: 10),
            Container(
                height: MediaQuery.of(context).size.height / 1.7,
                child: carousel()),
            _Descover(),
            gettingStartedBtn(),
            _kfLogo()
          ],
        ),
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
                child: churchDisplayContainer(context, i));
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
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(BuildChurch.routeName),
          child: Container(
              height: 43,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12.0),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Create your community",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18))
                ],
              )),
        ),
      ),
    );
  }
}

class _Descover extends StatelessWidget {
  const _Descover({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(2.0),
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: GestureDetector(
            onTap: () => context
                .read<BottomnavbarCubit>()
                .updateSelectedItem(BottomNavItem.feed),
            child: Container(
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Descover The KingsFam",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.map,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  ],
                )),
          ),
        ),
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
