// i always forget the command. this is how you deploy functions in firebase: firebase deploy --only functions
// or $ firebase deploy --only functions:func1,functions:func2
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { user } = require("firebase-functions/v1/auth");
//var serviceAccount = require("./kingsfam-9b1f8-firebase-adminsdk-dgh0u-38f8d6850d.json");

admin.initializeApp();

//WORKING PROD FUNCTIONS
exports.onFollowUserr = functions.firestore
  .document("/followers/{userrId}/userFollowers/{followerId}")
  //when a new doc is created at this path it will fire
  .onCreate(async (_, context) => {
    //because userrId and followerId are both in brackets we are able to acess
    //via the event context
    const userrId = context.params.userrId;
    const followerId = context.params.followerId;

    //increment followed users account by 1
    const followedUserrRef = admin.firestore().collection("users").doc(userrId);
    const followedUserrDoc = await followedUserrRef.get();
    if (followedUserrDoc.get("followers") !== undefined) {
      followedUserrRef.update({
        followers: followedUserrDoc.get("followers") + 1,
      });
    } else {
      followedUserrRef.update({ followers: 1 });
    }

    //increment user's fdollowwing account by 1
    const userrRef = admin.firestore().collection("users").doc(followerId);
    const userrDoc = await userrRef.get();
    if (userrDoc.get("following") !== undefined) {
      userrRef.update({ following: userrDoc.get("following") + 1 });
    } else {
      userrRef.update({ following: 1 });
    }

    //add followed users post to users post feed
    const followedUserPostRef = admin
      .firestore()
      .collection("posts")
      .where("author", "==", followedUserrRef)
      .limit(70);

    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed");

    var limiterHelper = 0;

    const followedUserPostsSnapshot = await followedUserPostRef.get();
    followedUserPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        userFeedRef.doc(doc.id).set(doc.data());
        limiterHelper += 1;
      }
    });

    if (followedUserrDoc.get("followers") !== undefined) {
      followedUserrRef.update({
        followers: followedUserrDoc.get("followers") + 1,
      });
    } else {
      followedUserrRef.update({ followers: 1 });
    }

    // check if a limiter exist. if not add limiter

    const fieldLimiterRef = admin.firestore().collection("feeds").doc(userrId);
    const fieldLimiterDoc = await fieldLimiterRef.get();

    if (fieldLimiterDoc.get("limiter") !== undefined) {
      if (fieldLimiterDoc.get("limiter") + limiterHelper < 500) {
        fieldLimiterRef.update({
          fieldLimiter: fieldLimiterDoc.get("limiter") + limiterHelper,
        });
      } else {
        const query = userFeedRef.orderBy("date").limit(100);
        const snapshot = await query.get();
        const batchSize = snapshot.size;
        if (batchSize === 0) {
          // When there are no documents flet
          return;
        }
        // Delete documents in a batch
        const batch = db.batch();
        snapshot.docs.forEach((doc) => {
          batch.delete(doc.ref);
        });
        await batch.commit();
        fieldLimiterRef.update({
          fieldLimiter: fieldLimiterDoc.get("limiter") + limiterHelper,
        });
        // TODO PLEASE OPTIMIZE. EVEN IF PAST LIM YOU STLL ADD ALL THE POST THEN GO BACK AND DEL. JUST IN TIME CURNCH. UPDATE
        //#write
        fieldLimiterRef.update({
          fieldLimiter: fieldLimiterDoc.get("limiter") - 100,
        });
      }
    } else {
      const limiter = { limiter: limiterHelper };
      fieldLimiterRef.update(limiter);
    }

    fieldLimiter.get("limiter");
  });

