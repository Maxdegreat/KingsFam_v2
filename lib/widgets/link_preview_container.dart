import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_link_preview/simple_link_preview.dart';

class LinkPreviewContainer extends StatefulWidget {
  final LinkPreview linkP;
  final Color color;
  const LinkPreviewContainer({Key? key, required this.linkP, required this.color}) : super(key: key);

  @override
  State<LinkPreviewContainer> createState() => LinkPreviewContainerState();
}

class LinkPreviewContainerState extends State<LinkPreviewContainer> {

  @override
  void initState() {
  
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: 
          Container(
            padding: EdgeInsets.only(left: 5.0),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.linkP.title != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.linkP.title!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 15),
                            maxLines: 3,
                          ),
                        )
                      ],
                      if (widget.linkP.description != null && widget.linkP.description!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.linkP.description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 15, color: Colors.blueAccent),
                            maxLines: 3,
                          ),
                        )
                      ],
                      if (widget.linkP.image != null) ...[
                        // height: MediaQuery.of(context).size.width > 400 ? 200 : MediaQuery.of(context).size.width / 5,
                        // width: MediaQuery.of(context).size.width > 400 ? 200 : MediaQuery.of(context).size.width / 5,
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              widget.linkP.image!,
                              fit: BoxFit
                                  .contain, // or BoxFit.cover, BoxFit.fill, BoxFit.fitWidth, etc.
                              alignment: Alignment
                                  .center, // or Alignment.topLeft, Alignment.bottomRight, etc.
                            ))
                      ]
                    ],
                  ),
                ),
              ),
          )
    
    );
  }
}
