// A PART OF THE SEARCH BLOC //

// add users takes a type of. this typeOf wil be used to determin which type of chat is being made
// acepts type of from a named pram CreateNewGroupArgs
// once typeOf has been made you can select the users to add to your chat

import 'dart:developer';

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

class _AddUsersState extends State<AddUsers> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void dispose() {
    context.read<SearchBloc>().clearSearchBlocAll();
    _textEditingController.clear();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<SearchBloc>().followingUsersList(lastStingId: null);
    //context.read<SearchBloc>().clearSearch();
    return BlocConsumer<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state.status == SearchStatus.error) {
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: 'AddUsers: ${state.failure.message}',
                  ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: widget.typeOf == 'Virtural Church'
                ? Text(
                    'Add Fam To The Commuinity?',
                    overflow: TextOverflow.fade,
                  )
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
                          fillColor: Colors.grey[600],
                          border: OutlineInputBorder(),
                          filled: true,
                          hintText: 'search for the fam that ur following',
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
                            .searchUserAdvancedAddToCommuinity(value.trim());
                      },
                    ),
                    SizedBox(height: 10.0),
                    Stack(children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 1.38,
                        width: double.infinity,
                        child: state.status == SearchStatus.initial
                            ? state.followingUsers.length == 0
                                ? Center(
                                    child: Text(
                                      "You have to follow some fam before you can create a community!",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: state.followingUsers.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Userr user = state.followingUsers[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        child: ListTile(
                                          onTap: () {
                                            if (!state.selectedUsers
                                                .contains(user)) {
                                              context.read<SearchBloc>()
                                                ..add(AddMember(member: user));
                                              setState(() {});
                                            } else {
                                              context.read<SearchBloc>()
                                                ..add(
                                                    RemoveMember(member: user));
                                              setState(() {});
                                            }
                                          },
                                          leading: ProfileImage(
                                            pfpUrl: user.profileImageUrl,
                                            radius: 37,
                                          ),
                                          title: Text(
                                            user.username,
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                                color: state.selectedUsers
                                                        .contains(user)
                                                    ? Colors.green
                                                    : Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    })
                            : state.status == SearchStatus.loading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                // once listview is a sucess
                                : state.status == SearchStatus.success
                                    ? ListView.builder(
                                        itemCount: state.users.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          Userr user = state.users[index];
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 13),
                                            child: ListTile(
                                              onTap: () {
                                                if (!state.selectedUsers
                                                    .contains(user)) {
                                                  context.read<SearchBloc>()
                                                    ..add(AddMember(
                                                        member: user));
                                                  setState(() {});
                                                } else {
                                                  context.read<SearchBloc>()
                                                    ..add(RemoveMember(
                                                        member: user));
                                                  setState(() {});
                                                }
                                              },
                                              leading: ProfileImage(
                                                pfpUrl: user.profileImageUrl,
                                                radius: 37,
                                              ),
                                              title: Text(
                                                user.username,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500,
                                                  color: state.selectedUsers
                                                          .contains(user)
                                                      ? Colors.green
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        })
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
                                        Navigator.of(context).pushNamed(BuildChurch.routeName);

                                        break;
                                      case typeOf.inviteTheFam:
                                        Navigator.of(context).pop();

                                        break;

                                      default:
                                        Navigator.of(context).pushNamed(
                                            CreateChatScreen.routeName,
                                            arguments: CreateChatArgs(
                                                selectedMembers: state
                                                    .selectedUsers
                                                    .toList()));
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
