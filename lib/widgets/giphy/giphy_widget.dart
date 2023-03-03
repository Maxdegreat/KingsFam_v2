import 'dart:async';
import 'dart:developer';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:kingsfam/api/giphy.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayGif extends StatefulWidget {
  final String giphyId;
  DisplayGif({
    Key? key,
    required this.giphyId,
  }) : super(key: key);

  @override
  State<DisplayGif> createState() => _DisplayGifState();
}

class _DisplayGifState extends State<DisplayGif> {
  GiphyGif? gif;

  @override
  void initState() {
    _getGif();
    super.initState();
  }

  _getGif() {
    log("in giphy state");
    GiphyAPI.fetchGif(widget.giphyId).then((value) {
      gif = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return gif != null
        ? _showGiphyDisplay()
        : Container(
            child: Text(
            "https://api.giphy.com/v1/gifs/${widget.giphyId}",
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontSize: 15, color: Colors.blueAccent),
          ));
  }

  TextStyle buttonsTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.white,
  );

  _showGiphyDisplay() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // nav to full view
                },
                child: Container(
                  width: double.parse(gif!.images!.fixedWidth.width),
                  height: double.parse(gif!.images!.fixedWidth.height),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Container(
                    width: double.parse(gif!.images!.fixedWidth.width),
                    height: double.parse(gif!.images!.fixedWidth.height),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      child: FadeInImage.memoryNetwork(
                        placeholder:
                            kTransparentImage, // Use kTransparentImage as the placeholder
                        image: gif!.images!.fixedWidth.url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

















// class GiphyGifWidget extends StatefulWidget {
//   // final GiphyGif gif;
//   // final GiphyGetWrapper giphyGetWrapper;
//   final String giphyId;
//   final bool showGiphyLabel;
//   final BorderRadius? borderRadius;
//   final Alignment imageAlignment;
//   const GiphyGifWidget({
//     Key? key,
//     // required this.gif,
//     // required this.giphyGetWrapper,
//     required this.giphyId,
//     this.borderRadius,
//     this.imageAlignment = Alignment.center,
//     this.showGiphyLabel = true,
//   }) : super(key: key);

//   @override
//   State<GiphyGifWidget> createState() => _GiphyGifWidgetState();
// }

// class _GiphyGifWidgetState extends State<GiphyGifWidget> {
//   bool _showMenu = false;
//   Timer? _timerMenu;
//   GiphyGif? gif;

//   @override
//   void initState() {
//     _getGif();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _timerMenu?.cancel();
//     super.dispose();
//   }

//  _getGif() {
//   log("in giphy state");
//     GiphyAPI.fetchGif(widget.giphyId).then((value) {
//       gif  = value;
//       setState(() {});
//       log("gif: " + gif.toString());
//       log("value: " + value.toString());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
    
    

//     if (gif != null) {
//       log("gif is not null");
//       return 
//     } else {
//       log("gif is null");
//       return SizedBox.shrink();
//     }
    
//   }

//   _triggerShowHideMenu() {
//     // Cancel Timer
//     _timerMenu?.cancel();

//     // Show menu
//     setState(() {
//       _showMenu = true;
//     });

//     // Triger Timer
//     _timerMenu = Timer(Duration(seconds: 5), () {
//       setState(() {
//         _showMenu = !_showMenu;
//       });
//     });
//   }
// }
