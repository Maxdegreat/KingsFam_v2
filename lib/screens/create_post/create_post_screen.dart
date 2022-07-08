import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/create_post/cubit/create_post_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';

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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // THIS IS USED FOR THE REASONING OF PASSING THE BUILDCONTEXT BACK TO THE PREPOST SCREEN.
  BuildContext? contextPrePost;
  // state to know if recording
  bool isInital = true;
  // camera controller which is null at first
  CameraController? controller;
  // list of cameras, ya dig
  List<CameraDescription>? cameras;
  // flash animation controllers
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  // used for the show in snack bar messaging... 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  loadCameras() async {
    controller = null;
    cameras = null;
    // ignore: non_constant_identifier_names
    var cameras_ = await availableCameras();
    // ignore: non_constant_identifier_names
    var controller_ = CameraController(cameras_[0], ResolutionPreset.medium);
    controller_.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    setState(() {
      cameras = cameras_;
      controller = controller_;
    });

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  closeCameras() async {
    if (cameras != null) cameras!.clear();
    if (controller != null) controller!.dispose();
    _flashModeControlRowAnimationController.dispose();
  }


  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    loadCameras();
    super.initState();
  }

  @override
  void dispose() {
    //_vidoeController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    closeCameras();
    super.dispose();
  }


  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (controller == null || !controller!.value.isInitialized) {
  //      return;
  //    }
  //   if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
  //     if (controller != null)
  //        controller!.dispose(); 
  //     //Navigator.of(context).pop();
  //   } else if (state == AppLifecycleState.resumed) {
  //     loadCameras();
  //   }
  // }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      log("we have closed the life cycle of the app");
      if (controller != null)
        controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      log("we have resumed the life cycle of the app");
      
      loadCameras();
    }
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //  ----------- START OF THE APP BAR
        appBar: AppBar(
          title: Text("Create Post "),
          // -------- IS APART OF THE IS INITAL, THIS USES THE BUILD CONTEXT
          leading: isInital == true
              ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ))
              : IconButton(
                  onPressed: () {
                    context.read<CreatePostCubit>().onRemovePostContent();
                    setState(() {
                      isInital = true;
                    });
                  },
                  icon: Icon(Icons.close),
                ),
          actions: [
            isInital == true
                ? SizedBox.shrink()
                :
                // -------------> IF IS INITIAL IS FALSE THEN HERE IN THE ACTIONS OF THE APP BAR WE SWITCH PASS THE PREPSOT AND CONTEXT
                // -------------> I NEED TO CREATE A GETTER FOR THE CONTEXT BECAUSE THIS NEEDS TO BE USED WHEN WE PASS THE CONTEXT

                // ------------> TODO ADD THE MADE GETTER FOR THE PREPOST CONTEXT ... DONE
                IconButton(
                    onPressed: () {
                      var prePost = context.read<CreatePostCubit>().prePost();
                      PreviewPostHelper(prepost: prePost, ctx: contextPrePost!);
                    },
                    icon: Icon(Icons.arrow_forward_ios_sharp,
                        color: Colors.white))
          ],
        ),
        key: _scaffoldKey,
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
              _formKey.currentState!.reset();
              context.read<CreatePostCubit>().reset();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                  content: Text('Post Created fam')));
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            } else if (state.status == CreatePostStatus.error) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      ErrorDialog(content: state.failure.message));
            }

            if (state.status != CreatePostStatus.initial) {
              setState(() {
                isInital = false;
              });
            } else {
              setState(() {
                isInital = true;
              });

              // BROOOO this caused the error lol ---------------> TODO look at this 😂
              // if (controller!.value.isInitialized) {
              //   // re initalizie
              //   print("NOT INITALIZED");
              //   loadCameras();
              // }

            }
          },
          builder: (context, state) {
            Size size = MediaQuery.of(context).size;
            return SafeArea(
                child: Stack(
              children: [
                state.status == CreatePostStatus.initial
                    ? camView(
                        size: size,
                        controller: controller!,
                        context: context,
                        state: state)
                    : state.videoFile != null
                        ? InitilizeVideo(videoFile: state.videoFile!)
                        : state.imageFile != null
                            ? previewPostImage(size, state)
                            : SizedBox.shrink(),
                state.status == CreatePostStatus.initial
                    ? Positioned(
                        bottom: 20,
                        right: size.width / 2.5,
                        child: Row(
                          children: [
                            galleryBtns(context, state),
                            SizedBox(width: 15),
                            GestureDetector(
                              // TODO -----------------------------> UPDATE THE BUILDCONTEXTPREPOST THAT YOU MADE AT TOP OF FILE. DONE
                              // THIS IS FOR THE REASONING... ACTUALLY JUST READ IT AGAIN.
                              onTap: () async => state.isRecording
                                  ? onStopButtonPressed()
                                  : onTakePictureButtonPressed(context, state),
                              onLongPress: () async => controller != null &&
                                      controller!.value.isInitialized &&
                                      !controller!.value.isRecordingVideo
                                  ? onVideoRecordButtonPressed()
                                  : null,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: state.isRecording
                                        ? Colors.red[400]
                                        : Colors.white,
                                    borderRadius: state.isRecording
                                        ? BorderRadius.circular(45)
                                        : BorderRadius.circular(50)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                state.status == CreatePostStatus.initial
                    ? Positioned(
                        top: 20,
                        right: 20,
                        child: GestureDetector(
                            onTap: () {
                              controller!.value.flashMode == FlashMode.off
                                  ? onSetFlashModeButtonPressed(FlashMode.torch)
                                  : onSetFlashModeButtonPressed(FlashMode.off);
                            }, // -----------------------
                            child: Container(
                              height: 25,
                              width: 25,
                              child: Icon(Icons.flash_on),
                            )))
                    : SizedBox.shrink(),
              ],
            ));
          },
        ),
      ),
    );
  }

  Widget galleryBtns(BuildContext context, CreatePostState state) {
    return state.isRecording != true
        ? Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImageHelper.pickImageFromGallery(
                      context: context,
                      cropStyle: CropStyle.rectangle,
                      title: 'Create Post');
                  if (pickedFile != null)
                  log("The picked file is not equal to null");
                    context
                        .read<CreatePostCubit>()
                        .postImageOnChanged(pickedFile);
                  setState(() {
                    contextPrePost = context;
                  });
                } ,
                child: Container(
                  height: 25,
                  width: 75,
                  child: Icon(Icons.image),
                  decoration: (BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(5))),
                ),
              ),
              // ------------------------------------------------> video from gall below image above <<<<<<<<<<<<<<<<<<< READ THAT B4 ATTEMPT TO READ CODE
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImageHelper.pickVideoFromGallery();
                  if (pickedFile != null)
                    context
                        .read<CreatePostCubit>()
                        .onStopPostRecording(pickedFile);

                  setState(() {
                    contextPrePost = context;
                  });
                },
                child: Container(
                  height: 25,
                  width: 75,
                  child: Icon(Icons.video_library),
                  decoration: (BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(5))),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  Widget camView(
      {required CameraController controller,
      required Size size,
      required BuildContext context,
      required CreatePostState state}) {
    var deviceRatio = size.width / size.height;
    var scale = size.aspectRatio * controller.value.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Stack(
      children: [
        Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(controller),
          ),
        ),
        state.isRecording == true
            ? Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  color: Colors.red[400],
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  // FLASH MODE SETTINGS -------------------
  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      // showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      log("an error in create post screen flash segment: $e");
      rethrow;
    }
  }

  // VIDEO RECORDING SEGMENT ----------------
  void onVideoRecordButtonPressed() {
    log("recordingggg");
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }

      // allow the state to know that the camera has started recording --> TODO
      context.read<CreatePostCubit>().startRecording();
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      log("error: ${e.toString()}");
      return;
    }
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        log('Video recorded to ${file.path}');
        // Need to add the video to the cubit ---> TODO
        context.read<CreatePostCubit>().onStopPostRecording(File(file.path));
        setState(() {
          contextPrePost = context;
        });
      } else {
        log("VID NOT SAVEDDDD");
      }
    });
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      log("error when stop recording is: ${e.toString()}");
      return null;
    }
  }

  // PHOTO TAKING SEGMENT --------------------
  Future<void> onTakePictureButtonPressed(
      BuildContext context, CreatePostState state) async {
    takePicture().then((XFile? file) {
      if (file != null) {
        var passFile = File(file.path);
        context.read<CreatePostCubit>().postImageOnChanged(passFile);
        setState(() {
          contextPrePost = context;
        });
      }
    });
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    if (controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      final XFile file = await controller!.takePicture();
      return file;
    } on CameraException catch (e) {
      log("The error in taking thre pic is: ${e.toString()}");
      return null;
    }
  }