//================================================================================
exports.unFollowUser = functions.firestore
  .document("followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (_, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //decrement the followers user count
    const followedUserRef = admin.firestore().collection("users").doc(userId);
    const followedUserDoc = await followedUserRef.get();
    if (followedUserDoc.get("followers") !== undefined) {
      followedUserRef.update({
        followers: followedUserDoc.get("followers") - 1,
      });
    } else {
      followedUserRef.update({ followers: 0 });
    }

    //decrement user's following field
    const userRef = admin.firestore().collection("users").doc(followerId);
    const userDoc = await userRef.get();
    if (userDoc.get("following") !== undefined) {
      userRef.update({ following: userDoc.get("following") - 1 });
    } else {
      userRef.update({ following: 0 });
    }

    //remove unfollowed users post from feed
    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed")
      .where("author", "==", followedUserRef);
    const userPostsSnapshot = await userFeedRef.get();
    userPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

// =========================================================================================
exports.onCreatePost = functions.firestore
  .document("/posts/{postsId}")
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postsId;

    //get author id.
    const authorRef = snapshot.get("author");
    //const authorRef = snapshot.after.get('author');//curr error is can not read get... im done ill pick up tomorrow
    const authorId = authorRef.path.split("/")[1];

    //add new post to the feed of all the followers of author
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(authorId)
      .collection("userFollowers");

    const userFollowerSnapshot = await userFollowersRef.get();

    // this hurts. if someone has a mill followers this is a mill writes lol. Jesus help me #write
    userFollowerSnapshot.forEach(async (doc) => {
      // doc.id is the user followilng's id
      admin
        .firestore()
        .collection("feeds")
        .doc(doc.id)
        .collection("userFeed")
        .doc(postId)
        .set(snapshot.data());
    });
  });
//======================================================================================================
exports.onUpdatePost = functions.firestore
  .document("/posts/{postId}")
  .onUpdate(async (snapshot, context) => {
    const postId = context.params.postId;

    // Get author id.
    const authorRef = snapshot.after.get("author");
    const authorId = authorRef.path.split("/")[1];

    // Update post data in each follower's feed.
    const updatedPostData = snapshot.after.data();
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(authorId)
      .collection("userFollowers");
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(async (doc) => {
      const postRef = admin
        .firestore()
        .collection("feeds")
        .doc(doc.id)
        .collection("userFeed");
      const postDoc = await postRef.doc(postId).get();
      if (postDoc.exists) {
        postDoc.ref.update(updatedPostData);
      }
    });
  });

// IN A LOCAL ENV
exports.onMentionedUser = functions.firestore
  .document("/mention/{mentionedId}/{churchId}/{kingsCordId}")
  .onCreate((snapshot, context) => {
    // curr data of what was written to firestore
    const snap = snapshot.data(); // can access any val of snap as i would any js obj
    const mentionedId = context.params.mentionedId;
    const communityId = context.params.churchId;

    // make the FCM
    const message = {
      notification: {
        title: "Hey Fam! you're mentioned in " + snap.communityName,
        body: snap.messageBody,
      },
      data: {
        kcId: String(snap.type_id),
        type: String(snap.type),
        cmId: communityId,
        //'tag': String(snap.type_tag),
        //'cordName': String(snap.type_cordName),
        //'recentSender': String(snap.type_recentSender),
        //'recentMessage': String(snap.type_recentMessage),
        //'members': String(snap.type_members),
        //'communityName': String(snap.communityName),
        //'communityId': String(communityId)
      },
    };

    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };
    admin.messaging().sendToDevice(snap.token, message, options);
  });

