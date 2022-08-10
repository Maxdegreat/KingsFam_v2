import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/snack_time/cm_theme_list.dart';

class UpdateCmThemePackArgs {
  final CommuinityBloc commuinityBloc;
  final String cmName;
  UpdateCmThemePackArgs({required this.commuinityBloc, required this.cmName});
}

class UpdateCmThemePack extends StatefulWidget {
  final CommuinityBloc cmBloc;
  final String cmName;

  static const String routeName = "update_cm_themePack";

  static Route route(UpdateCmThemePackArgs args) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => UpdateCmThemePack(cmBloc: args.commuinityBloc, cmName: args.cmName,),
    );
  }

  const UpdateCmThemePack({Key? key, required this.cmBloc, required this.cmName}) : super(key: key);

  @override
  State<UpdateCmThemePack> createState() => _UpdateCmThemePackState();
}

class _UpdateCmThemePackState extends State<UpdateCmThemePack> {
  TextStyle style = GoogleFonts.getFont('Montserrat');
  int currTheme = 0;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("btw New Theme Packs released bi-weekly", style: style),
          Text("Theme Packs r free while " +widget.cmName+ " is boosted", style: style,),
          SizedBox(height: 5),
          Text("Now behold ... cm packs", style: style),
          PageView.builder(
            itemCount: 5,
            onPageChanged: (i) {
              currTheme = i;
            },
            itemBuilder: (context, index) {
              return themePreview(pcolor: pcolor, scolor: scolor, bcolor: bcolor, svgPath: svgPath)
            } ,
          )
        ],
      ),
    );
    
  }

  Widget themePreview({required Color pcolor, required Color scolor, required Color bcolor, required String svgPath}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: bcolor),
          child: SvgPicture.asset(svgPath, alignment: Alignment.topCenter),
        ),
      ],
    );
  }
}