//   //SELECT POST IMAGE
//   // void _selectPostImage(BuildContext context) async {
//   // final pickedFile = await ImageHelper.pickImageFromGallery(
//   // context: context, cropStyle: CropStyle.rectangle, title: 'Create Post');
//   // if (pickedFile != null) {
//   // context.read<CreatePostCubit>().postImageOnChanged(pickedFile);
//   // }
//   // }
//   //SELECT VIDEO FILE FROM GALLERY
//   void _selectPostVideo(BuildContext context) async {
//     final pickedFile = await ImageHelper.pickVideoFromGallery();
//     if (pickedFile != null) {
//       context.read<CreatePostCubit>().postVideoOnChanged(pickedFile);
//     }
//   }
// //
//   //TAKE PIC WITH CAMERA
//   // void _capturePostImage(BuildContext context) async {
//   // final pickedFile = await ImageHelper.pickImageFromCam(
//   // context: context, cropStyle: CropStyle.rectangle, title: 'Create Post');
//   // if (pickedFile != null) {
//   // context.read<CreatePostCubit>().postImageOnChanged(pickedFile);
//   // }
//   // }
// //
//   //RECORD VIDEO WITH CAMERA
//   //  void _capturePostVid(BuildContext context) async {
//   //  final pickedFile = await ImageHelper.pickVidFromCam(context: context);
//   //  if (pickedFile != null) {
//   //  context.read<CreatePostCubit>().postVideoOnChanged(pickedFile);
//   //  InitilizeVideo(videoFile: pickedFile);
//   //  }
//   //  }
// //

