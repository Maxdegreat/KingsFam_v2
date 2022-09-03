import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kingsfam/config/type_of.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';

class SnackTimeShopScreen extends StatefulWidget {
  const SnackTimeShopScreen({Key? key}) : super(key: key);

  static const String routeName = "/snackTime";

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SnackTimeShopScreen());
  }

  static TextStyle tStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  @override
  _SnackTimeShopScreenState createState() => _SnackTimeShopScreenState();
}

class _SnackTimeShopScreenState extends State<SnackTimeShopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Perks",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.red[400],
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Boot Your Communitys!!!",
                  style: SnackTimeShopScreen.tStyle),
              SizedBox(height: 5),
              vipDisplay(display: "cmBoosting"),
              SizedBox(height: 10),
              Text("Post Promos", style: SnackTimeShopScreen.tStyle),
              vipDisplay(display: "postPromo"),
              SizedBox(height: 10),
              Text("Get Turbo Charged!", style: SnackTimeShopScreen.tStyle),
              SizedBox(height: 5),
              vipDisplay(display: "Turbo"),
            ],
          ),
        ));
  }

  Widget vipDisplay({required String display}) {
    int buildDots = 0;
    if (display == "cmBoosting")
      buildDots = 3;
    else if (display == "postPromo")
      buildDots = 2;
    else
      buildDots = 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            child: PageView.builder(
                itemCount: buildDots,
                onPageChanged: (idx) => buildDots += 1,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        if (display == "cmBoosting") {
                          NavHelper().navToBuyPerk(
                              context, typeOf.cmBoosting.toString());
                        } else if (display == "postPromo") {
                          NavHelper().navToBuyPerk(
                              context, typeOf.postPromo.toString());
                        } else {
                          NavHelper().navToBuyPerk(
                              context, typeOf.turbo.toString());
                        }
                      },
                      child: vipDisplayContent(display, buildDots)[index]);
                }),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  List<Widget> vipDisplayContent(String display, int buildDots) {
    if (display == "cmBoosting") {
      return [
        Container(
            height: 95,
            width: double.infinity,
            child: SvgPicture.asset(
                "assets/promo_banners/boosted_cm_banners_480x200/1.svg"),
            decoration: BoxDecoration(color: Colors.transparent)),
        Container(
            height: 95,
            width: double.infinity,
            child: SvgPicture.asset(
                "assets/promo_banners/boosted_cm_banners_480x200/2.svg"),
            decoration: BoxDecoration(color: Colors.transparent)),
        Container(
            height: 95,
            width: double.infinity,
            child: SvgPicture.asset(
                "assets/promo_banners/boosted_cm_banners_480x200/3.svg"),
            decoration: BoxDecoration(color: Colors.transparent)),
      ];
    } else if (display == "postPromo") {
      return [
        Container(
            height: 95,
            width: double.infinity,
            child: Center(
                child: Text(
              "So You Want To Advertise? Get a Post Promo and Post!",
              textAlign: TextAlign.center,
            )),
            decoration: BoxDecoration(color: Colors.blue[100])),
        Container(
            height: 95,
            width: double.infinity,
            child: Center(
                child: Text(
              "Make your way into the fams feed",
              textAlign: TextAlign.center,
            )),
            decoration: BoxDecoration(color: Colors.blue[100])),
      ];
    } else { 
      // when display is == Turbo
      return [
        Container(
            height: 95,
            width: double.infinity,
            child: SvgPicture.asset(
                "assets/promo_banners/turbo_ad_banner.svg"),
            decoration: BoxDecoration(color: Colors.transparent)),
      ];
    }
  }
}
