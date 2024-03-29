import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/config/type_of.dart';
import 'package:kingsfam/screens/snack_time/cm_theme_list.dart';
import 'package:kingsfam/widgets/show_asset_image.dart';
import 'package:kingsfam/widgets/widgets.dart';

class BuyPerkArgs {
  final String type;
  BuyPerkArgs({required this.type});
}

class BuyPerkScreen extends StatefulWidget {
  final String type;
  const BuyPerkScreen({Key? key, required this.type}) : super(key: key);

  static const String routeName = "buyPerkScreen";
  static Route route(BuyPerkArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => BuyPerkScreen(
              type: args.type,
            ));
  }

  @override
  State<BuyPerkScreen> createState() => _BuyPerkScreenState();
}

class _BuyPerkScreenState extends State<BuyPerkScreen> {
  TextStyle st = GoogleFonts.aBeeZee();
  TextStyle style = GoogleFonts.getFont('Montserrat');
  TextStyle styleBoostBtn = GoogleFonts.actor(
      fontWeight: FontWeight.bold, fontSize: 18, wordSpacing: 1.2);
  int currThemeIdx = 0;
  String path =
      cmSvgThemes[0]; // path is used for the svg path in pageVieweBuilder
  Color pColor = cmSvgColorThemes[cmSvgThemes[0]]["p"];
  Color sColor = cmSvgColorThemes[cmSvgThemes[0]]["s"];
  Color bColor = cmSvgColorThemes[cmSvgThemes[0]]["b"];
  String test_secret_key =
      "sk_test_51LepZfCJ9MK5xgXMTwuxT3vWb2BwgtX8QVMnDpwJdVhKh6Hul1hcQk7QiClO5qSAXcaGwxL6VviizHSjT9VGXZyV00tfpHrEQb";
  Map<String, dynamic>? _paymentIntent;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("COMING SOON"),
        ),
        body: widget.type == typeOf.KFCoins
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.9,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: cmSvgThemes.length,
                      itemBuilder: (context, index) {
                        return themePreview(
                          pcolor: null,
                          scolor: null,
                          bcolor: null,
                          svgPath: cmSvgThemes[index],
                          svgTitle: cmSvgThemeTitles[index],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.amber),
                          onPressed: () async {
                            snackBar(
                                snackMessage:
                                    "Coming Soon, customimze ur whole KF experience!",
                                context: context);
                            // widget.cmBloc.onBoostCm(cmId: widget.cmId);

                            // display amount of coins user has

                            // confirm check out

                            // backend code rmv coins

                            // snackBar(snackMessage: "BOOSTED, may have to refesh home screen to view", context: context, bgColor: Colors.green);
                          },
                          child: Text(
                            "Theme Up",
                            style: styleBoostBtn,
                          )),
                    ),
                  ),
                ],
              )
            : widget.type == typeOf.turbo
                ? turboWid()
                : SizedBox.shrink());

    // ------------------------------------------------------
  }

  Widget themePreview(
      {required Color? pcolor,
      required Color? scolor,
      required Color? bcolor,
      required String svgPath,
      required String svgTitle}) {
    return Stack(
      children: [
        ListTile(
          leading: svgCircleAvatar(svgAssetPath: svgPath),
          title: Text(svgTitle),
          trailing: Container(
            width: 150,
            height: 100,
            child: Row(
              children: [
                // show the coin
                showImageFromAssetsPNG(50, 50, 0, "assets/coin/KFcoin.png"),
                SizedBox(width: 10),
                //show the price
                Text("250"),
              ],
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget svgCircleAvatar({required String svgAssetPath}) {
    return Container(
      child: SvgPicture.asset(
        svgAssetPath,
        fit: BoxFit.fitWidth,
        clipBehavior: Clip.hardEdge,
      ),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  turboWid() {
    return Container(
      child: Text("Jesus I know you will not let me down"),
    );
  }
}
