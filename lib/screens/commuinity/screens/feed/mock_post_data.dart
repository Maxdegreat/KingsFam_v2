import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';

class MockPostData {
  
  

  static List<Widget> getMock2PostContainers() {
    return _generateFiles2();
  }

  static List<Widget> getMock4PostContainers() {
    return _generateFiles4();
  }

  static List<Post> getMockPosts2 = [
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
  ];

  static List<Post> getMockPosts4 = [
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
    Post.empty.copyWith(author: Userr.empty.copyWith(username: "We are mockTesting")),
  ];

  

}

List<Widget> _generateFiles2() {

  List<String> paths = [];
  String path1 = 'assets/mock_photos/1.jpg';
  String path2 = 'assets/mock_photos/2.jpg';
  // String path3 = 'assets/mock_photos/3.jpg';
  // String path4 = 'assets/mock_photos/4.jpg';
  // String path5 = 'assets/mock_photos/5.jpg';
  // String path6 = 'assets/mock_photos/6.jpg';
  // String path7 = 'assets/mock_photos/7.jpg';
  paths.add(path1);
  paths.add(path2);
  // paths.add(path3);
  // paths.add(path4);
  // paths.add(path5);
  // paths.add(path6);
  // paths.add(path7);


  List<Widget> widgets = [];
  for (var i in paths) {
    Widget mockPostView = _createMockPostView(i);
    widgets.add(mockPostView);
  }

  return widgets;

}

List<Widget> _generateFiles4() {



  List<String> paths = [];
 
  String path1 = 'assets/mock_photos/1.jpg';
  String path2 = 'assets/mock_photos/2.jpg';
  String path3 = 'assets/mock_photos/3.jpg';
  String path4 = 'assets/mock_photos/4.jpg';
  String path5 = 'assets/mock_photos/5.jpg';
  String path6 = 'assets/mock_photos/6.jpg';
  // String path7 = 'assets/mock_photos/7.jpg';

  paths.add(path1);
  paths.add(path2);
  paths.add(path3);
  paths.add(path4);
  paths.add(path5);
  paths.add(path6);
  // paths.add(path7);


  List<Widget> widgets = [];
  for (var i in paths) {
    Widget mockPostView = _createMockPostView(i);
    widgets.add(mockPostView);
  }

  return widgets;

}

  // ------------- helpers --------------------------------

  Widget _createMockPostView(String path) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(path))
      ),
    );
  }