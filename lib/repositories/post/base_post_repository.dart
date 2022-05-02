import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/models/models.dart';

abstract class BasePostsRepository {
  Future<void> createPost({required Post post});
  Future<void> createComment({required Comment comment});
  Stream<List<Future<Post?>>> getUserPosts({required String userId, required int limit, required DocumentSnapshot<Map<String, dynamic>>? lastPostDoc});
  Stream<List<Future<Comment?>>> getPostComments({required String postId});
  Future<List<Post?>> getUserFeed({required String userId, String? lastPostId, required int limit});

  void createLike({required Post post, required String userId});
  Future<Set<String>> getLikedPostIds({required String userId, required List<Post?> posts});
  void deleteLike({required String postId, required String userId});
}