//   //SUBMIT THE POST TO UPLOAD
//   void _submitForm(
//       {required BuildContext context,
//       required File? postVideo,
//       required File? postImage,
//       required bool isSubmitting}) {
//     //makes sure that there is something to submit. keep in mind the image post is will be evaluated in the cubit and if it has a value it will be posted!
//     //im not too sure why we chek the quote here. I will fix this soon.
//     //add && _formKey.currentState!.validate() if an error when submitting. I removed bc i dont now why its there
//     print("we are one now in the submit form function");
//     if ((postImage != null && !isSubmitting) || (postVideo != null && !isSubmitting)) {
//       final state = context.read<CreatePostCubit>().state;
//       final cubit = context.read<CreatePostCubit>();

//       if (postImage != null) cubit.postImageOnChanged(postImage);
//       if (videoState != null) cubit.postVideoOnChanged(videoState!);

//       print("we passed a conditional test, and now we are heading to the create post cubit");
//       print("the status of the state photo is ${state.postImage == null}}");
//       print(state.status);
//       context.read<CreatePostCubit>().submit();
//     }
//   }
// }
}

// PREVIEW FOR THE POST -------> TODO should later become a class that allows for filters
Container previewPostImage(Size size, CreatePostState state) => Container(
    height: size.height,
    width: size.width,
    decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(state.imageFile!))));

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
              child: BuildVideoFile(
              controller: _videoPlayerController,
            ))
          : CircularProgressIndicator(
              color: Colors.red[400],
            );
}

// A NEW CLASS FOR SENDING THE DATA TO THE CLOUD

// A HELPER FOR THE PREVIEWPOST
void PreviewPostHelper({required PrePost prepost, required BuildContext ctx}) =>
    previewPost(prePost: prepost, contextInhearated: ctx);

