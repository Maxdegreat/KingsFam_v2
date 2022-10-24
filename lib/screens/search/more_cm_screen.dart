import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/widgets/snackbar.dart';

import '../../models/church_model.dart';

// args class
class MoreCmArgs {
  final String type;
  final SearchBloc bloc;
  MoreCmArgs({required this.type, required this.bloc});
}

// main class
class MoreCm extends StatefulWidget {
  const MoreCm({Key? key, required this.type, required this.bloc})
      : super(key: key);
  final String type;
  final SearchBloc bloc;

  static const String routeName = "/moreCmArgs";

  static Route route(MoreCmArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) => MoreCm(
              type: args.type,
              bloc: args.bloc,
            )));
  }

  @override
  State<MoreCm> createState() => _MoreCmState();
}

class _MoreCmState extends State<MoreCm> {
  late ScrollController controller;

  @override
  void initState() {
    controller = ScrollController();
    controller.addListener(() {
      addListenerToScrollCtrl();
    });
    super.initState();
  }
  

  void addListenerToScrollCtrl() {
    if (controller.position.atEdge) {
      if (controller.position.pixels != 0.0 &&
          controller.position.maxScrollExtent - 100 ==
              controller.position.pixels - 100) {
        setState(() {});
        if (widget.type == "global") {
          setState(() {
            snackBar(
                snackMessage: "",
                context: context,
                showLoading: true,
                bgColor: Colors.blue);
            widget.bloc
              ..add(PaginateChListNotEqualToLocation(
                  currId: context.read<AuthBloc>().state.user!.uid));
          });
        } else {
          setState(() {
            snackBar(
                snackMessage: "",
                context: context,
                showLoading: true,
                bgColor: Colors.blue);
            widget.bloc
              ..add(PaginateChList1(
                  currId: context.read<AuthBloc>().state.user!.uid));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool loading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type} Communities"),
      ),
      body: BlocProvider.value(
        value: widget.bloc,
        child: BlocConsumer<SearchBloc, SearchState>(
          listener: (context, state) {
            if (state.status == SearchStatus.pag) {
              loading = true;
              setState(() {
                
              });
            } else {
              loading = false;
              setState(() {
                
              });
            }
          },
          builder: (context, state) {
            return SafeArea(
                child: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Stack(
                children: [
                  
                  ListView.builder(
                    controller: controller,
                    itemCount: widget.type == "global"
                        ? state.chruchesNotEqualLocation.length
                        : state.churches.length,
                    itemBuilder: (BuildContext context, int index) {
                      Church cm = widget.type == "global"
                          ? state.chruchesNotEqualLocation[index]
                          : state.churches[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _cmDisplay(
                            bgImgUrl: cm.imageUrl,
                            name: cm.name,
                            location: cm.location,
                            count: cm.members.length.toString()),
                      );
                    },
                  ),
                  Positioned(
                    child: state.status == SearchStatus.pag ? LinearProgressIndicator() : SizedBox.shrink(),
                  ),
                ],
              ),
            ));
          },
        ),
      ),
    );
  }

  Widget _cmDisplay(
      {required String? bgImgUrl,
      required String name,
      required String location,
      required String count}) {
    location = location == null || location == "" ? "Remote" : location;
    return Column(
      children: [
        Container(
          height: 152,
          width: MediaQuery.of(context).size.width / 1.3,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 102, 102, 103),
              image: bgImgUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(bgImgUrl),
                      fit: BoxFit.cover)
                  : null,
              borderRadius: BorderRadius.circular(5.0)),
        ),
        SizedBox(height: 20),
        Container(
          child: Column(
            children: [
              Text(
                name,
                style: GoogleFonts.aBeeZee(color: Colors.white),
              ),
              Text(
                "members: " + count,
                style: GoogleFonts.aBeeZee(color: Colors.white),
              ),
              Text(
                location,
                style: GoogleFonts.aBeeZee(color: Colors.white),
              )
            ],
          ),
        )
      ],
    );
  }
}