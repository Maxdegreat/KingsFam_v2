import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  TextStyle st = GoogleFonts.aBeeZee();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.toString()),
      ),
      body: widget.type == typeOf.cmBoosting ? cmBoostingWid() : 
        widget.type == typeOf.turbo ? turboWid() : SizedBox.shrink()
    );
  }


  Widget cmBoostingWid() { // price at $2.25 monthly
    return ListView(
      children: [
        ListTile(
          title: Text("CM Them Packs!", style: st),
        ),
        ListTile(
          title: Text("+5 CM Theme Pack slots (access to CM Themes and 5 slots for custom theme packs)", style: st),
        ),
        ListTile(
          title: Text("+5 CM Stickers slots. Stickers can be used as emojis)", style: st),
        ),
        ListTile(
          title: Text("Volume Up! (Elders Can Start Audio Calls) - Admins always can", style: st),
        ),
      ],
    );
  }

    Widget turboWid() { // price at $1.50 monthly
    return ListView(
      children: [
        ListTile(
          title: Text("Upload Videos Longer Than 60 seconds (up to 120 seconds)", style: st),
        ),
        ListTile(
          title: Text("Access To Super Cool Special Emojis", style: st),
        ),
        ListTile(
          title: Text("Use Theme Packs And add Customization Througout KingsFam", style: st),
        ),
      ],
    );
  }

    Widget postPromoWid() { // price at $2.50 per post or $5.50 a month for 7 promoted post a month or $7.00 for unlimited promo a month
    return ListView();
  }
}
