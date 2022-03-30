import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/create_post/cubit/create_post_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

enum setStateOfPostType { image, quote }
setStateOfPostType stateOfContainer = setStateOfPostType.image;

class CreatePostScreen extends StatefulWidget {
  //1 make route name
  static const String routeName = '/createPost';
  //2 make the route function
  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => BlocProvider(
              create: (context) => CreatePostCubit(
                  postsRepository: context.read<PostsRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  churchRepository: context.read<ChurchRepository>()),
              child: CreatePostScreen(),
            ));
  }

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TabController _tabController;

  //late VideoPlayerController _vidoeController;
  //late File videoFile;

  final TextEditingController _quoteController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    //_vidoeController.dispose();
    super.dispose();
  }

  //states
  // image
  File? imageState;
  // video
  File? videoState;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Posts'),
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
                _formKey.currentState!.reset();
                context.read<CreatePostCubit>().reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
                content: Text('Post Created fam')));
                Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
            } else if (state.status == CreatePostStatus.error) {
              showDialog(context: context, builder: (context) => ErrorDialog(content: state.failure.message));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    //height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        if (state.status == CreatePostStatus.submitting) 
                          LinearProgressIndicator(color: Colors.red,),
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.red[50],
                          unselectedLabelColor: Colors.white,
                          indicatorColor: Colors.red[50],
                          tabs: [
                            //tab 1
                            Tab(text: "Posts"),
                            //tab 2
                            Tab(
                              text: "Story",
                            ),
                          ],
                          //tab bar on tap
                          onTap: (i) {
                            context
                                .read<CreatePostCubit>()
                                .gallViewChanged(i == 0);
                          },
                        ),
                        GestureDetector(
                          onTap: () async {
                            await _bottomSheet(); // pisck file source
                            setState(() {});
                          },
                          child: Container(
                              color: Colors.white10,
                              width: double.infinity,
                              child: imageState != null
                                  ? Image.file(
                                      imageState!,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : videoState != null
                                      ? Center(
                                          child: InitilizeVideo(
                                              videoFile: videoState!))
                                      : Container(
                                          height: 400,
                                          child: Center(
                                            child: Icon(Icons.image),
                                          ))),
                        ),
                        SizedBox(height: 100),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: MaterialButton(
                            onPressed: () {
                              if (videoState != null || imageState != null) {
                                sendFileTo(context);
                              }
                            },
                            color: Colors.white,
                            child: Icon(
                              Icons.arrow_forward_sharp,
                              color: Colors.black,
                              size: 20,
                            ),
                            padding: EdgeInsets.all(20),
                            shape: CircleBorder(),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  sendFileTo(BuildContext context) {
    return submitPostBottomSheet(context);
  }

  Future<dynamic> submitPostBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => BlocProvider(
              create: (context) => CreatePostCubit(
                authBloc: context.read<AuthBloc>(),
                churchRepository: context.read<ChurchRepository>(),
                postsRepository: context.read<PostsRepository>(),
                storageRepository: context.read<StorageRepository>(),
              ),
              child: BlocConsumer<CreatePostCubit, CreatePostState>(
                listener: (context, state) {
                  if(state.status == CreatePostStatus.success) {
                    context.read<CreatePostCubit>().reset();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                    content: Text('Post Created fam')));
                    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                  }
                },
                builder: (context, state) {
                  //=================================================
                  return Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (state.status == CreatePostStatus.submitting) 
                          LinearProgressIndicator(color: Colors.red,),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text("Where do you want to post to Fam?"),
                        ),
                        Text("Commuinitys"),
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(Paths.church)
                                .where('memberIds',
                                    arrayContains: context
                                        .read<AuthBloc>()
                                        .state
                                        .user!
                                        .uid)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.data != null &&
                                  snapshot.data!.docs.length > 0) {
                                return Container(
                                  height: 100,
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        Church commuinity = Church.fromDoc(
                                            snapshot.data!.docs[index]);
                                        return ListTile(
                                          onTap: () => context
                                              .read<CreatePostCubit>()
                                              .onTapedCommuinitys(
                                                  commuinity.id!),
                                          leading: ProfileImage(
                                            pfpUrl: commuinity.imageUrl,
                                            radius: 25,
                                          ),
                                          title: Text(commuinity.name,
                                              overflow: TextOverflow.ellipsis),
                                          //trailing: isTaped(commuinity.id!),
                                        );
                                      }),
                                );
                              } else {
                                return Text("Join Some Commuinitys Fam!");
                              }
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final state = context.read<CreatePostCubit>().state;

                                  if (state.commuinitys.isNotEmpty) {
                                    // call the submit function passing strings to suvmit function
                                    print("we are in the submit function fam");
                                    _submitForm(context: context,  postVideo: null, postImage: imageState, isSubmitting: state.status == CreatePostStatus.submitting);
                                  } else
                                    print("did not allow submit of \"posttt\"");
                                },
                                child: Text("POSTTT!"),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400],
                                ),
                              )),
                        )
                      ],
                    ),
                  );

                  //==================================================
                },
              ),
            ));
  }

  Future<dynamic> _bottomSheet() => showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider(
            create: (context) => CreatePostCubit(
                postsRepository: context.read<PostsRepository>(),
                storageRepository: context.read<StorageRepository>(),
                churchRepository: context.read<ChurchRepository>(),
                authBloc: context.read<AuthBloc>()),
            child: StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final pickedFile =
                                await ImageHelper.pickImageFromGallery(
                                    context: context,
                                    cropStyle: CropStyle.rectangle,
                                    title: 'Create Post');
                            if (pickedFile != null) {
                              context
                                  .read<CreatePostCubit>()
                                  .postImageOnChanged(pickedFile);
                              context
                                  .read<CreatePostCubit>()
                                  .state
                                  .copyWith(postVideo: null);
                              videoState = null;
                            }
                            setState(() => imageState = pickedFile);
                            this.setState(() {});
                            Navigator.pop(context);
                          },
                          //child: context.read<CreatePostCubit>().state.postImage == null ? Icon(Icons.camera) : Icon(Icons.ac_unit),),
                          child: Icon(Icons.camera),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red[400]),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                            onPressed: () async {
                              final pickedFile =
                                  await ImageHelper.pickVideoFromGallery();
                              if (pickedFile != null) {
                                context
                                    .read<CreatePostCubit>()
                                    .postVideoOnChanged(pickedFile);
                                context
                                    .read<CreatePostCubit>()
                                    .state
                                    .copyWith(postImage: null);
                                imageState = null;
                              }
                              setState(() => videoState = pickedFile);
                              this.setState(() {});
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.video_camera_back)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ));
  //SELECT POST IMAGE
  // void _selectPostImage(BuildContext context) async {
  // final pickedFile = await ImageHelper.pickImageFromGallery(
  // context: context, cropStyle: CropStyle.rectangle, title: 'Create Post');
  // if (pickedFile != null) {
  // context.read<CreatePostCubit>().postImageOnChanged(pickedFile);
  // }
  // }
  //SELECT VIDEO FILE FROM GALLERY
  void _selectPostVideo(BuildContext context) async {
    final pickedFile = await ImageHelper.pickVideoFromGallery();
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postVideoOnChanged(pickedFile);
    }
  }
