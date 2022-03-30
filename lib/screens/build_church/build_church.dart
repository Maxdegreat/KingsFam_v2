// this screen assecpts a list of Userr's from the add users screen. as seen in the args.
// and handels the compleation of creating the church or commuinities. ps if looking for the extraction of member ids
// check the bottom of the file.
// after all navs back to prev pages but the church is now made :)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chats/chats_screen.dart';
import 'package:kingsfam/widgets/widgets.dart';

import 'cubit/buildchurch_cubit.dart';

class BuildChurchArgs {
  final List<Userr> selectedMembers;

  BuildChurchArgs({required this.selectedMembers});
}

class BuildChurch extends StatefulWidget {
  final List<Userr> selectedMembers;
  const BuildChurch({Key? key, required this.selectedMembers})
      : super(key: key);

  static const String routeName = '/buildChurch';

  static Route route(BuildChurchArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<BuildchurchCubit>(
              create: (_) => (BuildchurchCubit(
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  churchRepository: context.read<ChurchRepository>())),
              child: BuildChurch(selectedMembers: args.selectedMembers),
            ));
  }

  @override
  _BuildChurchState createState() => _BuildChurchState();
}

class _BuildChurchState extends State<BuildChurch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // == done i think just remove self from add users screen thats confusing...

    //widget.selectedMembers.insert(0, ) do this in cubit, inset urself at 0 and do via
    //cubit also remove ur name from querry in add user thats a big part of the app mate
    //use get user with id and auth bloc
    //int popScreens = 0;

    return BlocConsumer<BuildchurchCubit, BuildchurchState>(
      listener: (context, state) {
        if (state.status == BuildChurchStatus.error) {
          ErrorDialog(
            content: 'hmm, something went worong. check your connection',
          );
        } else if (state.status == BuildChurchStatus.success) {
          Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
          //Navigator.of(context).popAndPushNamed(ChatsScreen.routeName);
         // Navigator.of(context).popUntil((_) => popScreens++ >= 3);
        }
      },
      builder: (context, state) {
        return Scaffold(
          //appBar: AppBar(
          //  title: Text('Virtural Church'),
          //),
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
                            if (state.status == BuildChurchStatus.loading)
                              LinearProgressIndicator(
                                color: Colors.red[400],
                              ),
                            TextFormField(
                              decoration:
                                  InputDecoration(hintText: 'Church Name'),
                              onChanged: (value) => context
                                  .read<BuildchurchCubit>()
                                  .onNameChanged(value),
                              validator: (value) => value!.isEmpty
                                  ? "You need to add a name"
                                  : null,
                            ),
                            DropdownButton<String>(
                              value: Location.dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.white),
                              underline: Container(
                                height: 1,
                                color: Colors.white,                       alignment: Alignment.centerRight,
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
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: "hashTags example: #Jesus #KingsFam"),
                              onChanged: (value) => context
                                  .read<BuildchurchCubit>()
                                  .onHashTag(value.trim()),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Mission statement!'),
                              onChanged: (value) => context
                                  .read<BuildchurchCubit>()
                                  .onAboutChanged(value),
                              validator: (value) => value!.length < 200
                                  ? null
                                  : 'use less than 200 characters',
                            ),
                            SizedBox(height: 5.0),
                            Text('Virtural Church Particpants'),
                            SizedBox(height: 5.0),
                            Stack(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: ListView.builder(
                                      itemCount: widget.selectedMembers.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        Userr user =
                                            widget.selectedMembers[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: ListTile(
                                            leading: ProfileImage(
                                                pfpUrl: user.profileImageUrl,
                                                radius: 35),
                                            title: Text(user.username),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                              clipBehavior: Clip.none,
                            ),
                            SizedBox(height: 10.0),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red[400]),
                                onPressed: () => submitChurch(
                                    context: context,
                                    isSubmitting: state.status ==
                                        BuildChurchStatus.loading,
                                    isImage: state.imageFile == null),
                                child: Text(
                                  'CREATE',
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

  void _onChurchImageChanged(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
        context: context,
        cropStyle: CropStyle.rectangle,
        title: "Church Banner Image");
    if (pickedFile != null)
      context.read<BuildchurchCubit>().onImageChanged(pickedFile);
  }

  void submitChurch({required BuildContext context,required bool isSubmitting,required bool isImage}) {
    if (!isImage) { // if image not null
      if (!isSubmitting && _formKey.currentState!.validate())
        context.read<BuildchurchCubit>().submit();
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(content: "make sure you added a image"));
    }
    _extractMemberId(context, widget.selectedMembers);
    _makeAdminIds(context);
  }

  void _extractMemberId(BuildContext context, List<Userr> users) {
    List<String> ids = users.map((e) => e.id).toList();
    ids.insert(0, context.read<AuthBloc>().state.user!.uid);
    context.read<BuildchurchCubit>().onMemberIdsAdded(ids);
  }

  void _makeAdminIds(BuildContext context) {
    final currId = context.read<AuthBloc>().state.user!.uid;
    final List<String> adminIds = [];
    adminIds.add(currId);
    context.read<BuildchurchCubit>().onAdminsAdded(adminIds);
  }
}
