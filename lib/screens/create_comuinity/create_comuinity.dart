//this screen is for making a new gc either a church or a commuinity
import 'package:flutter/material.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:rive/rive.dart';

class CreateComuinity extends StatelessWidget {
  const CreateComuinity({Key? key}) : super(key: key);

  static const String routeName = '/createComuinity';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => CreateComuinity());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(TextSpan(children: [TextSpan(text: 'Create Something ', style: Theme.of(context).textTheme.bodyText1), TextSpan(text: 'Great', style: TextStyle(color: Colors.deepPurple[200], fontSize: 20, letterSpacing: 1.5, fontWeight: FontWeight.bold))])),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.5,
              child: ListView(
                children: [
                  //for a new gc
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.deepPurple[200]),
                      child: Text("Make A Chat Or Group Chat"),
                      onPressed: () => Navigator.of(context).pushNamed(AddUsers.routeName, arguments: CreateNewGroupArgs(typeOf: 'chat')),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  //for a new commuinity
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red[400]),
                      child: Text('Create A Virtural Church'),
                      onPressed: () => Navigator.of(context).pushNamed( AddUsers.routeName, arguments:CreateNewGroupArgs(typeOf: 'Virtural Church'))),
                  ),
                  Container(height: 400,child: RiveAnimation.asset('assets/phone_idle/phone_idle.riv')) 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
