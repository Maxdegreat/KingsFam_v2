//this screen is for making a new gc either a church or a commuinity
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:rive/rive.dart';

class CreateComuinity extends StatefulWidget {
  const CreateComuinity({Key? key}) : super(key: key);

  static const String routeName = '/createComuinity';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => CreateComuinity());
  }

  @override
  _CreateComuinityState createState() => _CreateComuinityState();
}

class _CreateComuinityState extends State<CreateComuinity> {

late BannerAd _bottomBannerAd;
    bool _isBottomBannerAdLoaded = false;
    void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("chatsScreen ad error: ${error.toString()}");
        }),
        request: AdRequest());
    _bottomBannerAd.load();
  }
    @override
    void initState() {
      _createBottomBannerAd();
      super.initState();
    }

    @override
  void dispose() {
    _bottomBannerAd.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        _isBottomBannerAdLoaded ?
        Container(height: AdSize.banner.height.toDouble(), width: double.infinity, child: AdWidget(ad: _bottomBannerAd,),) : SizedBox.shrink()
      ],
      appBar: AppBar(
        title: Text.rich(TextSpan(children: [TextSpan(text: 'Create Something ', style: Theme.of(context).textTheme.bodyText1), TextSpan(text: 'Great', style: TextStyle(color: Colors.deepPurple[200], fontSize: 20, letterSpacing: 1.5, fontWeight: FontWeight.bold))])),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
                    //for a new gc
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Color.fromARGB(255, 255, 193, 7)),
                        child: Text("✨ Share A Post ✨"),
                        onPressed: () => Navigator.of(context).pushNamed(CreatePostScreen.routeName),
                      ),
                    ),
                    
                    SizedBox(height: 10.0),
                    //for a new commuinity
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                        child: Text('Create A Commuinity 👑'),
                        onPressed: () => Navigator.of(context).pushNamed( AddUsers.routeName, arguments:CreateNewGroupArgs(typeOf: 'Virtural Church'))),
                    ),
                    // Container(height: 400,child: RiveAnimation.asset('assets/phone_idle/phone_idle.riv')) 
                    SizedBox(height: 10.0),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.deepPurple[200]),
                        child: Text("✨ Make A Chat / Group Chat"),
                        onPressed: () => Navigator.of(context).pushNamed(AddUsers.routeName, arguments: CreateNewGroupArgs(typeOf: 'chat')),
                      ),
                    ),
                  ],
      
          ),
        ),
      ),
    );
  }
}
