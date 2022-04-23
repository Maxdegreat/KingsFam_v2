import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
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

  @override
  Future<void> createComment({required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postsComments)
        .add(comment.toDoc());
  }

  @override
  Stream<List<Future<Post?>>> getUserPosts({required String userId}) {
    // to get users posts from firestore we will need to create a
    // query where looking at post collection and querry all doc's
    // that have an author equal to our author ref
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .orderBy('date', descending: true) // .LIMIT(8)//most recent post at the top
        .snapshots() //.snap() returns a stream of querry snaps
        //convert or map each query snap into a post
        .map((snap) => snap.docs.map((doc) => Post.fromDoc(doc)).toList());
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
  Future<List<Post?>> getUserFeed({required String userId, String? lastPostId}) async {

    QuerySnapshot postSnap;
    //if last post id is null asign postSnap to Fire base firestore 
    //this means that we are getting our post for the first time
    if (lastPostId == null) {
      postSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(8)
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
          .limit(8)
          .get();
    }

    // wait for all documents and return the post.
    final posts = Future.wait(postSnap.docs.map((doc) => Post.fromDoc(doc)).toList());
    return posts;
  }

  // GET THE COMMUINITY FEED
  Future<List<Post?>> getCommuinityFeed({required String commuinityId, String? lastPostId}) async {
    print("in the post repo looking for the commuinity feed");
    QuerySnapshot postSnap;

    if (lastPostId == null) {
      postSnap = await _firebaseFirestore
      .collection(Paths.posts)
      .where('commuinity', isEqualTo: commuinityId)
      .orderBy('date', descending: true)
      .limit(8)
      .get();
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
    var x = await posts;
    print("At the end of the posts repo, the post repo consisit of a len of ${x.length} ");
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