// pass this a post model and from there we can do the work around with it this way we do not need too much raw minupliation of data like I had in v1 of kingsFam
Future<dynamic> previewPost(
    {required PrePost prePost, required BuildContext contextInhearated}) {
  CreatePostState?
      stateGetter; // -------------------- make sure to init this and change it in the listener
  return showModalBottomSheet(
      enableDrag: (stateGetter != null &&
              stateGetter.status == CreatePostStatus.submitting)
          ? false
          : true,
      isDismissible: (stateGetter != null &&
              stateGetter.status == CreatePostStatus.submitting)
          ? false
          : true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: contextInhearated,
      builder: (context) => BlocProvider(
          create: (context) => CreatePostCubit(
                postsRepository: context.read<PostsRepository>(),
                storageRepository: context.read<StorageRepository>(),
                churchRepository: context.read<ChurchRepository>(),
                authBloc: context.read<AuthBloc>(),
              ),
          // -----------------------------------------------------------------------> BLOC CONSUMER
          child: BlocConsumer<CreatePostCubit, CreatePostState>(
              listener: (context, state) {
            if (state.status == CreatePostStatus.submitting) {
              stateGetter = state;
            } else {
              stateGetter = null;
            }
          }, builder: (context, state) {
            var ctxshort = context.read<CreatePostCubit>();
            // TODO can you make this work later. its saying that state.prepost! is not null even tho I call ctxshort.onPrePostMade(prePost); first thing.
            // ctxshort.onPrePostMade(prePost);
            // log("state.prepost = ${state.prePost} \n and prepost = $prePost");

            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.80,
                  builder: (_, controller) => Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (state.status == CreatePostStatus.submitting)
                          LinearProgressIndicator(
                            color: Colors.red,
                          ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Center(
                              child: Container(
                                height: 125,
                                width: 130,
                                child: prePost.videoFile != null
                                    ? InitilizeVideo(
                                        videoFile: prePost.videoFile!)
                                    : null,
                                decoration: BoxDecoration(
                                  image: prePost.imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(prePost.imageFile!))
                                      : null,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text("New Post Fam, Who dis?")
                          ],
                        ),
                        Divider(
                          height: 1.5,
                          color: Colors.white,
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(hintText: 'add a caption?'),
                          onChanged: (value) =>
                              ctxshort.captionOnChanged(value),
                          validator: (value) => value!.length > 350
                              ? "Hey fam, please keep caption lower than 350 characters"
                              : null,
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          decoration:
                              InputDecoration(hintText: 'add some hashTags?'),
                          //onChanged: (value) => ctx.captionOnChanged(value),
                          //validator: (value) => value!.length > 350 ? "Hey fam, please keep caption lower than 350 characters" : null,
                        ),
                        SizedBox(height: 10),
                        Text("Posting to your feed: yeah"),
                        Text("Post to a commuinity: pick some?"),
                        SizedBox(height: 10),
                        //commuinityList(context), //------------------------------------------------------ down
                        Expanded(
                          child: Container(
                            height: 100,
                            child: FutureBuilder(
                                future: context
                                    .read<ChurchRepository>()
                                    .getCommuinitysUserIn(
                                        userrId: context
                                            .read<AuthBloc>()
                                            .state
                                            .user!
                                            .uid,
                                        limit: 30),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Church>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          Church commuinity =
                                              snapshot.data![index];
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: ListTile(
                                                  onTap: () {
                                                    if (commuinity.id! !=
                                                        state
                                                            .selectedCommuinityId) {
                                                      prePost =
                                                          prePost.copyWith(
                                                              commuinity:
                                                                  commuinity);
                                                      ctxshort.onPickCommuinity(
                                                          commuinity.id);
                                                    } else {
                                                      ctxshort.onPickCommuinity(
                                                          "Jesus Is King ... hopefully this does not bug");
                                                      prePost =
                                                          prePost.copyWith(
                                                              commuinity: null);
                                                    }
                                                  },
                                                  leading: ProfileImage(
                                                    pfpUrl: commuinity.imageUrl,
                                                    radius: 25,
                                                  ),
                                                  title: Text(commuinity.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: commuinity
                                                                      .id! ==
                                                                  state
                                                                      .selectedCommuinityId
                                                              ? Colors.green
                                                              : Colors.white)),
                                                  //trailing: isTaped(commuinity.id!),
                                                ),
                                              ),
                                              Divider(
                                                height: 1,
                                                color: Colors.white,
                                              )
                                            ],
                                          );
                                        });
                                  } else
                                    return SizedBox.shrink();
                                }),
                          ),
                        ),
                        // ------------------------------------------------------------------------------- commuinty list tile ^^^^
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (ctxshort.state.status !=
                                      CreatePostStatus.submitting) {
                                    bool subbmittingBool =
                                        ctxshort.state.status !=
                                            CreatePostStatus.submitting;
                                    log("abt to submit");
                                    _submitForm(
                                        context: context,
                                        isSubmitting: subbmittingBool,
                                        prepost: prePost);
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
                  ),
                );
              },
            );
          })));
}

_submitForm(
    {required BuildContext context,
    required bool isSubmitting,
    required PrePost prepost}) async {
  var ctx = context.read<CreatePostCubit>();
  var state = ctx.state;

  bool condition1 = isSubmitting && prepost.imageFile != null;
  bool condition2 = isSubmitting && prepost.videoFile != null;
  log("condition1: $condition1");
  log("condition2: $condition2");
  if (condition1) {
    List<int> imgInfo = await imageInfo(prepost.imageFile, prepost.videoFile);
    ctx.submit(prePost: prepost, imgInfo: imgInfo);
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  } else if (condition2) {
    ctx.submit(prePost: prepost, imgInfo: []);
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
  }
}

Future<List<int>> imageInfo(File? image, File? video) async {
  File file;
  if (image != null)
    file = image;
  else if (video != null)
    file = video;
  else
    return [120, 120];
  //File image = new File('image.png'); // Or any other way to get a File instance.
  var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  log("height: ${decodedImage.height}");
  print("height: ${decodedImage.height}");
  return [decodedImage.height, decodedImage.width];
}
