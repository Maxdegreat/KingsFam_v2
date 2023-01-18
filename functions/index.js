// i always forget the command. this is how you deploy functions in firebase: firebase deploy --only functions
// or $ firebase deploy --only functions:func1,functions:func2
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const { RtcTokenBuilder, RtcToken, RtcRole } = require("agora-access-token");
require("dotenv").config();
const { user } = require("firebase-functions/v1/auth");
//var serviceAccount = require("./kingsfam-9b1f8-firebase-adminsdk-dgh0u-38f8d6850d.json");

admin.initializeApp();

const APP_ID = "706f3b99f31a4ca89b001b4671652c18"; //process.env.APP_ID;
const APP_CERTIFICATE = "5c33c35890b1441e8a1a2a9da878e74a"; //process.env.APP_CERTIFICATE;

const app = express();

const nocache = (req, resp, next) => {
  resp.header("Cache-Control", "private, no-cache, no-store, must-revalidate");
  resp.header("Pragma", "no-cache");
  resp.header("Expires", "0");
  next();
};

exports.sayHi = functions.https.onRequest((request, response) => {
  console.log("say hi");
  response.send("Hi");
});

const generateAccessToken = (req, res) => {
  // set res header
  res.header("Access-Control-Allow-Origin", "*");
  // get channel name
  const channelName = req.query.channelName;
  if (!channelName || channelName === "") {
    return res.status(505).json({ error: "A channel naem is required" });
  }

  // get uid
  let uid = req.query.uid;
  if (!uid || uid === "") {
    uid = 0;
  }
  // get role
  let role = RtcRole.SUBSCRIBER;
  if (req.query.role === "publisher") {
    role = RtcRole.PUBLISHER;
  }

  // get the expire time
  let expireTime = req.query.expireTime;
  if (!expireTime || expireTime === "") {
    expireTime = 3600; // an hr
  }
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegExpireTime = currentTime + expireTime;
  // build the token
  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    uid,
    role,
    privilegExpireTime
  );
  // return the token
  return res.json({ token: token });
};

exports.agoraTokenGenerator = functions.https.onRequest((req, res) => {
  res.send(generateAccessToken(req, res));
});

