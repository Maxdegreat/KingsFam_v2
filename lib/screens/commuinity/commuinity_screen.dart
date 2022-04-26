// this is the commuinity screen here we shold be able to acess many screens including some settings maybe if ur admin tho
// on the main room we need to pass a list of member ids which this, the church / commuinity contains. so will extract it and make the main room

//esentally this has the main room, events, storyes ,calls
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/build_church/cubit/buildchurch_cubit.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/calls_home.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/commuinity_feed.dart';
import 'package:kingsfam/screens/commuinity/screens/sounds/sounds.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscorc.dart';
import 'package:kingsfam/screens/commuinity/screens/stories/storys.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/widgets/county_tile_widget.dart';
import 'package:kingsfam/widgets/widgets.dart';

class CommuinityScreenArgs {
  final Church commuinity;

  CommuinityScreenArgs({required this.commuinity});
}

class CommuinityScreen extends StatefulWidget {
  final Church commuinity;

  const CommuinityScreen({Key? key, required this.commuinity})
      : super(key: key);

  static const String routeName = '/CommuinityScreen';
  static Route route({required CommuinityScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<BuildchurchCubit>(
              create: (context) => BuildchurchCubit(
                authBloc: context.read<AuthBloc>(),
                churchRepository: context.read<ChurchRepository>(),
                storageRepository: context.read<StorageRepository>(),
                userrRepository: context.read<UserrRepository>(),
              ),
              child: CommuinityScreen(
                commuinity: args.commuinity,
              ),
            ));
  }


  @override
  _CommuinityScreenState createState() => _CommuinityScreenState();
}

class _CommuinityScreenState extends State<CommuinityScreen> with SingleTickerProviderStateMixin {


  late TabController _tabController;
  TextEditingController _txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