//
  //TAKE PIC WITH CAMERA
  // void _capturePostImage(BuildContext context) async {
  // final pickedFile = await ImageHelper.pickImageFromCam(
  // context: context, cropStyle: CropStyle.rectangle, title: 'Create Post');
  // if (pickedFile != null) {
  // context.read<CreatePostCubit>().postImageOnChanged(pickedFile);
  // }
  // }
//
  //RECORD VIDEO WITH CAMERA
  //  void _capturePostVid(BuildContext context) async {
  //  final pickedFile = await ImageHelper.pickVidFromCam(context: context);
  //  if (pickedFile != null) {
  //  context.read<CreatePostCubit>().postVideoOnChanged(pickedFile);
  //  InitilizeVideo(videoFile: pickedFile);
  //  }
  //  }
//

  //SUBMIT THE POST TO UPLOAD
  void _submitForm(
      {required BuildContext context,
      required File? postVideo,
      required File? postImage,
      required bool isSubmitting}) {
    //makes sure that there is something to submit. keep in mind the image post is will be evaluated in the cubit and if it has a value it will be posted!
    //im not too sure why we chek the quote here. I will fix this soon.
    //add && _formKey.currentState!.validate() if an error when submitting. I removed bc i dont now why its there
    print("we are one now in the submit form function");
    if ((postImage != null && !isSubmitting) || (postVideo != null && !isSubmitting)) {
      final state = context.read<CreatePostCubit>().state;
      final cubit = context.read<CreatePostCubit>();

      if (postImage != null) cubit.postImageOnChanged(postImage);
      if (videoState != null) cubit.postVideoOnChanged(videoState!);

      print("we passed a conditional test, and now we are heading to the create post cubit");
      print("the status of the state photo is ${state.postImage == null}}");
      print(state.status);
      context.read<CreatePostCubit>().submit();
    }
  }
}

//NEW CLASS FOR VIDEO CONFIG
class InitilizeVideo extends StatefulWidget {
  final File videoFile;
  const InitilizeVideo({required this.videoFile});

  @override
  _InitilizeVideoState createState() => _InitilizeVideoState();
}

class _InitilizeVideoState extends State<InitilizeVideo> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => _videoPlayerController.play());
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _videoPlayerController.value.isInitialized
          ? Container(
              child: BuildVideo(
              controller: _videoPlayerController,
            ))
          : CircularProgressIndicator(
              color: Colors.red[400],
            );
}
