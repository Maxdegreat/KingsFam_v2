import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/extensions/locations.dart';
import 'package:kingsfam/helpers/image_helper.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

class EditProfileScreenArgs {
  final BuildContext context;
  const EditProfileScreenArgs({
    required this.context,
  });
}

// global args type beat. once we have our passed args we will update this args to be equal
// this will allow us to use the global args below for our  colorPref picker!
BuildContext? pb;

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/editProfile';
  static Route route({required EditProfileScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              create: (_) => EditProfileCubit(
                  profileBloc: args.context.read<ProfileBloc>(),
                  storageRepository: context.read<StorageRepository>(),
                  userrRepository: context.read<UserrRepository>()),
              child: EditProfileScreen(
                userr: args.context.read<ProfileBloc>().state.userr,
              ),
            ));
  }

  EditProfileScreen({required this.userr});

  final Userr userr;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // instance of hexcolor class
  HexColor hexcolor = HexColor();
  Map<String, String> hexcolormapStr = HexColor().hexColorMap;
  Map<int, String> hexcolormapInt = HexColor().hexcolorCounter;
  Map<String, String> hexToColor = HexColor().hexToColor;

  // used to gobally update the users color preff
  String? userColorPref;

// widget.userr.colorPref

  @override
  Widget build(BuildContext context) {
    String dropdownValue = "Remote";
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
          if (state.status == EditProfileStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == EditProfileStatus.error) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message));
          }
        }, builder: (context, state) {
          // I need to set the user color pref initally. it can be changed later but just so it is not set to a default color.
          // this will help the user know what they are changing in realtime and prevent them from muptile updates via writes
          if (state.colorPref == '') {
            log(widget.userr.colorPref);
            context
                .read<EditProfileCubit>()
                .updateColorPreff(widget.userr.colorPref);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                if (state.status == EditProfileStatus.submitting)
                  const LinearProgressIndicator(),
                GestureDetector(
                  onTap: () => _pickBannerImage(context),
                  child: BannerImage(
                    isOpasaty: false,
                    bannerImageUrl: widget.userr.bannerImageUrl,
                    bannerImage: state.bannerImage,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      child: ElevatedButton(
                    onPressed: () => _pickBannerImage(context),
                    child: Text(
                      "Edit banner image",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent),
                  )),
                ),
                Container(
                    child: GestureDetector(
                  onTap: () => _pickProfileImage(context),
                  child: ProfileImage(
                    radius: 40.0,
                    pfpUrl: widget.userr.profileImageUrl,
                    pfpImage: state.profileImage,
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () => _pickProfileImage(context),
                      child: Text(
                        "Edit banner image",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              cursorColor: Theme.of(context).colorScheme.inversePrimary,
                              initialValue: widget.userr.username,
                              decoration: InputDecoration(hintText: 'Username'),
                              onChanged: (value) => context
                                  .read<EditProfileCubit>()
                                  .usernameChanged(value),
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Username can\'t be empty'
                                  : null,
                            ),
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ B I O ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            TextFormField(
                              cursorColor: Theme.of(context).colorScheme.inversePrimary,
                              initialValue: widget.userr.bio,
                              decoration: InputDecoration(hintText: 'Bio'),
                              onChanged: (value) => context
                                  .read<EditProfileCubit>()
                                  .bioChanged(value),
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Bio can\'t be empty'
                                  : null,
                            ),
                            // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ C O L O R P R E F ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            SizedBox(height: 15.0),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                    'My Color Pref is... ${hexToColor[state.colorPref]}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color(hexcolor
                                          .hexcolorCode(state.colorPref)),
                                    )),
                              ),
                            ),

                            PickColorPref(
                                hexcolormapStr: hexcolormapStr,
                                hexcolormapInt: hexcolormapInt,
                                hexcolor: hexcolor),

                            Divider(
                              color: Colors.grey,
                              height: 5.0,
                              thickness: .5,
                            ),

                            Container(
                              width: double.infinity,
                              child: DropdownButton<String>(
                                value: Location.dropdownValue,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.white),
                                underline: Container(
                                  height: 2,
                                  color: Color(
                                      hexcolor.hexcolorCode(state.colorPref)),
                                ),
                                onChanged: (String? newValue) {
                                  setState(
                                      () => Location.dropdownValue = newValue!);
                                  context
                                      .read<EditProfileCubit>()
                                      .locationChanged(newValue!);
                                },
                                items: locations()
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: 15.0),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.green[400]),
                                onPressed: () => _submitForm(
                                    context,
                                    state.status ==
                                        EditProfileStatus.submitting),
                                child: Text('Done!?')),

                            SizedBox(
                              height: 20,
                            ),

                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onLongPress: () =>
                                        context.read<AuthRepository>().logout(),
                                    onPressed: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                "Long Press For 5 Seconds To Log Out"))),
                                    child: Text(
                                      "Log Me Out",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  TextButton(
                                    onLongPress: () async {
                                      await delAcc(context)
                                          ? context
                                              .read<AuthRepository>()
                                              .deleteAccount()
                                          : snackBar(
                                              snackMessage:
                                                  "Your account was not deleted.",
                                              context: context);
                                    },
                                    onPressed: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                "Long Press For 5 Seconds To to delete your account. Note your account will be forever deleted"))),
                                    child: Text(
                                      "Delete my account",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ])
                          ],
                        )))
              ],
            ),
          );
        }),
      ),
    );
  }

  void _pickBannerImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
        context: context,
        cropStyle: CropStyle.rectangle,
        title: 'Banner Image');
    if (pickedFile != null) {
      context
          .read<EditProfileCubit>()
          .bannerImageChanged(File(pickedFile.path));
    }
  }

  void _pickProfileImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
        context: context, cropStyle: CropStyle.circle, title: 'Profile Image');
    if (pickedFile != null) {
      context
          .read<EditProfileCubit>()
          .profileImageChanged(File(pickedFile.path));
    }
  }

  void _submitForm(BuildContext context, bool isSubmiting) {
    if (_formKey.currentState!.validate() && !isSubmiting) {
      context.read<EditProfileCubit>().submit();
    }
  }
}

Future delAcc(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("You are about to delete your account",
              style: Theme.of(context).textTheme.bodyText1),
          content: Text("You can not undo this action",
              style: Theme.of(context).textTheme.bodyText1),
          actions: [
            GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Text("No, keep account",
                    style: Theme.of(context).textTheme.bodyText1)),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Text("Delete your account",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.red[400])))
          ],
        );
      });
}

class PickColorPref extends StatelessWidget {
  const PickColorPref({
    Key? key,
    required this.hexcolormapStr,
    required this.hexcolormapInt,
    required this.hexcolor,
  }) : super(key: key);

  final Map<String, String> hexcolormapStr;
  final Map<int, String> hexcolormapInt;
  final HexColor hexcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 127,
      width: double.infinity,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: hexcolormapStr.length,
          itemBuilder: (context, idx) {
            Size size = MediaQuery.of(context).size;
            final currColor = hexcolormapStr[hexcolormapInt[idx]];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (currColor != null) {
                        context
                            .read<EditProfileCubit>()
                            .updateColorPreff(currColor);
                      }
                    },
                    child: Container(
                      height: size.height / 17,
                      width: size.width / 8,
                      decoration: BoxDecoration(
                        color: Color(hexcolor.hexcolorCode(currColor!)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(hexcolormapInt[idx]!,
                      style: TextStyle(
                        color: Color(hexcolor.hexcolorCode(currColor)),
                      ))
                ],
              ),
            );
          }),
    );
  }
}
