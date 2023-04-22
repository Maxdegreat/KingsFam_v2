// this screen assecpts a list of Userr's from the add users screen. as seen in the args.
// and handels the compleation of creating the church or commuinities. ps if looking for the extraction of member ids
// check the bottom of the file.
// after all navs back to prev pages but the church is now made :)

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/camera/camera_screen.dart';
import 'package:kingsfam/config/cm_type.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/widgets/widgets.dart';

import 'cubit/buildchurch_cubit.dart';

// ADMIN ID CODE ATTHE BOTTOM

class BuildChurch extends StatefulWidget {
  const BuildChurch({Key? key}) : super(key: key);

  static const String routeName = '/buildChurch';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<BuildchurchCubit>(
              create: (_) => (BuildchurchCubit(
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  churchRepository: context.read<ChurchRepository>())),
              child: BuildChurch(),
            ));
  }

  @override
  _BuildChurchState createState() => _BuildChurchState();
}

class _BuildChurchState extends State<BuildChurch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // bool emitProgressIndicator = false;
    // == done i think just remove self from add users screen thats confusing...

    //widget.selectedMembers.insert(0, ) do this in cubit, inset urself at 0 and do via
    //cubit also remove ur name from querry in add user thats a big part of the app mate
    //use get user with id and auth bloc
    //int popScreens = 0;

    return BlocConsumer<BuildchurchCubit, BuildchurchState>(
      listener: (context, state) {
        // if (state.status == BuildChurchStatus.loading) {
        //   emitProgressIndicator = true;
        // }
        // else
        if (state.status == BuildChurchStatus.error) {
          ErrorDialog(
            content:
                'hmm, something went worong. check your connection --- build_church e-code: ${state.failure.message} ',
          );
        } else if (state.status == BuildChurchStatus.success) {
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          //Navigator.of(context).popAndPushNamed(ChatsScreen.routeName);
          // Navigator.of(context).popUntil((_) => popScreens++ >= 3);
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                children: [
                      _orNewPostWidget(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.shortestSide / 5),
                        GestureDetector(
                          onTap: () => _onChurchImageChanged(context),
                          child: Container(
                            height: MediaQuery.of(context).size.shortestSide / 2,
                            width: MediaQuery.of(context).size.shortestSide / 2,
                            decoration: state.imageFile != null
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    image: DecorationImage(
                                        image: FileImage(state.imageFile!),
                                        fit: BoxFit.fitWidth))
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            child: state.imageFile != null
                                ? null
                                : Center(
                                    child: FaIcon(
                                    FontAwesomeIcons.image,
                                    size: 55,
                                  )),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.shortestSide / 10),
                        Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.isSubmiting == true)
                                  LinearProgressIndicator(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                  
                                TextFormField(
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 21),
                                      border: InputBorder.none,
                                      hintText: 'Name your Community'),
                                  onChanged: (value) => context
                                      .read<BuildchurchCubit>()
                                      .onNameChanged(value),
                                  validator: (value) => value!.isEmpty
                                      ? "Please name your community"
                                      : null,
                                ),
                                // ------------ drop down btn below
                                SizedBox(
                                  child: DropdownButton<String>(
                                    value: Location.dropdownValue,
                                    icon: null,
                                    iconSize: 0,
                                    elevation: 0,
                                    underline: SizedBox.shrink(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        Location.dropdownValue = newValue!;
                                      });
                                      context
                                          .read<BuildchurchCubit>()
                                          .onLocationChanged(newValue!);
                                    },
                                    items: locations()
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide /
                                                  2.5),
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                  
                                // ---------- cm type btn row above
                                TextFormField(
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 21),
                                      hintText: "Give a summary",
                                      border: InputBorder.none),
                                  onChanged: (value) => context
                                      .read<BuildchurchCubit>()
                                      .onAboutChanged(value),
                                  validator: (value) => value!.length < 200
                                      ? null
                                      : 'use less than 200 characters',
                                ),
                                SizedBox(height: 5.0),
                  
                                state.isSubmiting == false
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        onPressed: () {
                                          submitChurch(
                                              context: context,
                                              submitStatus: state.isSubmiting,
                                              isImage: state.imageFile == null);
                                        },
                                        child: Text(
                                          'CREATE YOUR COMMUNITY 🤩',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ))
                                    : ElevatedButton(
                                        onPressed: () {},
                                        child: Text(
                                          'CREATING...',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ))
                              ],
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  // ElevatedButton btnHollow(BuildContext context, BuildchurchState state, String content, VoidCallback vc) {
  //   return ElevatedButton(
  //                               onPressed: vc,
  //                               child: Text(content),
  //                               style: ButtonStyle(
  //                                   foregroundColor: state.cmType == content
  //                                       ? MaterialStateProperty.all<Color>(
  //                                           Colors.white)
  //                                       : MaterialStateProperty.all<Color>(
  //                                           Colors.grey[700]!),
  //                                   backgroundColor: MaterialStateProperty.all<Color>(
  //                                       Colors.transparent),
  //                                   shape: MaterialStateProperty.all<
  //                                           RoundedRectangleBorder>(
  //                                       RoundedRectangleBorder(
  //                                           borderRadius: BorderRadius.zero,
  //                                           side: BorderSide(
  //                                               color: state.cmType == CmType.chialpha
  //                                                   ? Colors.white
  //                                                   : Colors.grey[700]!)))),
  //                             );
  // }

  Widget _orNewPostWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(CameraScreen.routeName,
                          arguments: CameraScreenArgs(cmId: null));
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Or share a new Post",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(),
            ),
            const SizedBox(width: 5),
            Icon(Icons.add_rounded)
          ],
        ),
      ),
    );
  }

  void _onChurchImageChanged(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
        context: context,
        cropStyle: CropStyle.rectangle,
        title: "Church Banner Image");
    if (pickedFile != null)
      context.read<BuildchurchCubit>().onImageChanged(pickedFile);
  }

  void submitChurch(
      {required BuildContext context,
      required bool submitStatus,
      required bool isImage}) {
    if (!isImage) {
      // if image not null
      if (submitStatus == false && _formKey.currentState!.validate()) {
        context.read<BuildchurchCubit>().onSubmiting();
        setState(() {});

        context.read<BuildchurchCubit>().submit();
      } else {
        return;
      }
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(content: "make sure you added a image"));
    }
  }
}
