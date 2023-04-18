import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/repositories/post/base_post_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';

class PostsRepository extends BasePostsRepository {
  final FirebaseFirestore _firebaseFirestore;
  PostsRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({required Post post}) async {
    if (post.commuinity != null)
      await _firebaseFirestore
          .collection(Paths.posts)
          .add(post.toDocWithCommuinitys());
    else
      await _firebaseFirestore
          .collection(Paths.posts)
          .add(post.toDocNoCommuinitys());
  }

  Future<void> deletePost({required Post post}) async {
    // go to storage and delete the post base on ref
    StorageRepository().deletePost(p: post);
    _firebaseFirestore.collection(Paths.posts).doc(post.id).delete();
    print("deleated");
  }

  Future<void> onAddReply(
      {required Comment comment,
      required Post post,
      required String content}) async {
    String path = comment.highId == null ? comment.id! : comment.highId!;
    Comment newComment = Comment(
        postId: post.id!,
        author: comment.author,
        content: content,
        date: Timestamp.now(),
        highId: path);

    final postDoc = await _firebaseFirestore.collection(Paths.posts).doc(post.id!);

    _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot postSnap_ = await transaction.get(postDoc);

      if (!postSnap_.exists) {
        throw Exception("postSnap does not exist, can not update post");
      }

      Map<String, dynamic> data = postSnap_.data() as Map<String, dynamic>;
      int updatedCount = data['commentCount'] ?? 0;
      updatedCount += 1;

      transaction.update(postDoc, {"CommentCount": updatedCount});
    });

    // to have correct top level comment
    // highId is a copy of the id. used to detect original comment so that nesting of
    // comments does not get lost.

      _firebaseFirestore
          .collection(Paths.comments)
          .doc(post.id)
          .collection(Paths.postsComments)
          .doc(path)
          .collection(Paths.commentReply)
          .add(newComment.toDoc());
    

    if (post.id != null) {
      final notification = NotificationKF(
          fromUser: comment.author,
          msg: "someone commented on your post",
          date: Timestamp.now());

      _firebaseFirestore
          .collection(Paths.noty)
          .doc(post.author.id)
          .collection(Paths.notifications)
          .add(notification.toDoc());
    }
  }

  @override
  Future<void> createComment({required Comment comment, required Post? post}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postsComments)
        .add(comment.toDoc());

    final postDoc =
        await _firebaseFirestore.collection(Paths.posts).doc(post!.id);

    _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot postSnap_ = await transaction.get(postDoc);

      if (!postSnap_.exists) {
        throw Exception("postSnap does not exist, can not update post");
      }

      Map<String, dynamic> data = postSnap_.data() as Map<String, dynamic>;
      int updatedCount = data['commentCount'] ?? 0;
      updatedCount += 1;

      transaction.update(postDoc, {"CommentCount": updatedCount});
    });

    // if (post != null) {
    //   final notification = NotificationKF(
    //       fromUser: comment.author,
    //       msg: comment.author.username + " commented on your post",
    //       date: Timestamp.now());

    //   _firebaseFirestore
    //       .collection(Paths.noty)
    //       .doc(post.author.id)
    //       .collection(Paths.notifications)
    //       .add(notification.toDoc());
    // }
  }

  Future<List<Comment>> getCommentReplys(Comment comment, String postId, lastCommentid) async {
    String path = comment.highId == null ? comment.id! : comment.highId!;
    final List<Comment> bucket = [];
    if (lastCommentid != null) {
      final lastCommentDoc = await _firebaseFirestore
          .collection(Paths.comments)
          .doc(postId)
          .collection(Paths.postsComments)
          .doc(path)
          .collection(Paths.commentReply)
          .doc(lastCommentid)
          .get();

      var c = await _firebaseFirestore
          .collection(Paths.comments)
          .doc(postId)
          .collection(Paths.postsComments)
          .doc(path)
          .collection(Paths.commentReply)
          .limit(5)
          .orderBy('date')
          .startAfterDocument(lastCommentDoc)
          .get();

      for (var x in c.docs) {
        var z = await Comment.fromDoc(x);
        bucket.add(z!);
      }

      return bucket;
    } else {
      var c = await _firebaseFirestore
          .collection(Paths.comments)
          .doc(postId)
          .collection(Paths.postsComments)
          .doc(path)
          .collection(Paths.commentReply)
          .limit(5)
          .orderBy('date')
          .get();

      for (var x in c.docs) {
        var z = await Comment.fromDoc(x);
        bucket.add(z!);
      }
      return bucket;
    }

    return [];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserPostHelper(
      {required String userId, required String? lastPostId}) async {
    return await _firebaseFirestore
        .collection(Paths.posts)
        .doc(lastPostId)
        .get();
  }

  // @override
  Future<List<Post?>> getUserPosts({
      required String userId,
      required int limit,
      required DocumentSnapshot<Map<String, dynamic>>? lastPostDoc,
    }) async {

    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    QuerySnapshot? postSnap;

    if (lastPostDoc == null) {

      postSnap = await  _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .limit(limit)
        .orderBy('date', descending: true).get();

         List<Post> postList = [];

      for (var i in postSnap.docs) {
        // I want the doc and use it to get a Post then form a list.
        Post? p = await Post.fromDoc(i);
        if (p != null) {
          postList.add(p);
        }
      }
      return postList;
        
    } else {
      

      postSnap = await _firebaseFirestore
          .collection(Paths.posts)
          .where('author', isEqualTo: authorRef)
          .limit(limit)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc).get();
      
      List<Post> postList = [];

      for (var i in postSnap.docs) {
        // I want the doc and use it to get a Post then form a list.
        Post? p = await Post.fromDoc(i);
        if (p != null) {
          postList.add(p);
        }
      }
      return postList;
    }

  }

  @override
  Stream<List<Future<Comment?>>> getPostComments({required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postsComments)
        .limit(17)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Comment.fromDoc(doc)).toList());
  }

  // GET THE USER FEED
  @override
  Future<List<Post?>> getUserFeed({String? lastPostId, required int limit}) async {
    
    QuerySnapshot postSnap;
    //if last post id is null asign postSnap to Fire base firestore
    //this means that we are getting our post for the first time
    if (lastPostId == null) {
      postSnap = await _firebaseFirestore
          .collection(Paths.posts)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
    } else {
      // now we are in the else. here we want to grt the docid of the last post which we pass into the
      // function get user feed
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.posts)
          .doc(lastPostId)
          .get();

      if (!lastPostDoc.exists)
        return []; // meaning we are at the end of users posts

      // recall the querry but use start after
      postSnap = await _firebaseFirestore
          .collection(Paths.posts)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(limit)
          .get();
    }

    // wait for all documents and return the post.
    // var x =postSnap.docs.first.data();
    // log(x.toString());
    final posts =
        Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
    return posts;
  }

  // GET THE COMMUINITY FEED
  Future<List<Post?>> getCommuinityFeed(
      {required String commuinityId, String? lastPostId, int? limit}) async {
    // Build a reference catagori. this is used so i can query for a reference.
    var commuinityRef = _firebaseFirestore.collection(Paths.church).doc(commuinityId);
    QuerySnapshot postSnap;
    limit = limit == null ? 2 : limit;
    if (lastPostId == null) {
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      postSnap = await _firebaseFirestore
          .collection(Paths.posts)
          .where('commuinity', isEqualTo: commuinityRef)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final posts =
          Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
      return posts;
      // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.posts)
          .doc(lastPostId)
          .get();
      // where we able to get the actuall doc?
      if (!lastPostDoc.exists) {
        print("************** lastpost doc not exist in get church post pag. exiziting********************");
        return [];
      }

      //recall the querry but use start after
      postSnap = await _firebaseFirestore
          .collection(Paths.posts)
          .where('commuinity', isEqualTo: commuinityRef)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(limit)
          .get();
    }
    final posts =
        Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
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

  Future<void> reportPost({required String postId, required String cmId}) async {
    FirebaseFirestore.instance
          .collection(Paths.report)
          .doc(cmId)
          .set({"postId": postId});
  }

  //GET LIKED POSTS
  @override
  Future<Set<String>> getLikedPostIds(
      {required String userId, required List<Post?> posts}) async {
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