 @override
 void dispose() {
   _tabController.dispose();
   super.dispose();
 }


  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user!.uid;
    return BlocConsumer<BuildchurchCubit, BuildchurchState>(
      listener: (context, state) {
        if (state.status == BuildChurchStatus.error) {
          ErrorDialog(
            content: 'hmm, something went worong. check your connection',
          );
        }
      },
      builder: (context, state) {
        context.read<BuildchurchCubit>().isCommuinityMember(widget.commuinity);
        return Scaffold(
          drawer: drawerWidget(),
            body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height / 3,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.commuinity.name),
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    widget.commuinity.imageUrl),
                                fit: BoxFit.cover)),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color> [
                              Colors.transparent,
                              Colors.black12,
                              Colors.black45,
                              Colors.black87,
                            ]
                          )
                        )
                      )  
                    ],
                  ),
                ), 
                
                actions: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.arrow_back)), _settingsBtn(), _inviteButton(), ],
              ),
              
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 50,
                                width: (MediaQuery.of(context).size.width / 2.5 ),
                                //child will pend based on weather curr id exists in comm mem ids or not
                                child: state.isMember ?
                                   ElevatedButton(
                                      onPressed: () => showLeaveCommuinity(),
                                      child: Text( "Leave" , style: TextStyle(letterSpacing: 10)),
                                      style: ElevatedButton.styleFrom(primary: Colors.grey[900])
                                    ) :
                                    ElevatedButton(
                                  onPressed: () { setState(() {_onJoinCommuinity();}); },
                                  child: Text("Join", style: TextStyle(letterSpacing: 10)),
                                  style: ElevatedButton.styleFrom(primary: Colors.red[400])
                                ) 
                                ,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Expanded(
                                child: Text(
                                  "${widget.commuinity.memberIds.length} members" ,style: TextStyle(letterSpacing: 8), overflow: TextOverflow.ellipsis),
                                  ),
                            )
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(height: 50, child: kings_cord_strbldr(userId)),
                        SizedBox(height: 30),
                        Container(
                          height: 50.0,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.grey[900]),
                            child: Text("CONTENT", style: TextStyle(letterSpacing: 10)),
                            onPressed: () => Navigator.of(context).pushNamed(CommuinityFeedScreen.routeName, arguments: CommuinityFeedScreenArgs(commuinity: widget.commuinity))
                          )
                        ),
                        //                                 THIS IS A P2, MAYBE AFTER INIT RELEACE AND SOME CORE UPDATES WE CAN ADD THIS IN A INOVATIVE  WAY!!!
                        // Container(
                        //   height: 50.0,
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //           primary: Colors.grey[900]),
                        //       onPressed: () {
                        //         Navigator.of(context).pushNamed(
                        //             SoundsScreen.routeName,
                        //             arguments: SoundsArgs(
                        //                 commuinity: widget.commuinity));
                        //       },
                        //       child: Text('SOUNDS',
                        //           style: TextStyle(letterSpacing: 10))),
                        // ),
                        //                                THIS IS A P1, MAYBE AFTER INIT RELEACE AND SOME CORE UPDATES WE CAN ADD THIS IN A INOVATIVE  WAY!!!
                        // SizedBox(height: 30),
                        // Container(
                        //   height: 50.0,
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(primary: Colors.grey[900]),
                        //       onPressed: () => Navigator.of(context).pushNamed(CommuinityFeedScreen.routeName),
                        //       child: Text('FEED', style: TextStyle(letterSpacing: 10))),
                        // ),

                        //                            THIS IS A P1, MAYBE AFTER INIT RELEACE AND SOME CORE UPDATES WE CAN ADD THIS IN A INOVATIVE  WAY!!!

                        // SizedBox(height: 30),
                        // Container(
                        //   height: 50.0,
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //           primary: Colors.grey[900]),
                        //       onPressed: () => Navigator.of(context)
                        //           .pushNamed(
                        //               StorysCommuinityScreen.routeName,
                        //               arguments: StoryCommuinityArgs(
                        //                   commuinity: widget.commuinity)),
                        //       child: Text('STORYS',
                        //           style: TextStyle(letterSpacing: 10))),
                        // ),
                        SizedBox(height: 30),
                        Container(
                          height: 50.0,
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.grey[900]),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    CallsHome.routeName,
                                    arguments: CallsHomeArgs(
                                        commuinity: widget.commuinity));
                              },
                              child: Text('CALLS',
                                  style: TextStyle(letterSpacing: 10))),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  // ignore: non_constant_identifier_names
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> kings_cord_strbldr(String userId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(widget.commuinity.id)
          .collection(Paths.kingsCord)
          .where('tag', isEqualTo: widget.commuinity.id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else if (snapshot.data!.docs.isNotEmpty) {
          final kingsCordPram = KingsCord.fromDoc(snapshot.data!.docs.first);
          return Container(
            height: 50.0,
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.grey[900]),
                onPressed: () async {
                  if (!kingsCordPram!.memberIds.contains(userId)) {
                    // add the new member to the member info and the member ids
                    FirebaseFirestore.instance.collection(Paths.church).doc(widget.commuinity.id).collection(Paths.kingsCord).doc(kingsCordPram.id).update({'memberIds' : FieldValue.arrayUnion([userId])});
                    FirebaseFirestore.instance.collection(Paths.church).doc(widget.commuinity.id).collection(Paths.kingsCord).doc(kingsCordPram.id).update({'memberInfo' : widget.commuinity.memberInfo});
                  } else {
                    Navigator.of(context).pushNamed(KingsCordScreen.routeName,
                      arguments: KingsCordArgs(
                          kingsCord: kingsCordPram,
                          commuinity: widget.commuinity));
                  }
                },
                child: Text('MAIN ROOM', style: TextStyle(letterSpacing: 10))),
          );
        } else
          return  CircularProgressIndicator();
      },
    );
  }
  Widget _settingsBtn() {
    return IconButton(onPressed: () async {
      // show a list of all users in the commuinity, this can be done using a showmodel,
      // also allow to update image or chose a rive
      // also allow to invite usesers
      final usersInCommuiinity = await context.read<BuildchurchCubit>().commuinityParcticipatents(ids: widget.commuinity.memberIds);
      showModalBottomSheet(context: context, builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            color: Colors.black,  
          ),
          child: Column(
            children: [
            //child one is a tab bar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: "Participants"),
                  Tab(text: "Edit"),
                ],
              ),
            //child 2 is the child of tab
              Expanded(
                //height: MediaQuery.of(context).size.height / 2.3,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                  _participantsView(usersInCommuiinity),
                  _editView(commuinity: widget.commuinity)
                ]),
              )
            ],
              
          ),
        );
      }); 
    }, icon: Icon(Icons.settings));
  }


  Widget drawerWidget() =>  Drawer(
    child: ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SubCommuinityTile(title: 'Houston'),
        );
      },
    ),
  );

  Widget _inviteButton() {
    return IconButton(
      icon: Icon(Icons.person_add),
      onPressed: () async {
        final following = await context.read<BuildchurchCubit>().grabCurrFollowing();
        _inviteBottomSheet(following);

      }
    );
  }

  Widget _participantsView(List<Userr> users) {
    return ListView.builder(
      itemCount: widget.commuinity.memberIds.length,
      itemBuilder: (BuildContext context, int index) {
        final user = users[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: user.id)),
            child: ListTile(leading: ProfileImage(pfpUrl: user.profileImageUrl, radius: 25,), title: Text(user.username), trailing: _moreOptinos(user: user))),
        );
      },
    );
  }

  Widget _moreOptinos({required Userr user}) {
    //check to see if the curr id is a admin or not
    final isAdmin = context.read<BuildchurchCubit>().isAdmin(commuinity: widget.commuinity);
   return IconButton(
     icon: Icon(Icons.more_vert),
     onPressed: () async {
      if (isAdmin) 
        if (context.read<AuthBloc>().state.user!.uid == user.id)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are the admin alredy...")));
        else 
          return _adminsOptions(commuinity: widget.commuinity, participatant: user);
      else 
        return _nonAdminOptions();
     },
    );
  }
  
  Future<dynamic> _adminsOptions({required Church commuinity, required Userr participatant}) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () {
                context.read<BuildchurchCubit>().makeAdmin(user: participatant, commuinity: commuinity);
                Navigator.of(context).pop();
              }, child: FittedBox(child: Text("Promote ${participatant.username} to an admin", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1,))),
              TextButton(onPressed: () {
                context.read<ChurchRepository>().leaveCommuinity(commuinity: commuinity, currId: participatant.id);
                Navigator.of(context).pop();
              }, child: FittedBox(child: Text("Remove ${participatant.username} from ${widget.commuinity.name}", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1))),
          ],
        ),
      )
    );
  }

  Future<dynamic> _nonAdminOptions() {
    return showDialog(context: context, builder: (context) => AlertDialog(content: Text("You not the admin", style: Theme.of(context).textTheme.bodyText1,)));
  }

  Widget _editView({required Church commuinity}) {
    return BlocProvider<BuildchurchCubit>(
     create: (context) => BuildchurchCubit(
     churchRepository: context.read<ChurchRepository>(), 
     storageRepository: context.read<StorageRepository>(), 
     authBloc: context.read<AuthBloc>(), 
     userrRepository: context.read<UserrRepository>()
     ),
     child: Column (
      children: [
        ListTile(title: Text("Update Commuinity name", style: Theme.of(context).textTheme.bodyText1), onTap: () async => _updateCommuinityName(commuinity: commuinity, context: context)),
        ListTile(title: Text("Update Commuinity ImageUrl", style: Theme.of(context).textTheme.bodyText1), trailing: ProfileImage(radius: 25, pfpUrl: commuinity.imageUrl), onTap: () => _updateCommuinityImage(commuinity: commuinity, ),),
        ListTile(title: Text("Update The About", style: Theme.of(context).textTheme.bodyText1), onTap: () async => _updateTheAbout(commuinity: commuinity),),
        ElevatedButton(child: Text('Update!', style: Theme.of(context).textTheme.bodyText1), onPressed: () => _updateEditView(context, commuinity))
      ]
    )
  );
  }

  void _updateEditView(BuildContext context, Church commuinity) {
    var state = context.read<BuildchurchCubit>().state;
    print("okay we are in the submit func via the update! btn");
    print("This is the state name ${state.name}");
    print("This is the commuinity name ${commuinity.name}");
    //context.read<BuildchurchCubit>().submit();
    //print(commuinity.name);
  }

  Future<dynamic> _updateCommuinityName({required Church commuinity, required BuildContext context}) async => showModalBottomSheet(context: context, builder: (context) => BlocProvider<BuildchurchCubit>(
    create: (context) => BuildchurchCubit(
      churchRepository: context.read<ChurchRepository>(), 
      storageRepository: context.read<StorageRepository>(), 
      authBloc: context.read<AuthBloc>(), 
      userrRepository: context.read<UserrRepository>()
    ), child: Container(
       width: double.infinity,
       child: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           SizedBox(height: 8.0),
           Center(
               child: Text(
             "New Name For Commuinity",
             style: TextStyle(color: Colors.white),
           )),
           SizedBox(height: 8.0),
           Padding(
             padding:
                 const EdgeInsets.symmetric(horizontal: 10.0),
             child: TextField(
                 decoration:
                     InputDecoration(hintText: "Enter a name"),
                 onChanged: (value) =>
                     _txtController.text = value),
           ),
           SizedBox(height: 8.0),
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 8.0),
             child: Container(
               width: (double.infinity * .70),
               child: ElevatedButton(
                   style: ElevatedButton.styleFrom(primary: Colors.white),
                   onPressed: () {
                     var state = context.read<BuildchurchCubit>().state;
                     if (_txtController.value.text.length != 0) {
                       print(_txtController.text);
                       print("from the update Comu... name is ${state.name}");
                       context.read<BuildchurchCubit>().onNameChanged(_txtController.text);
                       context.read<BuildchurchCubit>().lightUpdate(commuinity.id);
                       Navigator.of(context).pop();
                       _txtController.clear();
                     } else {
                       print(state.name);
                      //  showDialog(
                      //      context: context,
                      //      builder: (BuildContext context) =>
                      //          AlertDialog(
                      //            //title
                      //            title: const Text("mmm, err my boi"),
                      //            //content
                      //            content: const Text("be sure you add a name for the commuinity you are updating"),
                      //            //actions
                      //            actions: [
                      //              TextButton(
                      //                child: Text("Ok",style: TextStyle(color: Colors.green[400]),),
                      //                onPressed: () =>Navigator.of(context).pop(),
                      //              )
                      //            ],
                      //          ));
                     }
                   },
                   child: Text("Done, Upadate The Name!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),))),
           )
         ],
       ),
     ),
  ));

  Future<dynamic> _updateCommuinityImage({required Church commuinity}) async => showModalBottomSheet(context: context, builder: (context) => BlocProvider<BuildchurchCubit>(
    create: (context) => BuildchurchCubit(
      churchRepository: context.read<ChurchRepository>(), 
      storageRepository: context.read<StorageRepository>(), 
      authBloc: context.read<AuthBloc>(), 
      userrRepository: context.read<UserrRepository>()
    ), 
    child: StatefulBuilder(
      builder: (BuildContext context, setState) {
        return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                 final pickedFile = await ImageHelper.pickImageFromGallery(
                 context: context,
                cropStyle: CropStyle.rectangle,
                title: 'New Commuinity Avatar');
              if (pickedFile != null) 
                context.read<BuildchurchCubit>().onImageChanged(File(pickedFile.path));
                setState(() {});
              },
              child: Container(
                height:  MediaQuery.of(context).size.height / 3.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: context.read<BuildchurchCubit>().state.imageFile == null ?
                    DecorationImage(image: CachedNetworkImageProvider(commuinity.imageUrl), fit: BoxFit.fitWidth) :
                    DecorationImage(image: FileImage(context.read<BuildchurchCubit>().state.imageFile!), fit: BoxFit.fitWidth)
                ),
              ),
            )
          ],
        ),
      );
      },
    )
));

  Future<dynamic> _updateTheAbout({required Church commuinity}) async => showBottomSheet(context: context, builder: (context) => BlocProvider<BuildchurchCubit>(
    create: (context) => BuildchurchCubit(
      churchRepository: context.read<ChurchRepository>(), 
      storageRepository: context.read<StorageRepository>(), 
      authBloc: context.read<AuthBloc>(), 
      userrRepository: context.read<UserrRepository>()
    ),
    child: Container(
      child: Text("come back and add an expandable text form field"),
    ),
  ));

  Future<dynamic> _inviteBottomSheet(List<Userr> following) async => showModalBottomSheet(context: context, builder: (context) => BlocProvider<BuildchurchCubit>(
    create: (context) => BuildchurchCubit(
      churchRepository: context.read<ChurchRepository>(), 
      storageRepository: context.read<StorageRepository>(), 
      authBloc: context.read<AuthBloc>(), 
      userrRepository: context.read<UserrRepository>()
    ),
    child: Container(
      height: 200,
      child: Column(
        children: [
          Container(
            height: 25,
            width: double.infinity,
            color: Colors.grey[900],
            child: 
              Text("Invite fam to ${widget.commuinity.name}", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    leading: ProfileImage(pfpUrl: user.profileImageUrl, radius: 25),
                    title: Text(user.username),
                    trailing: IconButton( icon: Icon(Icons.add), onPressed: () => _showInviteDialog(user),),
                  ),
                );
              },
            ),
          )
        ],
      ),
    ),
  ));
  _showInviteDialog(Userr user) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Invite ${user.username}???", overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1),
        actions: [
          TextButton(
            child: Text("Nope, my b"),
            onPressed: () {
              Navigator.pop(context);
            }, 
          ),
          TextButton(
            child: Text("Yezzz!"),
            onPressed: () async {
              await context.read<BuildchurchCubit>().inviteToCommuinity(toUserId: user.id, commuinity: widget.commuinity);
              Navigator.pop(context);
            }, 
          )
        ],
      );
    });
  }
  _onJoinCommuinity() {
    context.read<BuildchurchCubit>().onJoinCommuinity(commuinity: widget.commuinity);
    setState(() {
      
    });
  }
  _onLeaveCommuinity() {
    context.read<BuildchurchCubit>().onLeaveCommuinity(commuinity: widget.commuinity);
    setState(() {
      
    });
  }
  showLeaveCommuinity() => 
    showModalBottomSheet(context: context, builder: (context) =>
      Container(
        //height: 200,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              //height: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                _onLeaveCommuinity();
                Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
              }, 
              child: Text("... I sad bye")),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(primary: Colors.green),
                 child: Text("Chill, I wana stay fam")),
                )
          ],
        ),
      )
    );
}