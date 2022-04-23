import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

import 'package:kingsfam/widgets/commuinity_pf_image.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/video_display.dart';


class PostSingleView extends StatefulWidget {
  const PostSingleView({required this.post});
  final Post post;

  @override
  _PostSingleViewState createState() => _PostSingleViewState();
}

class _PostSingleViewState extends State<PostSingleView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userPicAndName(name: widget.post.author.username, imgurl: widget.post.author.profileImageUrl),
        viewCommuinity(commuinity: widget.post.commuinity),
        captionBox(caption: widget.post.caption, size: size),
        contentContainer(post: widget.post, size: size),
        interactions(widget.post.likes)
      ],
    );
  }

  Widget viewCommuinity({required Church? commuinity}) {
    return 

      commuinity != null ?

    Padding(
      padding: const EdgeInsets.only(top: 7.0, right: 12.0, left: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(3)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(CommuinityScreen.routeName,arguments: CommuinityScreenArgs(commuinity: commuinity)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ok add the commuinity image
                commuinity_pf_img(commuinity.imageUrl, 25, 25),
                SizedBox(width: 7),
                // add the commuinity name
                Text(commuinity.name, style: TextStyle( color:  Colors.grey[350], fontSize: 17 ),)
          
              ],
            ),
          ),
        ),
      ),
    ) :

    SizedBox.shrink();
  }

  Widget interactions(int likes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5),
      child: Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.thumb_up),
          SizedBox(width: 5),
          Container(
              //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
            decoration: BoxDecoration(  
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(7)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(likes.toString()),
            ),),
            SizedBox(width: 15,),
            Icon(Icons.message),
            SizedBox(width: 5),
            Container(
              //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
            decoration: BoxDecoration(  
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(7)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(likes.toString()),
            ),),

        ],
      ),
    );
  }

  Widget userPicAndName({required String name, required String imgurl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          ProfileImage(radius: 25, pfpUrl: imgurl),
          SizedBox(width: 10.0),
          Text(name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),)
        ],
      ),
    );
  }

  Widget captionBox({  required String? caption, required Size size}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0,),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height / 1.2,
          minWidth: size.width / 1.5
        ), 
        child: caption != null ?
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(caption, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),),
        ) 
        : SizedBox.shrink()
      ),
    );
  }

  Widget contentContainer({required Post post, required Size size}) {
    if (post.imageUrl != null) {

     

      return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: size.height / 1.7
      ),
      child: Container(

        decoration: BoxDecoration(
          image: DecorationImage(image: CachedNetworkImageProvider(post.imageUrl!), fit: BoxFit.fitWidth)
        ),
      ),
    );
    } else if (post.videoUrl != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height / 1.7
        ),
        child: VidoeDisplay(videoUrl: post.videoUrl!)
      );
    } else if (post.quote != null) {
      return Text("caption ${post.quote}");
    } else {return Text("contennt containe is empty???");}
    
  }

  Future<List<int>> getImageData(Image i, double h, double w) async {
    File image = new File('image.png'); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    return [decodedImage.height, decodedImage.width];
  }
}