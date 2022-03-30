// A PART OF THE SEARCH BLOC //

// add users takes a type of. this typeOf wil be used to determin which type of chat is being made
// acepts type of from a named pram CreateNewGroupArgs
// once typeOf has been made you can select the users to add to your chat
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/config/type_of.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/widgets.dart';

import '../screens.dart';

class CreateNewGroupArgs {
  final String typeOf;

  CreateNewGroupArgs({required this.typeOf});
}

class AddUsers extends StatefulWidget {
  final String typeOf;
  AddUsers({Key? key, required this.typeOf}) : super(key: key);

  static const String routeName = '/addUsers';

  static Route route(CreateNewGroupArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => AddUsers(typeOf: args.typeOf));
  }

  @override
  _AddUsersState createState() => _AddUsersState();
}

@override
void initState() {}

class _AddUsersState extends State<AddUsers> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //context.read<SearchBloc>().clearSearch();
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state.status == SearchStatus.error) {
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: state.failure.message,
                  ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: widget.typeOf == 'Virtural Church'
                ? Text('New Virtural Church')
                : widget.typeOf == typeOf.inviteTheFam
                    ? Text("Invite Members")
                    : Text("New Group"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          fillColor: Colors.black87,
                          filled: true,
                          hintText: 'search for the fam',
                          suffixIcon: IconButton(
                              onPressed: () {
                                context.read<SearchBloc>().clearSearch();
                                _textEditingController.clear();
                              },
                              icon: Icon(Icons.clear))),
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        context
                            .read<SearchBloc>()
                            .searchUserAdvanced(value.trim());
                      },
                    ),
                    SizedBox(height: 10.0),
                    Stack(children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 1.38,
                        width: double.infinity,
                        child: state.status == SearchStatus.initial
                            ? Center(
                                child: Text(
                                'Isiaha 43:2',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w400),
                              ))
                            : state.status == SearchStatus.loading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                // once listview is a sucess
                                : state.status == SearchStatus.success
                                    // itemCount: selected + non-selected.
                                    // itemBuilder:
                                    // itm count = 3;
                                    // inx = 3;
                                    // display -> sel + non sel with re-render for every change
                                    // sel users = 1
                                    // non sel = 2
                                    //
                                    ? ListView.builder(
                                        itemCount: state.users.length +
                                            state.selectedUsers.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index <
                                              state.selectedUsers.length) {
                                            final selectedUser =
                                                state.selectedUsers[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  context
                                                      .read<SearchBloc>()
                                                      .add(RemoveMember(
                                                          member:
                                                              selectedUser));
                                                  setState(() {});
                                                },
                                                child: FancyListTile(
                                                    username:
                                                        selectedUser.username,
                                                    imageUrl: selectedUser
                                                        .profileImageUrl,
                                                    onTap: () {
                                                      state.copyWith(
                                                          isSelected: false);
                                                    },
                                                    isBtn: true,
                                                    BR: 12.0,
                                                    height: 12.0,
                                                    width: 12.0),
                                              ),
                                            );
                                          }
                                          int userIndex = index -
                                              state.selectedUsers.length;
                                          Userr _user = state.users[userIndex];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                state.copyWith(
                                                    isSelected: true);
                                                context.read<SearchBloc>().add(
                                                    AddMember(member: _user));
                                                //print(state.selectedUsers);
                                                setState(() {});
                                              },
                                              child: FancyListTile(
                                                  username: _user.username,
                                                  imageUrl:
                                                      _user.profileImageUrl,
                                                  onTap: () {},
                                                  isBtn: false,
                                                  BR: 12.0,
                                                  height: 12.0,
                                                  width: 12.0),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(child: Text('fam not found')),
                      ),
                      Positioned(
                          bottom: 30,
                          right: 0,
                          child: state.selectedUsers.length >= 1
                              ? MaterialButton(
                                  onPressed: () {
                                    switch (widget.typeOf) {
                                      case 'Virtural Church':
                                        Navigator.of(context).pushNamed(
                                            BuildChurch.routeName,
                                            arguments: BuildChurchArgs(
                                                selectedMembers:
                                                    state.selectedUsers));

                                        break;
                                      case typeOf.inviteTheFam:
                                        Navigator.of(context).pop();

                                        break;

                                      default:
                                        Navigator.of(context).pushNamed(
                                            CreateChatScreen.routeName,
                                            arguments: CreateChatArgs(
                                                selectedMembers:
                                                    state.selectedUsers));
                                    }

                                    // print(state.selectedUsers.map((member) => member.username));
                                  },
                                  color: Colors.red[400],
                                  child: Icon(
                                    Icons.arrow_forward_sharp,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.all(20),
                                  shape: CircleBorder(),
                                )
                              : SizedBox.shrink())
                    ])
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
