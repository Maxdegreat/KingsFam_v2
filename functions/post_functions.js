// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// const { user } = require("firebase-functions/v1/auth");

// exports.onCreatePost = functions.firestore
//   .document("/posts/{postsId}")
//   .onCreate(async (snapshot, context) => {
//     const postId = context.params.postsId;

//     //get author id.
//     const authorRef = snapshot.get("author");
//     //const authorRef = snapshot.after.get('author');//curr error is can not read get... im done ill pick up tomorrow
//     const authorId = authorRef.path.split("/")[1];

//     // //add new post to the feed of all the followers of author
//     // const userFollowersRef = admin
//     //   .firestore()
//     //   .collection("followers")
//     //   .doc(authorId)
//     //   .collection("userFollowers");
//     // const userFollowerSnapshot = await userFollowersRef.get();
//     // userFollowerSnapshot.forEach(async (doc) => {
//     //   // doc.id is the user followilng's id
//     //   admin
//     //     .firestore()
//     //     .collection("feeds")
//     //     .doc(doc.id)
//     //     .collection("userFeed")
//     //     .doc(postId)
//     //     .set(snapshot.data());
//     // });
//   });

// // exports.onFeedUpdated = functions.firestore
// //   .document("feeds/{documentIdAsUserId}/userFeed")
// //   .onUpdate(async (change, context) => {
// //     const newValue = change.after.data();
// //   });
