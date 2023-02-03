
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_link_preview/simple_link_preview.dart';

class LinkPreviewContainer extends StatefulWidget {
  final String link;
  const LinkPreviewContainer({Key? key, required this.link}) : super(key: key);

  @override
  State<LinkPreviewContainer> createState() => LinkPreviewContainerState();
}

class LinkPreviewContainerState extends State<LinkPreviewContainer> {
  LinkPreview? _preview;

  @override
  void initState() {
    _getPreview();
    super.initState();
  }

  _getPreview() {
    // await Future.delayed(Duration(seconds: 1));
    SimpleLinkPreview.getPreview(widget.link).then((link) {
      _preview = link;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //log(_preview!.toString());
    String? _title;
    String? _imageUrl;
    String? _description;
    if (_preview != null) {
      _title = _preview!.title != null ? _preview!.title : "";
      _imageUrl = _preview!.image != null ? _preview!.image : null;
      _description = _preview!.description != null ? _preview!.description : null;
    }
    return _preview != null
        ? Container(
            width:  MediaQuery.of(context).size.width/ 1.4,
            decoration: BoxDecoration(
              color: Color.fromARGB(110, 255, 193, 7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _preview != null
                  ? [
                    
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_title != null) ... [
                        Padding(
                         padding: const EdgeInsets.only(top: 0.0, bottom: 4, left: 4),
                          child: Text(_title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: _description!=null||(_description!=null&&_description.length<5) ? 2 : null,
                              style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white, fontSize: 15)),
                        ),
                      ],
                        
                    
                      if (_description != null) ... [
                        Padding(
                         padding: const EdgeInsets.only(top: 0, bottom: 4, left: 4),
                          child: Text(_description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white54, fontSize: 15)),
                        ),
                      ],
                        ],
                      ),
                    ),

                      _imageUrl != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: MediaQuery.of(context).size.width/ 5,
                                width: MediaQuery.of(context).size.width/ 5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.0),
                                    image: DecorationImage( fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            _imageUrl))),
                              ),
                            )
                          : SizedBox.shrink(),
                    ]
                  : [],
            ),
          )
        : Container(
            height: ( MediaQuery.of(context).size.width/ 5 ) + 8,
            width: MediaQuery.of(context).size.width/ 1.4,
            child: Center(child: Text("Loading...")),
            decoration: BoxDecoration(
              color: Color.fromARGB(110, 255, 193, 7),
              borderRadius: BorderRadius.circular(4),
              
            ));
  }


}
