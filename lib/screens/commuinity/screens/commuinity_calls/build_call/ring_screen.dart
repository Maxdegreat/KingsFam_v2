
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/call_model.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/build_call/bloc/ringer_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/cubit/calls_home_cubit.dart';
import 'package:kingsfam/widgets/profile_image.dart';

class RingScreenArgs{
  final CallModel call;
  const RingScreenArgs({required this.call});
}

class RingScreen extends StatefulWidget {
  final CallModel call;
  const RingScreen({required this.call});
  //route name and route
  static const String routeName = 'ringScreen';
  static Route route({required RingScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<RingerBloc>(
              create: (context) => RingerBloc(authBloc: context.read<AuthBloc>()),
              child: RingScreen(call: args.call),
            ));
  }

  @override
  _RingScreenState createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  @override
  Widget build(BuildContext context) {
    final currId = context.read<AuthBloc>().state.user!.uid;
    return Scaffold(
      body: BlocConsumer<RingerBloc, RingerState>(
        listener: (context, state) {
          
        },
        builder: (context, state) => Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileImage(radius: 50, pfpUrl: widget.call.callerPicUrl!),
              SizedBox(height: 25),
              Center(
                child: Text(
                  "Incoming call from ${widget.call.callerUsername}", 
                  style: Theme.of(context).textTheme.bodyText1)
                ),
                SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                  child: ElevatedButton(
                    onPressed: () {}, 
                    child: Text("Answer"),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      //when decline pop out and del the call clone on the invited users ring
                      context.read<CallshomeCubit>().declineRIng(invitedId: currId);
                      SchedulerBinding.instance!.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                      });
                    }, 
                    child: Text("Decline"),
                    style: ElevatedButton.styleFrom(primary: Colors.red[700]),
                  ),
                ),
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
