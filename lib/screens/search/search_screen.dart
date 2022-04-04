import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';

import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/add_users/add_users.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';

import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();

  static const String routeName = "/SearchScreen";

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<SearchBloc>(
              create: (_) => SearchBloc(
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>(),
                  churchRepository: context.read<ChurchRepository>())
                ..add(InitializeUser(
                    currentUserrId: context.read<AuthBloc>().state.user!.uid)),
              child: SearchScreen(),
            ));
  }
}
HexColor hexcolor = HexColor();
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //--------------------------------------------------ADD TO SEARCH CUBIT THAT WAY GET CHURCH FROM STATE
    return RefreshIndicator(
        onRefresh: () async {
          context.read<SearchBloc>()
            ..add(InitializeUser(
                currentUserrId: context.read<AuthBloc>().state.user!.uid));
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                      fillColor: Colors.black87,
                      filled: true,
                      border: InputBorder.none,
                      hintText: 'search',
                      suffixIcon: IconButton(
                          onPressed: () {
                            context.read<SearchBloc>().clearSearch();
                            _textEditingController.clear();
                          },
                          icon: Icon(Icons.clear))),
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    context.read<SearchBloc>().searchUserAdvanced(value.trim());
                    //context.read<SearchBloc>().searchChurch(value.trim());
                  },
                ),
              ),
              body: BlocConsumer<SearchBloc, SearchState>(
                listener: (context, state) {
                  if (state.status == SearchStatus.error) {
                    //show error Dialog
                    showDialog(
                        context: context,
                        builder: (context) =>
                            ErrorDialog(content: state.failure.message));
                  }
                },
                builder: (context, state) {
                  return Scaffold(
                    body: _builBody(state: state, context: context),
                  );
                },
              )),
        ));
  }

  Widget _builBody(
      {required SearchState state, required BuildContext context}) {
    switch (state.status) {
      //-------------------------here I want to add a row of churches to the initial state
      case SearchStatus.initial:
      return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text("Commuinities Around You", style: TextStyle(fontSize: 20, color: Color(hexcolor.hexcolorCode('#FFC050')))),
              SizedBox(height: 5.0),
              Container(
                  height: 170,
                  child: state.churches.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.churches.length,
                          itemBuilder: (context, index) {
                            Church church = state.churches[index];
                            return GestureDetector(
                                onTap: () => navToChurch(
                                    context: context, commuinity: church),
                                child: search_Church_container(church: church));
                          },
                        )
                      : GestureDetector(
                          onTap: () => navToBuildChurch(context: context),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 165,
                              width: double.infinity,
                              color: Colors.grey[900],
                              child: Center(
                                  child: Text(
                                      "Be The First To Create A \nCommuinity From ${state.user.location}")),
                            ),
                          ),
                        )),
              SizedBox(height: 20.0),
              Text(
                "Find The Fam",
                style: TextStyle(fontSize: 20, color: Color(hexcolor.hexcolorCode('#FFC050'))),
              ),
              // to find most popular write a script that finds greater than sum of of all commuinities then
              SizedBox(height: 5.0),
              Container(
                  height: 170,
                  child: state.userExploreList.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.userExploreList.length,
                          itemBuilder: (context, index) {
                            Userr userr = state.userExploreList[index];
                            return user_explore_container(userr: userr);
                          },
                        )
                      : GestureDetector(
                          onTap: () => navToBuildChurch(context: context),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 165,
                              width: double.infinity,
                              color: Colors.grey[900],
                              child: Center(
                                  child: Text(
                                      "Be The First To Create A \nCommuinity From TikTOK\n Use: #TikTok")),
                            ),
                          ),
                        )),
              SizedBox(height: 20.0),

              Text(
                "Commuinitys All Over",
                style: TextStyle(fontSize: 20, color: Color(hexcolor.hexcolorCode('#FFC050')) ),
              ),
              // to find most popular write a script that finds greater than sum of of all commuinities then
              SizedBox(height: 5.0),
              Container(
                  height: 170,
                  child: state.chruchesList3.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.chruchesList3.length,
                          itemBuilder: (context, index) {
                            Church church = state.chruchesList3[index];
                            return search_Church_container(church: church);
                          },
                        )
                      : GestureDetector(
                        onTap: () => navToBuildChurch(context: context),
                        child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 165,
                              width: double.infinity,
                              color: Colors.grey[900],
                              child: Center(
                                  child: Text(
                                      "Be The First To Create A \nCommuinity Bible Studies\nUse #BibleStudy")),
                            ),
                          ),
                      )),
              SizedBox(height: 20.0),
            ],
          ),
        );
      case SearchStatus.loading:
        return Center(
          child: CircularProgressIndicator(
            color: Colors.red[400],
          ),
        );
      case SearchStatus.success:
        return state.users.isNotEmpty
            ? ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (BuildContext context, int index) {
                  final users = state.users[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 3.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(ProfileScreen.routeName,
                            arguments: ProfileScreenArgs(userId: users.id));
                        print('ontaped');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: FancyListTile(
                          username: users.username,
                          imageUrl: users.profileImageUrl,
                          onTap: () {},
                          isBtn: false,
                          BR: 12.0,
                          height: 12,
                          width: 12.0,
                        ),
                      ),
                    ),
                  );
                },
              )
            : CenterdText(text: 'This user cant be found');
      case SearchStatus.error:
        return CenterdText(
          text: state.failure.message,
        );
    }
  }

  void navToChurch(
      {required BuildContext context, required Church commuinity}) {
    Navigator.of(context).pushNamed(CommuinityScreen.routeName,
        arguments: CommuinityScreenArgs(commuinity: commuinity));
  }

  void navToBuildChurch({required context}) {
    Navigator.of(context).pushNamed(AddUsers.routeName,
        arguments: CreateNewGroupArgs(typeOf: 'Virtural Church'));
  }
  Widget user_explore_container({required Userr userr}) {
    return GestureDetector(
      onTap: () =>  Navigator.of(context).pushNamed(ProfileScreen.routeName,arguments: ProfileScreenArgs(userId: userr.id)),
      child: Container(
        child: Stack(
          //alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              child: Container(
                height: 140,
                width: MediaQuery.of(context).size.width * .70,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15)
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 10,
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(userr.profileImageUrl)
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Text(userr.username, style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.fade,)
                ],
              ),
            ),
            Positioned(
              bottom: 70,
              right: 50,
              child: Container(
                height: 35,
                width: 90,
                child: ElevatedButton(
                  onPressed: () {
                    String userrId = context.read<AuthBloc>().state.user!.uid;
                    String followersId = userr.id;
                    UserrRepository().followerUserr(userrId: userrId, followersId: followersId);
                    setState(() {});
                  }, 
                  child: Text( "Follow", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),),
                  style: ElevatedButton.styleFrom(primary: Colors.white54),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 10,
              child: Container(
                height: 70,
                width: 70,
                child: Icon(Icons.add, size: 50, color: Colors.red[400],),
              )
            )
          ],
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
  Widget search_Church_container({required Church church}) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          child: Container(
            height: 150,
            width: MediaQuery.of(context).size.width * .70,
            decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                image: DecorationImage(
                    image: CachedNetworkImageProvider(church.imageUrl),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        Container(
          height: 150 / 2, //use parent height / 2,
          width: MediaQuery.of(context).size.width * .70,
          decoration: BoxDecoration(color: Colors.black54),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${church.name}",
                  style: TextStyle(fontSize: 20), overflow: TextOverflow.fade),
              Text("At ${church.location}",
                  style: TextStyle(fontSize: 20), overflow: TextOverflow.fade),
              Text(
                "${church.memberIds.length} members",
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CenterdText extends StatelessWidget {
  final String text;
  const CenterdText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
