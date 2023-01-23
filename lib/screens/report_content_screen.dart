import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/widgets/snackbar.dart';

// continue = collection("church").doc("cmid") or continue = collection("user").doc("userId")
// fire.collection("reports").doc(const).continue;

// info {
//  "continue": "...", // documentRef to user
// "what" : "post or cm or pf"
// "path to what"
// why : "
// }

class RepoetContentScreenArgs {
  final Map<String, dynamic> info;
  const RepoetContentScreenArgs({required this.info});
}

class ReportContentScreen extends StatefulWidget {
  final Map<String, dynamic> info;

  ReportContentScreen({Key? key, required this.info}) : super(key: key);
  static const String routeName = "/ReportContentScreen";
  static Route route({required RepoetContentScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) {
          return ReportContentScreen(info: args.info);
        }));
  }

  @override
  State<ReportContentScreen> createState() => _ReportContentScreenState();
}

class _ReportContentScreenState extends State<ReportContentScreen> {
  String? reason;

  @override
  Widget build(BuildContext context) {


    submit() {
      if (reason != null) {
         Map<String, dynamic> toDoc = {
        "what": widget.info["what"],
        "continue": widget.info["continue"],
        "why": reason,
      };

      FirebaseFirestore.instance.collection(Paths.report).doc(widget.info["userId"]).collection("reports").add(toDoc);
      snackBar(snackMessage: "If we find this content violates out guidelines we will remove it", context: context, bgColor: Colors.greenAccent);
      Navigator.of(context).pop();
      } else {
        snackBar(snackMessage: "Please provide a reason to report", context: context, bgColor: Colors.redAccent);
      }
    }

     Widget _checkBox(String r) =>  Checkbox(
        checkColor: Theme.of(context).colorScheme.onPrimary,
        fillColor: MaterialStateProperty.all(Colors.amber),
        value: reason == r,
        onChanged: (bool? value) {
          setState(() {
            reason = r;
          });
        });
      

  List<String> reasons = [
    "Sharing hate speech or discriminatory content",
    "Sharing violent or graphic images",
    "Cyberbullying or harassment of others",
    "Sharing personal information of others without their consent",
    "Sharing fake or misleading information",
    "Engaging in online scams or fraud",
    "Sharing sexaual content"
  ];

  List<Widget> tiles = [
    ListTile(title: Text(reasons[0]), trailing: _checkBox(reasons[0]),),
    ListTile(title: Text(reasons[1]), trailing: _checkBox(reasons[1]),),
    ListTile(title: Text(reasons[2]), trailing: _checkBox(reasons[2]),),
    ListTile(title: Text(reasons[3]), trailing: _checkBox(reasons[3]),),
    ListTile(title: Text(reasons[4]), trailing: _checkBox(reasons[4]),),
    ListTile(title: Text(reasons[5]), trailing: _checkBox(reasons[5]),),
    ListTile(title: Text(reasons[6]), trailing: _checkBox(reasons[6]),),
  ];

  tiles.add(
    Container(
      width: double.infinity,
      child: ElevatedButton(onPressed: submit, child: Text("Submit"), style: ElevatedButton.styleFrom(shape: StadiumBorder()),))
  );


    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Report Screen',
          style: Theme.of(context).textTheme.bodyText1,
        )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: tiles.map((tile) => tile).toList(),
              ),
            ),
          ),
        ));
  }
 
}
