import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/config/type_of.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chat_room_settings/cubit/roomsettings_cubit.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ChatRoomSettingsArgs {
  final Chat chat;
  ChatRoomSettingsArgs({
    required this.chat,
  });
}

class ChatRoomSettings extends StatelessWidget {
  final Chat chat;
  ChatRoomSettings({
    Key? key,
    required this.chat,
  }) : super(key: key);

  static const String routeName = '/chatRoomSettings';

  static Route route({required ChatRoomSettingsArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              create: (context) => RoomsettingsCubit(
                  storageRepository: context.read<StorageRepository>(),
                  chatRepository: context.read<ChatRepository>(),
                  userrRepository: context.read<UserrRepository>()),
              child: ChatRoomSettings(
                chat: args.chat,
              ),
            ));
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RoomsettingsCubit, RoomsettingsState>(
        listener: (context, state) {
          if (state.status == RoomSettingStatus.error) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message));
          }
        },
        builder: (context, state) {
          context
              .read<RoomsettingsCubit>()
              .memberList(chat.readStatus.keys.toList(), chat.readStatus.keys.length);
          return SafeArea(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  actions: [
                    TextButton(
                        onPressed: () => _submit(
                            context: context,
                            isSubmitting:
                                state.status == RoomSettingStatus.loading),
                        child: Text(
                          'Save',
                          style: Theme.of(context).textTheme.bodyText1,
                        ))
                  ],
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: GestureDetector(
                      onTap: () => _onChatImageChanged(context),
                      child: BannerImage(
                        bannerImage: state.chatAvatar,
                        bannerImageUrl: chat.imageUrl,
                        isOpasaty: true,
                      ),
                    ),
                    title: Text(
                      '${chat.chatName}\'s room',
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _key,
                          child: TextFormField(
                            initialValue: chat.chatName,
                            decoration:
                                InputDecoration(hintText: 'update room name'),
                            onChanged: (value) => context
                                .read<RoomsettingsCubit>()
                                .onNameChanged(value),
                            validator: (value) {
                              if (value!.length > 15) {
                                return 'The name must be less than 25 characters';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("All participantcs"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: chat.readStatus.keys.length,
                              itemBuilder: (BuildContext context, int index) {
                                Userr user = state.members.length > 0
                                    ? state.members[index]
                                    : Userr.empty;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Card(
                                      color: Colors.black,
                                      child: ListTile(
                                          leading: ProfileImage(
                                              radius: 25.0,
                                              pfpUrl: user.profileImageUrl),
                                          title: Text(user.username))),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  AddUsers.routeName,
                                  arguments: CreateNewGroupArgs(
                                      typeOf: typeOf.inviteTheFam));
                            },
                            child: Text('Invive the fam'),
                            style: TextButton.styleFrom(primary: Colors.black),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(10.0)),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Leave ${chat.chatName}\'s room?',
                              overflow: TextOverflow.fade,
                            ),
                            style: TextButton.styleFrom(primary: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),  
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit({required BuildContext context, required bool isSubmitting}) {
    if (_key.currentState!.validate() && !isSubmitting) {
      //submit changes
      _key.currentState!.save();
      context.read<RoomsettingsCubit>().submit(chat.id!);
      Navigator.of(context).pop();
    }
  }

  void _onChatImageChanged(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
        context: context,
        cropStyle: CropStyle.rectangle,
        title: "Church Banner Image");
    if (pickedFile != null)
      context.read<RoomsettingsCubit>().onAvatarChanged(pickedFile);
  }
}
