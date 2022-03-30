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
    pb = args.context;
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              create: (_) => EditProfileCubit(
                  profileBloc: args.context.read<ProfileBloc>(),
                  storageRepository: context.read<StorageRepository>(),
                  userrRepository: context.read<UserrRepository>()),
              child: EditProfileScreen(
                userr: args.context.read<ProfileBloc>().state.userr, 
                args: args,
              ),
            ));
  }

  EditProfileScreen({required this.args, required this.userr});
  
  final Userr userr;
  final EditProfileScreenArgs args;


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
          title: Text('Edit Profile Fam'),
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
          return SingleChildScrollView(
            child: Column(
              children: [
                if (state.status == EditProfileStatus.submitting)
                  const LinearProgressIndicator(),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _pickBannerImage(context),
                      child: BannerImage(
                        isOpasaty: false,
                        bannerImageUrl: widget.userr.bannerImageUrl,
                        bannerImage: state.bannerImage,
                      ),
                    ),
                    Positioned(
                        top: 30,
                        left: 10,
                        child: GestureDetector(
                          onTap: () => _pickProfileImage(context),
                          child: ProfileImage(
                            radius: 40.0,
                            pfpUrl: widget.userr.profileImageUrl,
                            pfpImage: state.profileImage,
                          ),
                        ))
                  ],
                  clipBehavior: Clip.none,
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
                              initialValue: widget.userr.username,
                              decoration: InputDecoration(hintText: 'Username'),
                              onChanged: (value) => context
                                  .read<EditProfileCubit>()
                                  .usernameChanged(value),
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Username can\'t be empty'
                                  : null,
                            ),
                            TextFormField(
                              initialValue: widget.userr.bio,
                              decoration: InputDecoration(hintText: 'Bio'),
                              onChanged: (value) => context
                                  .read<EditProfileCubit>()
                                  .bioChanged(value),
                              validator: (value) => value!.trim().isEmpty
                                  ? 'Bio can\'t be empty'
                                  : null,
                            ),
                            SizedBox(height: 15.0),
                            GestureDetector(
                              child: Text(
                                'My Color Pref is... ${hexToColor[widget.userr.colorPref]}',
                                style: TextStyle(color: Color(hexcolor.hexcolorCode(widget.userr.colorPref)),
                              )),
                              onTap: () => pickColorPref(args: pb!),
                            ),
                            SizedBox(height: 10.0),
                            Divider(
                              color: Colors.grey,
                              height: 5.0,
                              thickness: .5,
                            ),

                            Container(
                              width: double.infinity,
                              child: DropdownButton<String>(
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.white),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                onChanged: (String? value) {
                                  setState(() => dropdownValue = value!);
                                  context
                                      .read<EditProfileCubit>()
                                      .locationChanged(value!);
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

                            //  TextFormField(
                            //    initialValue: userr.location,
                            //    decoration: InputDecoration(hintText: 'add name of state to find commuinitys around'),
                            //    validator: (value) => value!.trim().isEmpty ? "Location Can Not be empty" : null,
                            //    onChanged: (value) => context
                            //        .read<EditProfileCubit>()
                            //        .locationChanged(value),
                            //  ),
                            SizedBox(height: 15.0),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red[400]),
                                onPressed: () => _submitForm(context, state.status == EditProfileStatus.submitting),
                                child: Text('Done!?'))
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

  // show a showmodelbottom sheet that allows the user to pick a pref color.
  // on tap of a color should update the fb db for users colorpref
  // once this has been picked setState and close the model sheet :)
  Future<void> pickColorPref({required BuildContext args}) async => showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocProvider<EditProfileCubit>(
          create: (context) => EditProfileCubit(
            userrRepository: context.read<UserrRepository>() ,
            storageRepository: context.read<StorageRepository>(), 
            profileBloc: args.read<ProfileBloc>(),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) => Container(
              height: 120,
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
                                var ctx = context.read<EditProfileCubit>();
                                ctx.updateColorPreff(currColor);
                                print("The selected color is $currColor");
                                print("In the state the color is ${ctx.state.colorPref}");
                                Navigator.pop(context);
                                // setState(() => userColorPref = currColor);
                                // this.setState(() => userColorPref = currColor);
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
            ),
          ),
        );
      });
}
//128 by 128
