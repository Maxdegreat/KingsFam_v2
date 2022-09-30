import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kingsfam/config/type_of.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/widgets/show_asset_image.dart';

class SnackTimeArgs {
  final String currUserId;
  SnackTimeArgs({required this.currUserId});
}

class SnackTimeShopScreen extends StatefulWidget {
  const SnackTimeShopScreen({Key? key, required this.currId}) : super(key: key);
  final String currId;
  static const String routeName = "/snackTime";

  static Route route(SnackTimeArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SnackTimeShopScreen(currId: args.currUserId,));
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
              Text("Get KFCoins",
                  style: SnackTimeShopScreen.tStyle),
              SizedBox(height: 5),
              vipDisplay(display: "KFCoins"),
              SizedBox(height: 10),
              Text("Post Promos", style: SnackTimeShopScreen.tStyle),
              vipDisplay(display: "postPromo"),
              // SizedBox(height: 10),
              // Text("Buy Themes", style: SnackTimeShopScreen.tStyle),
              // SizedBox(height: 5),
              // vipDisplay(display: "Turbo"),
            ],
          ),
        ));
  }

  Widget vipDisplay({required String display}) {
    int buildDots = 0;
    if (display == "KFCoins")
      buildDots = 1;
    else if (display == "postPromo")
      buildDots = 1;

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
                        if (display == "KFCoins") {
                          NavHelper().navToBuyPerk(
                              context, typeOf.KFCoins.toString());
                        } else if (display == "postPromo") {
                          NavHelper().navToBuyPerk(
                              context, typeOf.postPromo.toString());
                        } else {
                          NavHelper()
                              .navToBuyPerk(context, typeOf.turbo.toString());
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
            child: showAssetImage(500, 300, 5, "assets/promo_banners/boosted_480_200_px/1.png"),),
            // SvgPicture.asset("assets/promo_banners/boosted_cm_banners_480x200/1.svg"),
            // decoration: BoxDecoration(color: Colors.transparent)
      ];
    } else if (display == "postPromo") {
      return [
                 Container(
            height: 95,
            width: double.infinity,
            child: showAssetImage(500, 300, 5, "assets/promo_banners/boosted_480_200_px/2.png"),),
      ];
    } else {
      // when display is == Turbo
      return [
                Container(
            height: 95,
            width: double.infinity,
            child: showAssetImage(500, 300, 5, "assets/promo_banners/boosted_480_200_px/1.png"),),
      ];
    }
  }
}
