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
import 'package:kingsfam/config/cm_type.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/widgets/widgets.dart';

import 'cubit/buildchurch_cubit.dart';

// ADMIN ID CODE ATTHE BOTTOM


class BuildChurch extends StatefulWidget {
  const BuildChurch({Key? key})
      : super(key: key);

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
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height / 3,
              flexibleSpace: FlexibleSpaceBar(
                  //if state.imageFile == null show the image icon else show the selected file
                  background: GestureDetector(
                onTap: () => _onChurchImageChanged(context),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: state.imageFile != null
                      ? BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(state.imageFile!),
                              fit: BoxFit.fitWidth))
                      : null,
                  child: state.imageFile != null
                      ? null
                      : Center(
                          child: FaIcon(
                          FontAwesomeIcons.image,
                          size: 55,
                        )),
                ),
              )),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.isSubmiting ==
                                true) //state.status == BuildChurchStatus.loading || emitProgressIndicator)
                              LinearProgressIndicator(
                                color: Colors.red[400],
                              ),
                            TextFormField(
                              decoration:
                                  InputDecoration(hintText: 'Community Name'),
                              onChanged: (value) => context
                                  .read<BuildchurchCubit>()
                                  .onNameChanged(value),
                              validator: (value) => value!.isEmpty
                                  ? "You need to add a name"
                                  : null,
                            ),
                            // ------------ drop down btn below
                            DropdownButton<String>(
                              value: Location.dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.white),
                              underline: Container(
                                height: 1,
                                color: Colors.white,
                                alignment: Alignment.centerRight,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  Location.dropdownValue = newValue!;
                                });
                                context
                                    .read<BuildchurchCubit>()
                                    .onLocationChanged(newValue!);
                              },
                              items: locations().map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            
                            // ---------- cm type btn row above
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Mission statement / about'),
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
                                        primary: Colors.red[400]),
                                    onPressed: () {
                                      submitChurch(
                                          context: context,
                                          submitStatus: state.isSubmiting,
                                          isImage: state.imageFile == null);
                                    },
                                    child: Text(
                                      'CREATE',
                                      style: TextStyle(letterSpacing: 1.5),
                                    ))
                                : ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                      'CREATING...',
                                      style: TextStyle(letterSpacing: 1.5),
                                    ))
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ]),
        );
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
