import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';

import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/add_users/add_users.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/nav/widgets/bottom_nav_bar.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';

import 'package:kingsfam/widgets/widgets.dart';

import '../../widgets/church_display_column.dart';

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
                  churchRepository: context.read<ChurchRepository>()),
              child: SearchScreen(),
            ));
  }
}

HexColor hexcolor = HexColor();

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late ScrollController scrollController;
  bool initSearchScreen = false;

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(listenToScrolling);
    initSearchScreen = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void listenToScrolling() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels != 0.0 &&
          scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
        context.read<SearchBloc>()
          ..add(GrabUsersPaginate(
              currId: context.read<AuthBloc>().state.user!.uid));
      }
    }
  }

  // this is to make sure the search screen is initalized only once
  // unless refreshed. soon find a way to only load once the screen is opened
  // i usupect the need to rewrite the stack logic for that tho.

  initializeSeachScreen(BuildContext context) {
    initSearchScreen = true;
    context.read<SearchBloc>()
      ..add(InitializeUser(
          currentUserrId: context.read<AuthBloc>().state.user!.uid));
  }

  // the build method is shown below
  bool hasSeen = false;
  @override
  Widget build(BuildContext context) {
    if (context.read<BottomnavbarCubit>().state.selectedItem == BottomNavItem.search ) {
      if (!hasSeen) {
        initializeSeachScreen(context);
        hasSeen = true;
      }

    } 

    return RefreshIndicator(
        onRefresh: () async {
          context.read<SearchBloc>()
            ..add(InitializeUser(
                currentUserrId: context.read<AuthBloc>().state.user!.uid));
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
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
                appBar: AppBar(
                  toolbarHeight: 56,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      child: TextField(
                        controller:  _textEditingController,
                        decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: "Search Cm or Fam",
                        fillColor: Color(hc.hexcolorCode("#141829")!),

                        suffixIcon: IconButton(
                                onPressed: () {
                                  context.read<SearchBloc>().clearSearch();
                                  _textEditingController.clear();
                                },
                                icon: Icon(Icons.clear, size: 17,))),
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          context
                              .read<SearchBloc>()
                              .searchUserAdvanced(value.trim());
                          //context.read<SearchBloc>().searchChurch(value.trim());
                        },
                      ),
                    ),
                  ),
                    
                    ),
                
                        
                
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _builBody(state: state, context: context),
                ),
              );
            },
          )),
        ));
  }

  Widget _builBody(
      {required SearchState state, required BuildContext context}) {
    switch (state.status) {
      case SearchStatus.pag:
      case SearchStatus.initial:
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Local Communities",
                          style: GoogleFonts.aBeeZee(
                              color: Color(hexcolor.hexcolorCode('#FFC050')),
                              fontSize: 20)),
                      TextButton(
                          onPressed: () => NavHelper().navToMoreCm(
                              context, "local", context.read<SearchBloc>()),
                          child: Text(
                            "More Cm's",
                            style: Theme.of(context).textTheme.bodyText1,
                          ))
                    ],
                  ),
                  SizedBox(height: 3.0),
                  state.churches.length > 0
                      ? Container(
                          height: 205,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.churches.length,
                            itemBuilder: (context, index) {
                              Church church = state.churches[index];
                              return GestureDetector(
                                  onTap: () => navToChurch(
                                      context: context, commuinity: church),
                                  child:
                                      search_Church_container(church: church, context: context));
                            },
                          ))
                      : Container(
                          height: 170,
                          child: Center(
                              child: Text("You Are In Every Community?!?!"))),
                  SizedBox(height: 10.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Global Communitys",
                        style: GoogleFonts.aBeeZee(
                            color: Color(hexcolor.hexcolorCode('#FFC050')),
                            fontSize: 20),
                      ),
                      TextButton(
                          onPressed: () => NavHelper().navToMoreCm(
                              context, "global", context.read<SearchBloc>()),
                          child: Text(
                            "More Cm's",
                            style: Theme.of(context).textTheme.bodyText1,
                          ))
                    ],
                  ),

                  SizedBox(height: 5.0),
                  state.chruchesNotEqualLocation.length > 0
                      ? Container(
                          height: 205,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.chruchesNotEqualLocation.length,
                            itemBuilder: (context, index) {
                              Church church =
                                  state.chruchesNotEqualLocation[index];
                              return GestureDetector(
                                  onTap: () => navToChurch(
                                      context: context, commuinity: church),
                                  child:
                                      search_Church_container(church: church, context: context));
                            },
                          ))
                      : Container(
                          height: 170,
                          child: Center(child: Text("hmm, nothing to see here"))),

                  SizedBox(height: 10.0),
                  
                  Text("Join Link"),

                  SizedBox(height: 10.0),

                  Container(
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Enter A Join Link",
                      fillColor: Color(hc.hexcolorCode("#141829")!)),
                    ),
                  )
                  
                ],
              ),
            ),
            
          ],
        );

      // this is in the case that we are using the search box on a user..

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

  

  Widget ProfileCard(Userr user) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName,
          arguments: ProfileScreenArgs(userId: user.id)),
      child: Container(
        height: 110,
        width: MediaQuery.of(context).size.width * .70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCardTop(pfpImgUrl: user.profileImageUrl, bimgUrl: user.bannerImageUrl),
            Text(
              user.username.length >= 20 ? user.username.substring(0, 20) : user.username,
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.fade,
              softWrap: true,
            ),
            SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  Widget ProfileCardTop(
      {required String? bimgUrl, required String? pfpImgUrl}) {
    double widthsize = MediaQuery.of(context).size.width * .70;
    return Container(
      height: 75,
      width: widthsize,
      child: Stack(
        children: [
          BannerImage(
            isOpasaty: false,
            bannerImageUrl: bimgUrl,
            passedheight: 50,
          ),
          Positioned(
            top: 20,
            left: (65),
            child: ProfileImage(radius: 25, pfpUrl: pfpImgUrl!),
          )
        ],
      ),
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
