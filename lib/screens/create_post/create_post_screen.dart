import 'dart:developer';
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
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // THIS IS USED FOR THE REASONING OF PASSING THE BUILDCONTEXT BACK TO THE PREPOST SCREEN.
  BuildContext? contextPrePost;
  // state to know if recording
   bool isInital = true;
  // camera controller which is null at first
  CameraController? controller;
  // list of cameras, ya dig
  List<CameraDescription>? cameras;
  // used for the show in snack bar messaginer... idk lol anddd idc
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  loadCameras() async {
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
      setState(() {cameras = cameras_; controller = controller_;});

  }

  closeCameras() async {
    if (cameras != null)
      cameras!.clear();
    if (controller != null) 
      controller!.dispose();
  }


  //final TextEditingController _quoteController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    loadCameras();
    super.initState();
  }

  @override
  void dispose() {
    //_vidoeController.dispose();
    closeCameras();
    super.dispose();
  }

    void didChangeAppLifecycleState(AppLifecycleState state) {

    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      closeCameras();
    } else if (state == AppLifecycleState.resumed) {
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
        title: Text( "Create Post "),
        // -------- IS APART OF THE IS INITAL, THIS USES THE BUILD CONTEXT
        leading: isInital == true ? 
          IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.arrow_back, color: Colors.white,)) 
          : IconButton(onPressed: () {context.read<CreatePostCubit>().onRemovePostContent();  setState(() {isInital = true; });}, icon: Icon(Icons.close),),
        actions: [

          isInital == true ?
            SizedBox.shrink() :
            // -------------> IF IS INITIAL IS FALSE THEN HERE IN THE ACTIONS OF THE APP BAR WE SWITCH PASS THE PREPSOT AND CONTEXT
            // -------------> I NEED TO CREATE A GETTER FOR THE CONTEXT BECAUSE THIS NEEDS TO BE USED WHEN WE PASS THE CONTEXT

            // ------------> TODO MAKE A GETTER FOR THE PREVIEW POST!!!
             IconButton(onPressed: () { 
               var prePost = context.read<CreatePostCubit>().prePost();
               PreviewPostHelper(prepost: prePost, ctx: context); 
             },
               icon: Icon(Icons.arrow_forward_ios_sharp, color: Colors.white)
             )
            ],
      ),
      key: _scaffoldKey,
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
                _formKey.currentState!.reset();
                context.read<CreatePostCubit>().reset();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 2),backgroundColor: Colors.green,content: Text('Post Created fam')));
                Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
            } else if (state.status == CreatePostStatus.error) {
              showDialog(context: context, builder: (context) => ErrorDialog(content: state.failure.message));
            }

             if (state.status != CreatePostStatus.initial) {
                setState(() {isInital = false;});
            } else {
              setState(() {isInital = true;});
            

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

                   state.status == CreatePostStatus.initial  ? 
                     
                    camView(size: size, controller: controller!, context: context, state: state)

                    : state.videoFile != null ? InitilizeVideo(videoFile: state.videoFile!) :

                    state.imageFile != null ? previewPostImage(size, state) : SizedBox.shrink(),

                      
                   state.status  == CreatePostStatus.initial ? Positioned(
        
                      bottom: 20,
                      right: size.width / 2.5,
                      child: GestureDetector(
                        // TODO -----------------------------> UPDATE THE BUILDCONTEXTPREPOST THAT YOU MADE AT TOP OF FILE.
                        // THIS IS FOR THE REASONING... ACTUALLY JUST READ IT AGAIN.
                        onTap: () async => state.isRecording ? onStopButtonPressed() : onTakePictureButtonPressed(context, state),
                        onLongPress: () async => controller != null && controller!.value.isInitialized && !controller!.value.isRecordingVideo ? onVideoRecordButtonPressed() : null,
                        child: Container(
                          height: 80, 
                          width: 80,
                          decoration: BoxDecoration(
                            color: state.isRecording ?  Colors.red[400] : Colors.white,
                            borderRadius: state.isRecording ?   BorderRadius.circular(45) : BorderRadius.circular(50)
                          ),
                        ),
                      ),
                    ) : SizedBox.shrink()
                ],
              )
            );
          },
        ),
      ),
    );
  }

   Widget camView({required CameraController controller, required Size size, required BuildContext context, required CreatePostState state}) {
  return Stack(
    children: 
      [
        Container(
          height: size.height,
          width: size.width ,
          child: CameraPreview(controller),
        ),
        state.isRecording == true ?
        Align(
          alignment: Alignment.topCenter,
          child: LinearProgressIndicator(color: Colors.red[400],),
        ) 
        : SizedBox.shrink()
      ],
    );
  }

  // VIDEO RECORDING SEGMENT ----------------
  void onVideoRecordButtonPressed() {
    log("recordingggg");
    startVideoRecording().then((_) {
      
      if (mounted) {setState(() {});}

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
  Future<void> onTakePictureButtonPressed(BuildContext context, CreatePostState state) async {
      takePicture().then((XFile? file) {
        if (file != null) {
          var passFile = File(file.path);
          context.read<CreatePostCubit>().postImageOnChanged(passFile);
         setState(() {

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
  

//   Future<Column> oldBody(CreatePostState state, BuildContext context) async {
//     return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   //height: MediaQuery.of(context).size.height,
//                   child: Column(
//                     children: [
//                       if (state.status == CreatePostStatus.submitting) 
//                         LinearProgressIndicator(color: Colors.red,),
//                       TabBar(
//                         controller: _tabController,
//                         labelColor: Colors.red[50],
//                         unselectedLabelColor: Colors.white,
//                         indicatorColor: Colors.red[50],
//                         tabs: [
//                           //tab 1
//                           Tab(text: "Posts"),
//                           //tab 2
//                           Tab(
//                             text: "Story",
//                           ),
//                         ],
//                         //tab bar on tap
//                         onTap: (i) {
//                           context
//                               .read<CreatePostCubit>()
//                               .gallViewChanged(i == 0);
//                         },
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           await _bottomSheet(); // pisck file source
//                           setState(() {});
//                         },
//                         child: Container(
//                             color: Colors.white10,
//                             width: double.infinity,
//                             child: imageState != null
//                                 ? Image.file(
//                                     imageState!,
//                                     fit: BoxFit.fitWidth,
//                                   )
//                                 : videoState != null
//                                     ? Center(
//                                         child: InitilizeVideo(
//                                             videoFile: videoState!))
//                                     : Container(
//                                         height: 400,
//                                         child: Center(
//                                           child: Icon(Icons.image),
//                                         ))),
//                       ),
//                       SizedBox(height: 100),
//                       Align(
//                         alignment: Alignment.bottomRight,
//                         child: MaterialButton(
//                           onPressed: () {
//                             if (videoState != null || imageState != null) {
//                               sendFileTo(context);
//                             }
//                           },
//                           color: Colors.white,
//                           child: Icon(
//                             Icons.arrow_forward_sharp,
//                             color: Colors.black,
//                             size: 20,
//                           ),
//                           padding: EdgeInsets.all(20),
//                           shape: CircleBorder(),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             );
//   }


//   sendFileTo(BuildContext context) {
//     return submitPostBottomSheet(context);
//   }

//   Future<dynamic> submitPostBottomSheet(BuildContext context) {
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) => BlocProvider(
//               create: (context) => CreatePostCubit(
//                 authBloc: context.read<AuthBloc>(),
//                 churchRepository: context.read<ChurchRepository>(),
//                 postsRepository: context.read<PostsRepository>(),
//                 storageRepository: context.read<StorageRepository>(),
//               ),
//               child: BlocConsumer<CreatePostCubit, CreatePostState>(
//                 listener: (context, state) {
//                   if(state.status == CreatePostStatus.success) {
//                     context.read<CreatePostCubit>().reset();
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     duration: const Duration(seconds: 1),
//                     backgroundColor: Colors.green,
//                     content: Text('Post Created fam')));
//                     Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
//                   }
//                 },
//                 builder: (context, state) {
//                   //=================================================
//                   return Container(
//                     color: Colors.black,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.max,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         if (state.status == CreatePostStatus.submitting) 
//                           LinearProgressIndicator(color: Colors.red,),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 5.0),
//                           child: Text("Where do you want to post to Fam?"),
//                         ),
//                         Text("Commuinitys"),
//                         Expanded(
//                           child: StreamBuilder(
//                             stream: FirebaseFirestore.instance
//                                 .collection(Paths.church)
//                                 .where('memberIds',
//                                     arrayContains: context
//                                         .read<AuthBloc>()
//                                         .state
//                                         .user!
//                                         .uid)
//                                 .snapshots(),
//                             builder: (BuildContext context,
//                                 AsyncSnapshot<QuerySnapshot> snapshot) {
//                               if (snapshot.data != null &&
//                                   snapshot.data!.docs.length > 0) {
//                                 return Container(
//                                   height: 100,
//                                   child: ListView.builder(
//                                       itemCount: snapshot.data!.docs.length,
//                                       itemBuilder: (context, index) {
//                                         Church commuinity = Church.fromDoc(
//                                             snapshot.data!.docs[index]);
//                                         return ListTile(
//                                           onTap: () => context
//                                               .read<CreatePostCubit>()
//                                               .onTapedCommuinitys(
//                                                   commuinity.id!),
//                                           leading: ProfileImage(
//                                             pfpUrl: commuinity.imageUrl,
//                                             radius: 25,
//                                           ),
//                                           title: Text(commuinity.name,
//                                               overflow: TextOverflow.ellipsis),
//                                           //trailing: isTaped(commuinity.id!),
//                                         );
//                                       }),
//                                 );
//                               } else {
//                                 return Text("Join Some Commuinitys Fam!");
//                               }
//                             },
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Container(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   final state = context.read<CreatePostCubit>().state;

//                                   if (state.commuinitys.isNotEmpty) {
//                                     // call the submit function passing strings to suvmit function
//                                     print("we are in the submit function fam");
//                                     _submitForm(context: context,  postVideo: null, postImage: imageState, isSubmitting: state.status == CreatePostStatus.submitting);
//                                   } else
//                                     print("did not allow submit of \"posttt\"");
//                                 },
//                                 child: Text("POSTTT!"),
//                                 style: ElevatedButton.styleFrom(
//                                   primary: Colors.red[400],
//                                 ),
//                               )),
//                         )
//                       ],
//                     ),
//                   );

//                   //==================================================
//                 },
//               ),
//             ));
//   }

//   Future<dynamic> _bottomSheet() => showModalBottomSheet(
//       context: context,
//       builder: (context) => BlocProvider(
//             create: (context) => CreatePostCubit(
//                 postsRepository: context.read<PostsRepository>(),
//                 storageRepository: context.read<StorageRepository>(),
//                 churchRepository: context.read<ChurchRepository>(),
//                 authBloc: context.read<AuthBloc>()),
//             child: StatefulBuilder(
//               builder: (BuildContext context, setState) {
//                 return Container(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final pickedFile =
//                                 await ImageHelper.pickImageFromGallery(
//                                     context: context,
//                                     cropStyle: CropStyle.rectangle,
//                                     title: 'Create Post');
//                             if (pickedFile != null) {
//                               context
//                                   .read<CreatePostCubit>()
//                                   .postImageOnChanged(pickedFile);
//                               context
//                                   .read<CreatePostCubit>()
//                                   .state
//                                   .copyWith(postVideo: null);
//                               videoState = null;
//                             }
//                             setState(() => imageState = pickedFile);
//                             this.setState(() {});
//                             Navigator.pop(context);
//                           },
//                           //child: context.read<CreatePostCubit>().state.postImage == null ? Icon(Icons.camera) : Icon(Icons.ac_unit),),
//                           child: Icon(Icons.camera),
//                           style: ElevatedButton.styleFrom(
//                               primary: Colors.red[400]),
//                         ),
//                       ),
//                       Container(
//                         child: ElevatedButton(
//                             onPressed: () async {
//                               final pickedFile =
//                                   await ImageHelper.pickVideoFromGallery();
//                               if (pickedFile != null) {
//                                 context
//                                     .read<CreatePostCubit>()
//                                     .postVideoOnChanged(pickedFile);
//                                 context
//                                     .read<CreatePostCubit>()
//                                     .state
//                                     .copyWith(postImage: null);
//                                 imageState = null;
//                               }
//                               setState(() => videoState = pickedFile);
//                               this.setState(() {});
//                               Navigator.pop(context);
//                             },
//                             child: Icon(Icons.video_camera_back)),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ));
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
Container previewPostImage(Size size, CreatePostState state) => Container(height: size.height, width: size.width, decoration: BoxDecoration( image: DecorationImage(image: FileImage(state.imageFile!)) ));


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
    
// A NEW CLASS FOR SENDING THE DATA TO THE CLOUD

// A HELPER FOR THE PREVIEWPOST 
void PreviewPostHelper({required PrePost prepost, required BuildContext ctx}) => previewPost(prepost: prepost, context: ctx);

// pass this a post model and from there we can do the work around with it this way we do not need too much raw minupliation of data like I had in v1 of kingsFam
Future<dynamic> previewPost({ required PrePost prepost, required BuildContext context}) {
  var ctx = context.read<CreatePostCubit>();
  return showModalBottomSheet(
     enableDrag: ctx.state.status == CreatePostStatus.submitting ? false : true,
     isDismissible: ctx.state.status == CreatePostStatus.submitting ? false : true,
     isScrollControlled: true,
     backgroundColor: Colors.transparent,
    context: context, builder: (BuildContext context) {
      return DraggableScrollableSheet(initialChildSize: 0.80, builder: (_, controller) =>
         Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (ctx.state.status == CreatePostStatus.submitting) 
                LinearProgressIndicator(color: Colors.red,),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 125,
                    width: 130,
                    child: prepost.videoFile != null ? InitilizeVideo(videoFile: prepost.videoFile!) : null,
                    decoration: BoxDecoration(image: prepost.imageFile != null ? DecorationImage(image: FileImage(ctx.state.imageFile!)) : null,),
                  ),
                  SizedBox(height: 5),
                  Text("New Post Fam, Who dis?")
                ],
              ),
              Divider(height: 1.5, color: Colors.white,),
              TextFormField(
                decoration: InputDecoration(hintText: 'add a caption?'),
                onChanged: (value)  {ctx.captionOnChanged(value);  print(ctx.state.caption);},
                validator: (value) => value!.length > 350 ? "Hey fam, please keep caption lower than 350 characters" : null,
              ),
              SizedBox(height: 5),
              TextFormField(
                decoration: InputDecoration(hintText: 'add some hashTags?'),
                //onChanged: (value) => ctx.captionOnChanged(value),
                //validator: (value) => value!.length > 350 ? "Hey fam, please keep caption lower than 350 characters" : null,
              ),
              SizedBox(height: 10),
              Text("Posting to your feed: yeah"),
              Text("Post to a commuinity: pick some?"),
              SizedBox(height: 10),
              commuinityList(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container( 
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {  
                        if (ctx.state.status != CreatePostStatus.submitting) {
                          _submitForm(context: context, isSubmitting: ctx.state.status != CreatePostStatus.submitting);
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
    }
  );
  
}

  Expanded commuinityList(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Paths.church)
            .where('memberIds',arrayContains: context.read<AuthBloc>().state.user!.uid)
            .snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
             if (snapshot.data != null &&
              snapshot.data!.docs.length > 0) {
            return Container(
              height: 100,
              child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Church commuinity = Church.fromDoc(
                        snapshot.data!.docs[index]);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            onTap: () {},
                            leading: ProfileImage(
                              pfpUrl: commuinity.imageUrl,
                              radius: 25,
                            ),
                            title: Text(commuinity.name,
                                overflow: TextOverflow.ellipsis),
                            //trailing: isTaped(commuinity.id!),
                          ),
                        ),
                        Divider(height: 1, color: Colors.white,)
                      ],
                    );
                  }),
            );
          } else {
            return Text("Join Some Commuinitys Fam!");
          }
        },
      ),
    );
  }

_submitForm({required BuildContext context, required bool isSubmitting}) {
  var ctx = context.read<CreatePostCubit>();
  var state = ctx.state;
  if (!isSubmitting && (state.imageFile != null || state.videoFile != null))
    log('submittingggggggggggggg');
    ctx.submit();
}
