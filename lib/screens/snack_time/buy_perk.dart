import 'package:flutter/material.dart';
import 'package:kingsfam/config/type_of.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.toString()),
      ),
      body: widget.type == typeOf.cmBoosting ? cmBoostingView() : Container(),
    );
  }

  Widget cmBoostingView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("The perks of boosting a CM"),
          Text("Theme Packs!"),
          Text("Get more than 105 members"),
          Text("Get more than 5 Text channels"),
          Text("Get more than two admins"),
          Text("And more features are fs coming!"),
          SizedBox(height: 10),
          Text("Select Community\'s to boost!")
        ],
      ),
    );
  }
}