exports.onNewJoinRequest = functions.firestore
  .document("/requestToJoinCm/{cmId}/request/{requestingId}")
  .onCreate(async (_, context) => {
    // ps. user will be updated on admission status via client

    // get the tokens from user,
    const userId = context.params.requestingId;
    const userrRef = admin.firestore().collection("users").doc(userId);
    const userrDoc = await userrRef.get();
    var requestingUsername = userrDoc.get("username");
    // query the user cm for Lead and admins
    const cmId = context.params.cmId;
    const cmLeadsSnaps = await admin
      .firestore()
      .collection("communityMembers")
      .doc(cmId)
      .collection("members")
      .where("kfRole", "==", "Lead")
      .limit(10)
      .get();
    const cmAdminsSnaps = await admin
      .firestore()
      .collection("communityMembers")
      .doc(cmId)
      .collection("members")
      .where("kfRole", "==", "Admin")
      .limit(10)
      .get();

    var recievingTokens = [];

    cmLeadsSnaps.forEach(async function (snap) {
      var uid = snap.id;
      const userrRef = admin.firestore().collection("users").doc(uid);
      const userrDoc = await (await userrRef.get()).data;
      var token = userrDoc.get("token");
      functions.logger.log("val of token in snap is:", token);
      if (token.length > 0) {
        recievingTokens.push(token[0]);
      }
    });

    functions.logger.log("recieving Tokens 1:", recievingTokens);

    cmAdminsSnaps.forEach(async function (snap) {
      var uid = snap.id; // or try snap.id not snap.data.id
      const userrRef = admin.firestore().collection("users").doc(uid);
      const userrDoc = await (await userrRef.get()).data;
      var token = userrDoc.get("token");
      functions.logger.log("val of token in snap is:", token);
      if (token.length > 0) {
        recievingTokens.push(token[0]);
      }
    });

    functions.logger.log("recieving tokens 2: ", recievingTokens);

    // send encoded notification to lead and admins that new request is live
    // make the FCM
    const message = {
      notification: {
        title: "Community Join Request",
        body: requestingUsername + " is requesting to join",
      },
      data: {
        type: "CmJoinRequest",
        cmId: context.params.cmId,
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
    admin.messaging().sendToDevice(recievingTokens, message, options);
  });

(exports.onEditProfile = functions.firestore
  .document("/users/{userId}")
  .onUpdate((change, context) => {
    if (change.after.data().username === change.before.data().username) return;
    const userId = context.params.userId;

    var cmIds = [];

    // check if path to cms exist
    var cmRef = admin.firestore
      .collection("users")
      .doc(userId)
      .collection("church")
      .get()
      .then(function (querySnapshot) {
        querySnapshot.forEach(function (doc) {
          // doc is a DocumentSnapshot
          cmIds.push(doc.id);
        });
      });
    // if so nav to .each cms member paths and update the usernames
    cmIds.forEach(function (cmId) {
      var docRef = admin
        .firestore()
        .collection("communityMembers")
        .doc(cmId)
        .collection("members")
        .doc(userId);
      docRef.update({
        userNameCaseList: change.after.data().usernameSearchCase,
      });
    });
  })),
  //WORKING PROD FUNCTIONS
  (exports.onFollowUserr = functions.firestore
    .document("/followers/{userrId}/userFollowers/{followerId}")
    //when a new doc is created at this path it will fire
    .onCreate(async (_, context) => {
      //because userrId and followerId are both in brackets we are able to acess
      //via the event context
      const userrId = context.params.userrId;
      const followerId = context.params.followerId;

      //increment followed users account by 1
      const followedUserrRef = admin
        .firestore()
        .collection("users")
        .doc(userrId);
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
        .where("author", "==", followedUserrRef);
      const userFeedRef = admin
        .firestore()
        .collection("feeds")
        .doc(followerId)
        .collection("userFeed");

      const followedUserPostsSnapshot = await followedUserPostRef.get();
      followedUserPostsSnapshot.forEach((doc) => {
        if (doc.exists) {
          userFeedRef.doc(doc.id).set(doc.data());
        }
      });
    }));

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
//_========================================================================================
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
    const kingsCordId = context.params.kingsCordId;

    // make the FCM
    const message = {
      notification: {
        title: "Hey Fam! you're mentioned in " + snap.communityName,
        body: snap.messageBody,
      },
      data: {
        kcId: kingsCordId,
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
    const kingsCordId = context.params.kingsCordId;

    // make the FCM
    const message = {
      notification: {
        title: "mentioned in " + snap.communityName,
        body: snap.messageBody,
      },
      data: {
        kcId: kingsCordId,
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

    // var recentMessage;
    // if (kcMsgData.imageUrl !== null) {
    //   recentMessage = "An image was shared";
    // } else if (kcMsgData.videoUrl !== null) {
    //   recentMessage = "A video was shared";
    // } else {
    //   recentMessage = kcMsgData.text;
    // }

    cmRef.update({
      recentMsgTime: kcMsgData.date,
    });
    kcRef.update({
      // 'recentSender' : [senderId, kcMsgData.senderUsername ],
      recentTimestamp: kcMsgData.date,
      // 'recentMessage' : recentMessage,
    });
    // send notif as topic if msg contains "anouncment" in metadata
    

    
    if (snapshot.data().metadata !== undefined) {
      
      var snapData = snapshot.data();
      var cmSnap = await cmRef.get();
      var cmData = cmSnap.data();
      var messageBody;

      if (snapData.text === undefined || snapData.text === "")
        messageBody = "shared something";
      else 
        messageBody = snapData.text;
      const message = {
        notification: {
          title: "anouncment:" + cmData.name,
          body: snapData.username + ": " + messageBody,
        },
        data: {
          type: String("kc_type"),
          cmId: String(cmId),
          kcId: String(kcId),
        },
      };

      const options = {
        priority: "high",
        timeToLive: 60 * 60 * 24,
      };
   
      admin.messaging().sendToTopic("church"+cmId, message).then((value) => {
        functions.logger.log("sent the topicMessage", "/church/"+cmId)
      }).catch((err) => {console.log(String(err), console.log("sent to: /church/" + cmId))});
    }
  });

exports.onUpdateChat = functions.firestore
  .document("chats/{chatId}")
  .onUpdate((change, context) => {
    var chatDoc = context.params.chatId;
    var msgCollection = admin
      .firestore()
      .collection("chats")
      .doc(chatDoc)
      .collection("messages")
      .orderBy("date")
      .limit(500);
    const updatedChat = change.after.data();
    const previousChat = change.before.data();
    functions.logger.log("The val of uppdatedChat: ", updatedChat);
    functions.logger.log("The val of memRefs: ", updatedChat.memRefs);
    functions.logger.log("The len of memRefs == ", updatedChat.memRefs.length);
    if (updatedChat.memRefs.length === 0) {
      admin.firestore().collection("chats").doc(chatDoc).delete();
      functions.logger.log(
        "memRefs is empty should now del the chat",
        admin.firestore().collection("chats").doc(chatDoc)
      );
      return new Promise((resolve, reject) => {
        deleteQueryBatch(admin.firestore(), msgCollection, resolve).catch(
          reject
        );
      });
    }
    functions.logger.log("nothing to del here");
    //else if (updatedChat.memRefs !== previousChat.memRefs){
    //  for ()
    //}
  });

// _________________________________________HELPERS__________________________________________
async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;
  if (batchSize === 0) {
    // When there are no documents left, we are done
    resolve();
    return;
  }

  // Delete documents in a batch
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  // Recurse on the next process tick, to avoid
  // exploding the stack.
  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

// when a user has opted to recieve notifications in a kings cord room
exports.onRecieveKcRoomNotif = functions.firestore
  .document("/kcMsgNotif/{cmId}/kingsCord/{kcId}")
  .onCreate(async (snapshot, context) => {
    const cmId = context.params.cmId;
    const kcId = context.params.kcId;

    var info = snapshot.data();

    const message = {
      notification: {
        title: info.communityName,
        body: info.username + ": " + info.messageBody,
      },
      data: {
        type: String(info.type),
        cmId: String(cmId),
        kcId: String(kcId),
      },
    };

    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };

    admin.messaging().sendToDevice(info.token, message, options);
  });

exports.onRecieveKcRoomNotifUpdate = functions.firestore
  .document("/kcMsgNotif/{cmId}/kingsCord/{kcId}")
  .onUpdate((change, context) => {
    const cmId = context.params.cmId;
    const kcId = context.params.kcId;
    var info = change.after.data();
    functions.logger.log("value of tokens is: ", info.token);

    const message = {
      notification: {
        title: info.communityName,
        body: info.username + ": " + info.messageBody,
      },
      data: {
        type: String(info.type),
        cmId: String(cmId),
        kcId: String(kcId),
      },
    };

    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };
    admin.messaging().sendToDevice(info.token, message, options);
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
