import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/models/comment_model.dart';

import 'package:kingsfam/repositories/post/base_post_repository.dart';

class PostsRepository extends BasePostsRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostsRepository({FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({required Post post}) async {
    if (post.commuinity != null)
      await _firebaseFirestore.collection(Paths.posts).add(post.toDocWithCommuinitys());
    else 
      await _firebaseFirestore.collection(Paths.posts).add(post.toDocNoCommuinitys());
  }

  Future<void> deletePost({required Post post}) async {
    _firebaseFirestore.collection(Paths.posts).doc(post.id).delete();
    print("deleated");
  }

  @override
  Future<void> createComment({required Comment comment, required Post? post}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postsComments)
        .add(comment.toDoc());
        log("added comment to firestore");
        if (post != null) {
          final notification = NotificationKF(
            fromUser: comment.author, 
            notificationType: Notification_type.comment_post, 
            date: Timestamp.now()
          );

          _firebaseFirestore.collection(Paths.noty).doc(comment.author.id).collection(Paths.notifications).add(notification.toDoc());
        }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserPostHelper({required String userId, required String? lastPostId}) async {
    return await _firebaseFirestore.collection(Paths.posts).doc(lastPostId).get();
  }
  
  @override
  Stream<List<Future<Post?>>> getUserPosts({required String userId, required int limit, required DocumentSnapshot<Map<String, dynamic>>? lastPostDoc}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    if (lastPostDoc == null) {
      return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef).limit(limit)
        .orderBy('date', descending: true) 
        .snapshots() //.snap() returns a stream of querry snaps
        //convert or map each query snap into a post
        .map((snap) => snap.docs.map((doc) => Post.fromDoc(doc)).toList());
    } else {
        return  _firebaseFirestore.collection(Paths.posts)
        .where('author', isEqualTo: authorRef).limit(limit)
        .orderBy('date', descending: true).startAfterDocument(lastPostDoc).snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDoc(doc)).toList());
    }
    
  }

  @override
  Stream<List<Future<Comment?>>> getPostComments({required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postsComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Comment.fromDoc(doc)).toList());
  }
  // GET THE USER FEED
  @override
  Future<List<Post?>> getUserFeed({required String userId, String? lastPostId, required int limit}) async {

    QuerySnapshot postSnap;
    //if last post id is null asign postSnap to Fire base firestore 
    //this means that we are getting our post for the first time
    if (lastPostId == null) {
      postSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
    } else {
      // now we are in the else. here we want to grt the docid of the last post which we pass into the 
      // function get user feed
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .doc(lastPostId)
          .get();
      print("does the last post doc exist? ${lastPostDoc.exists}");
      if (!lastPostDoc.exists) return []; // meaning we are at the end of users posts

      // recall the querry but use start after 
      postSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(limit)
          .get();
    }

    // wait for all documents and return the post.
    // var x =postSnap.docs.first.data();
    // log(x.toString());
    final posts = Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
    return posts;
  }

  // GET THE COMMUINITY FEED
  Future<List<Post?>> getCommuinityFeed({required String commuinityId, String? lastPostId}) async {

    // Build a reference catagori. this is used so i can query for a reference.
    var commuinityRef = _firebaseFirestore.collection(Paths.church).doc(commuinityId);
    QuerySnapshot postSnap;

    if (lastPostId == null) {
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      postSnap = await _firebaseFirestore
      .collection(Paths.posts)
      .where('commuinity', isEqualTo: commuinityRef)
      .orderBy('date', descending: true)
      .limit(8)
      .get();
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    } else {
      // now we just grab the actuall doc. we use this in the start after. (if the doc exist)
      final lastPostDoc = await _firebaseFirestore.collection(Paths.posts).doc(lastPostId).get();
      // where we able to get the actuall doc?
      if (!lastPostDoc.exists) return [];

    //recall the querry but use start after 
    postSnap = await _firebaseFirestore
      .collection(Paths.posts)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(8)
          .get();
    }

    final posts = Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
    return posts;

   }
 


  //CREATE LIKES FOR POSTS
  @override
  void createLike({required Post post, required String userId}) {
    //field value of post incrment by 1
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post.id)
        .update({'likes': FieldValue.increment(1)});
  //goes into the collection likes looks for the doc with post id
  //goes to the collection post likes then adds the doc user id
    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userId)
        .set({});
  }

  //DELETE LIKE FOR POSTS===============================================================================================
  @override
  void deleteLike({required String postId, required String userId}) {
    //when deleating a document go and find where it is EVERYWHERE then deleate all... um ikd what i was thinking but yeah ofc

    // just decrement by one 
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});

    //removes the user from the list of users that have liked the post.
    _firebaseFirestore
        .collection(Paths.likes)
        .doc(postId)
        .collection(Paths.postLikes)
        .doc(userId)
        .delete();
  }


  //GET LIKED POSTS
  @override
  Future<Set<String>> getLikedPostIds({ required String userId, required List<Post?> posts }) async {
    final postIds = <String>{};
    for (final post in posts) {
      final likeDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post!.id)
          .collection(Paths.postLikes)
          .doc(userId)
          .get();
      if (likeDoc.exists) postIds.add(post.id!);
    }
    return postIds;
  }
}
