import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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

                            //await _stripePayCardWidget();
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

  _stripePayCardWidget() async {
    try {
      _paymentIntent = await makePaymentIntent("2", "USD");
      if (_paymentIntent == null) {
        log("THE INTENT IS NULL GANG GANG ... FOR YOU MY LORD.");
      }
      // create a payment sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: _paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'KingsFam'))
          .then((value) => displayPaymentSheet());
    } catch (e) {
      log(e.toString() + "update_cm_theme_pack.dart - _stripePayCardWidget");
    }
    // return showModalBottomSheet(
    //   isScrollControlled: true,
    //   context: context,
    //   builder: (context) => Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       StripePayCardWidget(cardTitle: 'Boost ${widget.cmName}', price: '\$1.99',),
    //     ],
    //   )
    // );
  }

  displayPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet().then((value) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.green,
                      ),
                      Text("Success Payment Fam")
                    ],
                  )
                ],
              ),
            )));

    _paymentIntent = null;
  }

  makePaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': getAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $test_secret_key',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      print("response =============> ${response.body.toString()}");
      return jsonDecode(response.body);
    } catch (e) {
      // ignore: unnecessary_statements
      log(e.toString() + "update_cm_theme_pack.dart - makePayment");
    }
  }

  getAmount(String amount) {
    final calculation = (int.parse(amount)) * 100;
    print(calculation.toString());
    return calculation.toString();
  }
}

turboWid() {
  return Container(
    child: Text("Jesus I know you will not let me down"),
  );
}
