import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/helpers.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/create_chat/cubit/createchat_cubit.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/widgets.dart';

class CreateChatArgs {
  final List<Userr> selectedMembers;

  CreateChatArgs({required this.selectedMembers});
}

class CreateChatScreen extends StatelessWidget {
  final List<Userr> selectedMembers;

  CreateChatScreen({
    Key? key,
    required this.selectedMembers,
  }) : super(key: key);

  static const String routeName = '/createChatScreen';

  static Route route(CreateChatArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              create: (context) => CreatechatCubit(
                  storageRepository: context.read<StorageRepository>(),
                  chatRepository: context.read<ChatRepository>(),
                  userrRepository: context.read<UserrRepository>()),
              child: CreateChatScreen(selectedMembers: args.selectedMembers),
            ));
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Chat'),
        centerTitle: true,
      ),
      body: BlocConsumer<CreatechatCubit, CreatechatState>(
        listener: (context, state) {
          if (state.status == CreateChatStatus.success)
            Navigator.of(context).popUntil((_) => count++ >= 2);
          if (state.status == CreateChatStatus.error) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message));
          }
        },
        builder: (context, state) {
          List<String> userIds =
              selectedMembers.map((user) => user.id).toList();
          userIds.add(context.read<AuthBloc>().state.user!.uid);

          //selectedMembers.add(context.read<AuthBloc>().state.user);
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.status == CreateChatStatus.loading)
                    LinearProgressIndicator(
                      color: Colors.red[400],
                    ),
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: () => _pickChatAvatar(context),
                    child: ProfileImage(
                      radius: 50,
                      pfpUrl: state.chat.imageUrl,
                      pfpImage: state.chatAvatar,
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(right: 100),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        decoration:
                            InputDecoration(hintText: 'add a group chat name'),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return 'Sorry fam, must add a name';
                          } else if (value.length > 25) {
                            return 'The name must be less than 25 characters';
                          } else
                            return null;
                        },
                        onSaved: (value) => context
                            .read<CreatechatCubit>()
                            .nameOnChanged(value!),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '${selectedMembers.length} group members')
                  ])),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(right: 100),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 7.5,
                      width: double.infinity,
                      child: ListView.builder(
                        itemCount: selectedMembers.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          final addedMember = selectedMembers[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              child: Column(
                                children: [
                                  ProfileImage(
                                      radius: 30,
                                      pfpUrl: addedMember.profileImageUrl),
                                  SizedBox(height: 8),
                                  Text(addedMember.username)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 35.0,
                    color: Colors.red[400],
                    child: TextButton(
                        onPressed: () => _submit(
                            context,
                            userIds,
                            state.status == CreateChatStatus.loading,
                            state.chatAvatar),
                        child: Text(
                          'Create',
                          style: Theme.of(context).textTheme.bodyText1,
                        )),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
// th esubmit function
  void _submit(BuildContext context, List<String> userIds, bool loading,
      File? avatar) async {
    final state = context.read<CreatechatCubit>();

    if (_formKey.currentState!.validate() && !loading && avatar != null) {
      _formKey.currentState!.save();

      //updates the states member list
      context.read<CreatechatCubit>().userListUpdated(userIds);

      //print('the users are ${state.state.usersList}');
      final user = await context
          .read<UserrRepository>()
          .getUserrWithId(userrId: context.read<AuthBloc>().state.user!.uid);
      state.populateRecentSender(user.id);

      context.read<CreatechatCubit>().submit();
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(content: 'Make sure you added a avatar image'));
    }
  }
}

void _pickChatAvatar(BuildContext context) async {
  final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context, cropStyle: CropStyle.circle, title: 'Chat Avatar');
  if (pickedFile != null) {
    context.read<CreatechatCubit>().chatAvatarOnChanged(pickedFile);
  }
}








// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:kingsfam/blocs/auth/auth_bloc.dart';
// import 'package:kingsfam/helpers/helpers.dart';
// import 'package:kingsfam/models/models.dart';
// import 'package:kingsfam/repositories/repositories.dart';
// import 'package:kingsfam/widgets/widgets.dart';

// import 'cubit/buildchurch_cubit.dart';

// class BuildChurchArgs {
//   final List<Userr> selectedMembers;

//   BuildChurchArgs({required this.selectedMembers});
// }

// class BuildChurch extends StatefulWidget {
//   final List<Userr> selectedMembers;
//   const BuildChurch({Key? key, required this.selectedMembers})
//       : super(key: key);

//   static const String routeName = '/buildChurch';

//   static Route route(BuildChurchArgs args) {
//     return MaterialPageRoute(
//         settings: const RouteSettings(name: routeName),
//         builder: (context) => BlocProvider<BuildchurchCubit>(
//               create: (_) => (BuildchurchCubit(
//                   authBloc: context.read<AuthBloc>(),
//                   userrRepository: context.read<UserrRepository>(),
//                   storageRepository: context.read<StorageRepository>(),
//                   churchRepository: context.read<ChurchRepository>())),
//               child: BuildChurch(selectedMembers: args.selectedMembers),
//             ));
//   }

//   @override
//   _BuildChurchState createState() => _BuildChurchState();
// }

// class _BuildChurchState extends State<BuildChurch> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     //widget.selectedMembers.insert(0, ) do this in cubit, inset urself at 0 and do via
//     //cubit also remove ur name from querry in add user thats a big part of the app mate
//     //use get user with id and auth bloc
//     int popScreens = 0;

//     return BlocConsumer<BuildchurchCubit, BuildchurchState>(
//       listener: (context, state) {
//         if (state.status == BuildChurchStatus.error) {
//           ErrorDialog(
//             content: 'hmm, something went worong. check your connection',
//           );
//         } else if (state.status == BuildChurchStatus.success) {
//           Navigator.of(context).popUntil((_) => popScreens++ >= 3);
//         }
//       },
//       builder: (context, state) {
//         _extractMemberId(context, widget.selectedMembers);
//         return Scaffold(
//           //appBar: AppBar(
//           //  title: Text('Virtural Church'),
//           //),
//           body: CustomScrollView(slivers: [
//             SliverAppBar(
//               expandedHeight: MediaQuery.of(context).size.height / 3,
//               flexibleSpace: FlexibleSpaceBar(
//                   //if state.imageFile == null show the image icon else show the selected file
//                   background: GestureDetector(
//                 onTap: () => _onChurchImageChanged(context),
//                 child: Container(
//                   height: MediaQuery.of(context).size.height / 3,
//                   decoration: state.imageFile != null
//                       ? BoxDecoration(
//                           image: DecorationImage(
//                               image: FileImage(state.imageFile!),
//                               fit: BoxFit.fitWidth))
//                       : null,
//                   child: state.imageFile != null
//                       ? null
//                       : FaIcon(FontAwesomeIcons.image),
//                 ),
//               )),
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             if (state.status == BuildChurchStatus.loading)
//                               LinearProgressIndicator(
//                                 color: Colors.red[400],
//                               ),
//                             TextFormField(
//                               decoration:
//                                   InputDecoration(hintText: 'Church Name'),
//                               onChanged: (value) => context
//                                   .read<BuildchurchCubit>()
//                                   .onNameChanged(value),
//                             ),
//                             TextFormField(
//                               decoration: InputDecoration(hintText: 'location'),
//                               onChanged: (value) => context
//                                   .read<BuildchurchCubit>()
//                                   .onLocationChanged(value),
//                             ),
//                             ConstrainedBox(
//                               constraints:
//                                   BoxConstraints(maxHeight: 100, minHeight: 50),
//                               child: TextFormField(
//                                 maxLines: null,
//                                 expands: true,
//                                 decoration: InputDecoration(
//                                     hintText: 'Mission statement'),
//                                 onChanged: (value) => context
//                                     .read<BuildchurchCubit>()
//                                     .onAboutChanged(value),
//                                 validator: (value) => value!.length < 200
//                                     ? null
//                                     : 'use less than 200 characters',
//                               ),
//                             ),
//                             SizedBox(height: 5.0),
//                             Text('Virtural Church members'),
//                             SizedBox(height: 5.0),
//                             Stack(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () =>
//                                       print(widget.selectedMembers.length),
//                                   child: Container(
//                                     height:
//                                         MediaQuery.of(context).size.height / 3,
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[900],
//                                         borderRadius:
//                                             BorderRadius.circular(10.0)),
//                                     child: ListView.builder(
//                                       itemCount: widget.selectedMembers.length,
//                                       itemBuilder:
//                                           (BuildContext context, int index) {
//                                         Userr user =
//                                             widget.selectedMembers[index];
//                                         return Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 10.0),
//                                           child: ListTile(
//                                             leading: ProfileImage(
//                                                 pfpUrl: user.profileImageUrl,
//                                                 radius: 35),
//                                             title: Text(user.username),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                               clipBehavior: Clip.none,
//                             ),
//                             SizedBox(height: 10.0),
//                             ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     primary: Colors.red[400]),
//                                 onPressed: () => submitChurch(
//                                     context: context,
//                                     isSubmitting: state.status ==
//                                         BuildChurchStatus.loading),
//                                 child: Text(
//                                   'CREATE',
//                                   style: TextStyle(letterSpacing: 1.5),
//                                 ))
//                           ],
//                         ))
//                   ],
//                 ),
//               ),
//             ),
//           ]),
//         );
//       },
//     );
//   }

//   void _onChurchImageChanged(BuildContext context) async {
//     final pickedFile = await ImageHelper.pickImageFromGallery(
//         context: context,
//         cropStyle: CropStyle.rectangle,
//         title: "Church Banner Image");
//     if (pickedFile != null)
//       context.read<BuildchurchCubit>().onImageChanged(pickedFile);
//   }

//   void submitChurch(
//       {required BuildContext context, required bool isSubmitting}) {
//     if (!isSubmitting) context.read<BuildchurchCubit>().submit();
//   }

//   void _extractMemberId(BuildContext context, List<Userr> users) {
//     List<String> ids = users.map((e) => e.id).toList();
//     context.read<BuildchurchCubit>().onMemberIdsAdded(ids);
//   }
// }

