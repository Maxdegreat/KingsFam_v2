import 'dart:convert';
import 'dart:developer';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/helpers/stripe_helper.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/snack_time/cm_theme_list.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class UpdateCmThemePackArgs {
  final CommuinityBloc commuinityBloc;
  final String cmName;
  final String cmId;
  UpdateCmThemePackArgs(
      {required this.commuinityBloc, required this.cmName, required this.cmId});
}

class UpdateCmThemePack extends StatefulWidget {
  final CommuinityBloc cmBloc;
  final String cmName;
  final String cmId;

  static const String routeName = "update_cm_themePack";

  static Route route(UpdateCmThemePackArgs args) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => UpdateCmThemePack(
        cmBloc: args.commuinityBloc,
        cmName: args.cmName,
        cmId: args.cmId,
      ),
    );
  }

  const UpdateCmThemePack(
      {Key? key,
      required this.cmBloc,
      required this.cmName,
      required this.cmId})
      : super(key: key);

  @override
  State<UpdateCmThemePack> createState() => _UpdateCmThemePackState();
}

class _UpdateCmThemePackState extends State<UpdateCmThemePack> {
  TextStyle style = GoogleFonts.getFont('Montserrat');
  TextStyle styleBoostBtn = GoogleFonts.actor(fontWeight: FontWeight.bold);
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
        title: Text(
          widget.cmName + "THEME PACK",
          style: GoogleFonts.getFont('Montserrat'),
          overflow: TextOverflow.fade,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("btw New Theme Packs released bi-weekly", style: style),
            Text(
              "Theme Packs r free while " + widget.cmName + " is boosted",
              style: style,
            ),
            SizedBox(height: 7),
            Text("Now behold ... cm packs", style: style),
            Container(
              height: MediaQuery.of(context).size.height / 3.7,
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
                      svgTitle: cmSvgThemeTitles[index]);
                },
              ),
            ),
            SizedBox(height: 10),
            widget.cmBloc.state.boosted != 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            // widget.cmBloc.onBoostCm(cmId: widget.cmId);
                            await _stripePayCardWidget();
                            // snackBar(snackMessage: "BOOSTED, may have to refesh home screen to view", context: context, bgColor: Colors.green);
                          },
                          child: Text(
                            "BOOST ${widget.cmName.toUpperCase()}",
                            style: styleBoostBtn,
                          )),
                    ),
                  )
                : SizedBox.shrink(),
            SizedBox(height: 7),
            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: (Colors.blue[700]),
                    child: Center(child: Text("Perks When Boosting CM")),
                  ),
                  Container(
                    height: 300,
                    color: Colors.blue[400],
                    child: Column(
                      children: [
                        _paddedText(
                          text: "More Than 105 Community Members",
                        ),
                        _paddedText(text: "More Than 5 KC's"),
                        _paddedText(text: "More Than 2 Admins"),
                        _paddedText(text: "Theme Packs!!!"),
                        _paddedText(
                            text: "More Coming Soon, be on the look out ")
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding _paddedText({required String text}) => Padding(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Center(
            child: Text(
          text,
          style: styleBoostBtn,
        )),
      );

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
          onTap: () {
            if (widget.cmBloc.state.boosted == 0) {
              snackBar(
                  snackMessage:
                      "Hey, to use a theme you have to boost ${widget.cmName}",
                  context: context,
                  bgColor: Colors.red[400]);
            } else {
              widget.cmBloc.setTheme(cmId: widget.cmId, theme: svgPath);
            }
          },
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

  Future<void> _stripePayCardWidget() async {
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