exports.onMentionedUserUpdate = functions.firestore
  .document("/mention/{mentionedId}/{churchId}/{kingsCordId}")
  .onUpdate((snapshot, context) => {
    // curr data of what was written to firestore
    const snap = snapshot.data(); // can access any val of snap as i would any js obj
    const mentionedId = context.params.mentionedId;
    const communityId = context.params.churchId;

    // make the FCM
    const message = {
      notification: {
        title: "Hey Fam! you're mentioned in " + snap.communityName,
        body: snap.messageBody,
      },
      data: {
        kcId: String(snap.type_id),
        type: String(snap.type),
        cmId: communityId,
        //'tag': String(snap.type_tag),
        //'cordName': String(snap.type_cordName),
        //'recentSender': String(snap.type_recentSender),
        //'recentMessage': String(snap.type_recentMessage),
        //'members': String(snap.type_members),
        //'communityName': String(snap.communityName),
        //'communityId': String(communityId)
      },
    };

    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };
    admin.messaging().sendToDevice(snap.token, message, options);
  });

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//set all read status to false
exports.addChatMessage = functions.firestore
  .document("/chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const chatId = context.params.chatId;
    const messageData = snapshot.data();
    const chatRef = admin.firestore().collection("chats").doc(chatId);
    const chatDoc = await chatRef.get();
    const chatData = chatDoc.data();
    functions.logger.log("value of chatData:", chatData);
    if (chatDoc.exists) {
      const readStatus = chatData.readStatus;
      const activeMembers = chatData.activeMems;
      var senderId = messageData.sender.path.split("/")[1];
      functions.logger.log("value of senderId:", senderId);
      // for each user in readstatus.keys i want them to = false
      // however if they are in the active mem list or they are the sender then set to true.
      functions.logger.log("value of readStat.keys(): ", readStatus);
      //functions.logger.log("the value of actmem.includes(): ", activeMembers.includes(userId))
      for (let userId in readStatus) {
        if (activeMembers.includes(userId) || userId == senderId) {
          readStatus[userId] = true;
        } else if (readStatus.hasOwnProperty(userId) && userId !== senderId) {
          readStatus[userId] = false;
        } else {
          readStatus[userId] = false;
        }
      }
      // open msg and store val.
      // sends msg checks if val stored.
      // if val stored write read = 1
      // if val not exist write read = 0
      // for (let userId in readStatus) {
      //   if (readStatus.hasOwnProperty(userId) && userId !== senderId)
      //   {
      //     readStatus[userId] = false;
      //   } else {
      //     readStatus[userId] = true;
      //   }
      // }

      chatData.recentMessage = {
        timestamp: messageData.date,
        recentMessage: messageData.text,
        recentSender: messageData.sender,
      };

      chatRef.update({
        recentMessage: chatData.recentMessage,
        readStatus: readStatus,
      });

      //notifications =========

      let body = messageData.senderUsername;
      if (messageData.text !== null) {
        body += `: ${messageData.text}`;
      } else {
        body += " sent an image";
      }

      const payload = {
        notification: {
          title: chatData["chatName"],
          body: body,
        },
        data: {
          chatId: chatId,
          type: "directMsg_type",
        },
      };

      const options = {
        priority: "high",
        timeToLive: 60 * 60 * 24,
      };

      for (var userId in readStatus) {
        if (activeMembers.includes(userId) || userId == senderId) {
          continue;
        } else {
          if (chatData.memberTokens[userId] !== "") {
            admin
              .messaging()
              .sendToDevice(chatData.memberTokens[userId], payload, options);
          }
        }
      }

      //   for (const userId in memberInfo) {
      //       if (userId !== senderId) {
      //           const tokens = memberInfo[userId].token;
      //           for (var token in tokens) {
      //             if ( token !== '') {
      //               admin.messaging().sendToDevice(token, payload, options);
      //           }
      //         }
      //       }
      //   }
    }
  });

exports.onKingsCordMessageSent = functions.firestore
  .document("/church/{churchId}/kingsCord/{kingsCordId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const cmId = context.params.churchId;
    const kcId = context.params.kingsCordId;
    const kcRef = admin
      .firestore()
      .collection("church")
      .doc(cmId)
      .collection("kingsCord")
      .doc(kcId);
    const cmRef = admin.firestore().collection("church").doc(cmId);

    var kcMsgData = snapshot.data();
    var senderId = kcMsgData.sender.path.split("/")[1];
    var senderUsername = kcMsgData.senderUsername;

    var recentMessage;
    if (kcMsgData.imageUrl !== null) {
      recentMessage = "An image was shared";
    } else if (kcMsgData.videoUrl !== null) {
      recentMessage = "A video was shared";
    } else {
      recentMessage = kcMsgData.text;
    }

    cmRef.update({
      recentMsgTime: kcMsgData.date,
    });
    kcRef.update({
      recentSender: [senderId, kcMsgData.senderUsername],
      recentTimestamp: kcMsgData.date,
      recentMessage: recentMessage,
    });
  });

// exports.onUpdatePost = functions.firestore
//   .document('/posts/{postId}')
//   .onUpdate(async (snapshot, context) => {
//     const postId = context.params.postId;
//     // Get author id.
//     const authorRef = snapshot.after.get('author');
//     const authorId = authorRef.path.split('/')[1];
//     // Update post data in each follower's feed.
//     const updatedPostData = snapshot.after.data();
//     const userFollowersRef = admin
//       .firestore()
//       .collection('followers')
//       .doc(authorId)
//       .collection('userFollowers');
//     const userFollowersSnapshot = await userFollowersRef.get();
//     userFollowersSnapshot.forEach(async (doc) => {
//       const postRef = admin
//         .firestore()
//         .collection('feeds')
//         .doc(doc.id)
//         .collection('userFeed');
//       const postDoc = await postRef.doc(postId).get();
//       if (postDoc.exists) {
//         postDoc.ref.update(updatedPostData);
//       }
//     });
//   });

/*how the feed will work
    post collection has all post from user
    make a new collection called feeds
    each user will have a collection called user feed
    when user followes another user we take users the followe and paste post in users feed
    add this method to onfollow method
*/

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// })
