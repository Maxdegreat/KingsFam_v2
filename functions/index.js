// i always forget the command. this is how you deploy functions in firebase: firebase deploy --only functions
// or $ firebase deploy --only functions:func1,functions:func2
const functions = require('firebase-functions');
const admin = require("firebase-admin");
const express = require("express");
// import fetch from 'node-fetch';
const { RtcTokenBuilder, RtcToken, RtcRole } = require("agora-access-token");
const { user } = require("firebase-functions/v1/auth");
const { log } = require("firebase-functions/logger");
require("dotenv").config();
//var serviceAccount = require("./kingsfam-9b1f8-firebase-adminsdk-dgh0u-38f8d6850d.json");
// const onCreateKc = require('./kc.js');

admin.initializeApp();

const APP_ID = "706f3b99f31a4ca89b001b4671652c18"; 
const APP_CERTIFICATE = "5c33c35890b1441e8a1a2a9da878e74a";

const app = express();

// exports.onCreateKc = onCreateKc.onCreateKc;

const nocache = (req, resp, next) => {
  resp.header("Cache-Control", "private, no-cache, no-store, must-revalidate");
  resp.header("Pragma", "no-cache");
  resp.header("Expires", "0");
  next();
};

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

const https = require('https');

exports.openAiEndpoint = functions.https.onRequest(async (req, res) => {
  try {
    // Check if the request body includes the required 'topic' parameter
    if (!req.body || !req.body.topic) {
      throw new Error('Missing required parameter: topic');
    }
    
    // Construct the prompt
    const prompt = 'Return to me a Bible verse that includes the topic hard work: Colossians 3:23-24 Whatever you do, do it from the heart for the Lord and not for people. You know that you will receive an inheritance as a reward. You serve the Lord Christ Return to me a Bible verse that includes the topic ${req.body.topic}.';

    // Make the OpenAI API call with the API key
    const apiKey = '###'; 
    const apiUrl = 'https://api.openai.com/v1/completions';
    const requestData = JSON.stringify({
      model: 'text-davinci-003',
      prompt: prompt,
      max_tokens: 256,
      temperature: 0.7
    }); // firebase deploy --only functions

    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      }
    };

    const request = https.request(apiUrl, options, (response) => {
      let responseData = '';

      response.on('data', (chunk) => {
        responseData += chunk;
      });

      response.on('end', () => {
        // Check if the OpenAI API call was successful
        if (response.statusCode !== 200) {
          throw new Error(`OpenAI API returned ${response.statusCode} ${response.statusMessage}`);
        }

        // Parse the response JSON and extract the text
        const jsonResponse = JSON.parse(responseData);
        const text = jsonResponse.choices[0].text;

        // Return the results to the HTTP response
        res.status(200).send({ status: 200, text: text });
      });
    });

    request.on('error', (error) => {
      console.error(error);
      res.status(500).send({ status: 500, text: error.message });
    });

    request.write(requestData);
    request.end();
  } catch (error) {
    console.error(error);
    res.status(500).send({ status: 500, text: error.message });
  }
});


exports.onNewJoinRequest = functions.firestore.document("/requestToJoinCm/{cmId}/request/{requestingId}").onCreate(async (_, context) => {
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
// firebase deploy --only functions:openAiEndpoint
    var recievingTokens = [];

    for (const snap of cmLeadsSnaps.docs) {
      var uid = snap.id;
      const userrRef = admin.firestore().collection("users").doc(uid);
      const userrDoc = (await userrRef.get()).data();
      var token = userrDoc.token;
      functions.logger.log("val of token in snap is:", token);
      if (token.length > 0) {
        recievingTokens.push(token[0]);
      }
    }

    functions.logger.log("recieving Tokens 1:", recievingTokens);

      for (const snap of cmAdminsSnaps.docs) {
        var uid = snap.id;
        const userrRef = admin.firestore().collection("users").doc(uid);
        const userrDoc = (await userrRef.get()).data();
        var token = userrDoc.token;
        functions.logger.log("val of token in snap is:", token);
        if (token.length > 0) {
          recievingTokens.push(token[0]);
        }
      }

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

(exports.onEditProfile = functions.firestore .document("/users/{userId}").onUpdate(async (change, context) => {
    // IMPORTANT NOTE
    // This function will be called when IOS and maybe android login / uninstall and reinstall. this is because of token changes
    // in the user profile. tokens are important to app functionality due to subscriptions for fcm. because of this we will check
    // for changes to tokens and act accordingly.

    // TODO: make a token deactivation.

    const uid = context.params.userId;

    if (change.after.data().token[0] !== change.before.data().token[0]) {
      console.log("tokens are not the same");
      // get all user cmIds
      var userCm = admin
        .firestore()
        .collection("users")
        .doc(uid)
        .collection("church");
      var userCmSnap = await userCm.get();

      // nav through all cms and sub to each kc and cm and role topics.
      var topic;
      for (var i = 0; i < userCmSnap.docs.length; i++) {
        // sub to cm
        topic = "church" + userCmSnap.docs[i].id;
        // log("topic for cm is: ",  topic);
        admin.messaging().subscribeToTopic(change.after.data().token[0], topic);
        // go through cm and sub to topics accordingly
        var kcSnap = await admin
          .firestore()
          .collection("church")
          .doc(userCmSnap.docs[i].id)
          .collection("kingsCord")
          .get();
        for (var j = 0; j < kcSnap.docs.length; j++) {
          topic = userCmSnap.docs[i].id + kcSnap.docs[j].id + "topic";
          // log("topic for kc is: ", topic);
          admin
            .messaging()
            .subscribeToTopic(change.after.data().token[0], topic);
        }

        // go to cmMem and get role. then sub to topic as needed
        var userAsMember = await admin
          .firestore()
          .collection("communityMembers")
          .doc(userCmSnap.docs[i].id)
          .collection("members")
          .doc(uid)
          .get();
        var role = await userAsMember.data().kfRole;
        var cmId = userCmSnap.docs[i].id;
        if (role === "Lead" || role === "lead") {
          topic = cmId + role;
        } else if (role === "Admin" || role === "admin") {
          topic = cmId + role;
        } else if (role === "Mod" || role === "mod") {
          topic = cmId + role;
        }

        // console.log("topic is: ", topic);
        admin.messaging().subscribeToTopic(change.after.data().token[0], topic);
      }
      // done
    }

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

  (exports.onFollowUserr = functions.firestore .document("/followers/{userrId}/userFollowers/{followerId}").onCreate(async (_, context) => {
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
    }));

//================================================================================
exports.unFollowUser = functions.firestore  .document("followers/{userId}/userFollowers/{followerId}").onDelete(async (_, context) => {
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
  });
//_========================================================================================
exports.onCreatePost = functions.firestore.document("/posts/{postsId}").onCreate(async (snapshot, context) => {
    const postId = context.params.postsId;

    functions.logger.log("the post: ", snapshot.data());
    // get cmId of the post
    const cmId = snapshot.data().commuinity.path.split("/")[1];
    functions.logger.log("the community id is: ", cmId);
    functions.logger.log("the community is: ", snapshot.data().commuinity);

    // check timestamp of last post in cm
    const cmRef = admin.firestore().collection("church").doc(cmId);
    const postRef = admin.firestore().collection("posts");
    postRef
      .where("commuinity", "==", snapshot.data().commuinity)
      .orderBy("date", "desc")
      .limit(2)
      .get()
      .then(async (snap) => {
        functions.logger.log("this is num of posts found: ", snap.docs.length);
        // if timestamp is 10 minuets apart send notif to the cm topic
        if (snap.docs.length >= 2) {
          log("more than 2");
          var post1 = snap.docs[0].data();
          var post2 = snap.docs[1].data();

          const tenMinutes = 10 * 60 * 1000; // 10 minutes in milliseconds
          const difference = Math.abs(
            post1.date.toMillis() - post2.date.toMillis()
          );

          if (difference >= tenMinutes) {
   
            var title = "new post in " + snapshot.data().name;
            const message = {
              notification: {
                title: title,
                body: "See what the fam is sharing!",
              },
              data: {
                postId: snap.docs[0].id,
                type: "cmPost",
                cmId: cmId,
              },
            };

            var topic = "church" + cmId;
            admin.messaging().sendToTopic(topic, message);
          }
          log("do nothing, not longer than 10 minuets");
        } else {
          console.log("found none");
          var post1 = snapshot.data();


          var title = "new post in " + snapshot.data().name;
          const message = {
            notification: {
              title: title,
              body: "See what the fam is sharing!",
            },
            data: {
              postId: snapshot.id,
              type: "cmPost",
              cmId: cmId,
            },
          };

          var topic = "church" + cmId;
          admin.messaging().sendToTopic(topic, message);
        }
        console.log("what how did we get here?");
      });

    console.log("found no matching cm to notify users subed to topic w/");
  });

// IN A LOCAL ENV
exports.onMentionedUser = functions.firestore.document("/mention/{mentionedId}/{churchId}/{kingsCordId}").onCreate((snapshot, context) => {
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

exports.onMentionedUserUpdate = functions.firestore.document("/mention/{mentionedId}/{churchId}/{kingsCordId}").onUpdate((snapshot, context) => {
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

exports.onJoinCm = functions.firestore.document("/communityMembers/{cmId}/members/{memberId}").onCreate(async (snapshot, context) => {
    const uid = context.params.memberId;
    const cmId = context.params.cmId;

    // check if exist at user church path. if not add
    var userCm = admin
      .firestore()
      .collection("users")
      .doc(uid)
      .collection("church")
      .doc(cmId);
    var userCmSnap = await userCm.get();
    if (!userCmSnap.exists) {
      admin
        .firestore()
        .collection("users")
        .doc(uid)
        .collection("church")
        .doc(cmId)
        .set({});
    }
    // get all kcIds
    var kcRef = admin
      .firestore()
      .collection("church")
      .doc(cmId)
      .collection("kingsCord");
    var kcSnaps = await kcRef.get();
    var kcDocs = kcSnaps.docs;
    // get user token
    var userRef = admin.firestore().collection("users").doc(uid);
    var userSnapshot = await userRef.get();
    var token = userSnapshot.get("token");

    // sub user from topic (cmId + kcId + "topic")
    for (var i = 0; i < kcDocs.length; i++) {
      var topic = cmId + kcDocs[i].id + "topic";
      admin.messaging().subscribeToTopic(token[0], topic);
    }

    var topic = "church" + cmId;
    admin.messaging().subscribeToTopic(token[0], topic);

    // done
  });

exports.onLeaveCm = functions.firestore.document("/communityMembers/{cmId}/members/{memberId}").onDelete(async (snapshot, context) => {
    const uid = context.params.memberId;
    const cmId = context.params.cmId;
    // nav to user home and remove cmId from user / church
    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .collection("church")
      .doc(cmId)
      .delete();

    // var userRef = admin.firestore().collection("users").doc(uid);
    // var userSnapshot = await userRef.get();

    // itr through all kcId's in path of cmId and save kcIds
    var kcRef = admin
      .firestore()
      .collection("church")
      .doc(cmId)
      .collection("kingsCord");
    var kcSnaps = await kcRef.get();
    var kcDocs = kcSnaps.docs;

    // get user token
    var userRef = admin.firestore().collection("users").doc(uid);
    var userSnapshot = await userRef.get();
    var token = userSnapshot.get("token");

    // unsub user from topic (cmId + kcId + "topic")
    for (var i = 0; i < kcDocs.length; i++) {
      var topic = cmId + kcDocs[i].id + "topic";
      admin.messaging().unsubscribeFromTopic(token[0], topic);
    }

    var topic = "church" + cmId;
    admin.messaging().unsubscribeFromTopic(token[0], topic);
    // done
  });

exports.onRoleChanged = functions.firestore.document("/communityMembers/{cmId}/members/{memberId}") .onUpdate(async (change, context) => {
    const cmId = context.params.cmId;
    const uid = context.params.memberId;

    // base case
    var roleSnap = change.after.data();
    var oldRole = change.before.data().kfRole;

    if (roleSnap === oldRole) {
      return;
    }

    // get value for new role
    // var role = admin.firestore().collection("communityMembers").doc(cmId).collection("members").doc(uid);
    // conditionally create appropriate topic or none if member
    var topic;
    if (roleSnap.kfRole === "Lead" || roleSnap.kfRole === "lead") {
      topic = cmId + roleSnap.kfRole;
    } else if (roleSnap.kfRole === "Admin" || roleSnap.kfRole === "admin") {
      topic = cmId + roleSnap.kfRole;
    } else if (roleSnap.kfRole === "Mod" || roleSnap.kfRole === "mod") {
      topic = cmId + roleSnap.kfRole;
    }

    var user = admin.firestore().collection("users").doc(uid);
    var userSnap = await user.get();

    if (typeof topic !== "undefined" || topic !== null) {
      log("topic: " + topic);
      var token = userSnap.get("token");
      // conditionally subscribe or un sub to topic
      admin.messaging().subscribeToTopic(token[0], topic);
    }

    // must unsub from old
    topic = cmId + oldRole;
    admin.messaging().unsubscribeFromTopic(token[0], topic);

    // done
  });

exports.onDeleteKc = functions.firestore.document("/church/{cmId}/kingsCord/{kcId}").onDelete(async (_, context) => {
    const cmId = context.params.cmId;
    const kcId = context.params.kcId;
    // itr through all members in kc and collect tokens
    var cmMem = admin
      .firestore()
      .collection("communityMembers")
      .doc(cmId)
      .collection("members");
    var cmMemSnap = await cmMem.get();
    var cmMemDocs = cmMemSnap.docs;

    // check if have correct documents
    var docIds = cmMemDocs.map((doc) => doc.id);

    // now let us grab user tokens
    var tokens = [];
    for (var i = 0; i < docIds.length; i++) {
      var user = admin.firestore().collection("users").doc(docIds[i]);
      var userSnap = await user.get();
      var userTokens = await userSnap.get("token");
      tokens.push(userTokens[0]);
    }

    // unsub all member app instance tokens
    var topic = cmId + kcId + "topic";
    admin.messaging().unsubscribeFromTopic(tokens, topic);
    // done.
  });

exports.onCreateKc = functions.firestore.document("/church/{cmId}/kingsCord/{kcId}").onCreate(async (_, context) => {
    const cmId = context.params.cmId;
    const kcId = context.params.kcId;
    // itr through all members
    var cmMem = admin
      .firestore()
      .collection("communityMembers")
      .doc(cmId)
      .collection("members");
    var cmMemSnap = await cmMem.get();
    var cmMemDocs = cmMemSnap.docs;

    // check if have correct documents
    functions.logger.log("document 1 id: ", cmMemDocs[0].id);
    var docIds = cmMemDocs.map((doc) => doc.id);
    functions.logger.log("document ids: ", docIds);

    // now let us grab user tokens
    var tokens = [];
    for (var i = 0; i < docIds.length; i++) {
      var user = admin.firestore().collection("users").doc(docIds[i]);
      var userSnap = await user.get();
      var userTokens = await userSnap.get("token");
      tokens.push(userTokens[0]);
    }

    // subscribe all members
    var topic = cmId + kcId + "topic";
    admin.messaging().subscribeToTopic(tokens, topic);
    // done
  });

exports.onKingsCordMessageSent = functions.firestore.document("/church/{churchId}/kingsCord/{kingsCordId}/messages/{messageId}").onCreate(async (snapshot, context) => {

    const cmId = context.params.churchId;
    const kcId = context.params.kingsCordId;
    const cmRef = admin.firestore().collection("church").doc(cmId);
    const kcRef = admin
      .firestore()
      .collection("church")
      .doc(cmId)
      .collection("kingsCord")
      .doc(kcId);

    var kcMsgData = snapshot.data();
    var senderId = kcMsgData.sender.path.split("/")[1];
    var senderUsername = kcMsgData.senderUsername;


    cmRef.update({recentMsgTime: kcMsgData.date,});

    kcRef.update({ recentTimestamp: kcMsgData.date });

    functions.logger.log("complete snapshot: ", snapshot.data());
    
    var chatPriority = snapshot.data().metadata.chatPriority;

      var cmSnap = await cmRef.get();
      var cmData = cmSnap.data();
      var messageBody;

      if (kcMsgData.text === undefined || kcMsgData.text === "") {
        messageBody = "shared something";
      }
      else {
        messageBody = kcMsgData.text;
      }

      const message = {
        notification: {
          title: kcMsgData.metadata.kcName + " " + cmData.name,
          body: kcMsgData.senderUsername + ": " + messageBody,
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
         
      console.log("now checking if statments");

      if (kcMsgData.replyMsg !== undefined && kcMsgData.replyMsg !== null) {
        // handle if a message was replied to
        functions.logger.log("replyMsg is not null", kcMsgData.replyMsg)
      }
      console.log("checking second if statment");

      if (kcMsgData.mentionedIds !== undefined && kcMsgData.mentionedIds.length > 0) {
        functions.logger.log("mentionedIds is not null: " + kcMsgData.mentionedIds)
        // handle if a message contains replies
        var tokenBucket = [];
        for (var i = 0; i < kcMsgData.mentionedIds.length; i++) {
          var user = await getUserWithId(kcMsgData.mentionedIds[i]);
          console.log(user);
          console.log(user.token);
          console.log(user.token[0])
          tokenBucket.push(user.token[0]);
        }
        console.log("sending msg to device")
        var mentionMsg = message;
        mentionMsg['notification']['body'] = `You were mentioned: ${message['notification']['body']}`
        admin.messaging().sendToDevice(tokenBucket, mentionMsg, options);

        // unsub those that alredy got mentioned for a moment
        
          var topic = cmId + kcId + "topic";
          admin.messaging().unsubscribeFromTopic(tokenBucket, topic).then(() => {
            
            admin.messaging().sendToTopic(topic, message);
            admin.messaging().subscribeToTopic(tokenBucket, topic)
          })
        
        return ;
      }
 
      
      console.log("1");
      functions.logger.log("The value of chatP = ", chatPriority);
      if (chatPriority !== undefined && chatPriority == "Notify For All Messages" || messageBody.includes("@everyone")) {
        var topic = cmId + kcId + "topic";
        admin
        .messaging()
        .sendToTopic(topic, message)
        .then((value) => {
          functions.logger.log("sent the topicMessage", topic);
        })
        .catch((err) => {
          console.log(String(err), console.log("sent to: " + topic));
        });
      } else if (chatPriority === undefined || chatPriority === "Passive Chat" || chatPriority === null) {
      console.log("2");
        // get the user of most recent chat member.
        console.log("about to call getRecentKcUser");
        getRecentKcUser(cmId, kcId).then((user) => {
          if (user !== undefined) {
            admin.messaging().sendToDevice(user.token[0], message, options);
          } else {
            console.log("The user is still undefined")
          }
        });
        
        // if same as sender | check if recent chat is 5 hr apart | if true just send to all users

        // if not same as user notfi that recent user 
      }
      console.log("um???");

      
      
    
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

async function getRecentKcUser(cmId, kcId) {
  try {
    functions.logger.log("in getRecentKcUser, cmId and kcId", cmId, kcId)
  var messageSnap = await admin
  .firestore()
  .collection("church")
  .doc(cmId)
  .collection("kingsCord")
  .doc(kcId)
  .collection('messages')
  .orderBy('date', 'desc')
  .limit(2)
  // .startAfter(admin.firestore.Timestamp.now())
  .get();

  var user;
  // ========= READ =========
  // Limit is 2 above but will return on fist itr of for loop 
  // in order to just notify the most recent user (note using decending order)
  for (var i = messageSnap.docs.length - 1; i >= 0; i--) {
    console.log("in 1")
    var msgData = messageSnap.docs[i].data();
    if (msgData.sender !== null) {
      console.log("2 in if, next should be if we got the user")
      var userId = msgData.sender.path.split('/')[1];
      var userRef = await admin.firestore().collection("users").doc(userId).get();
      user = userRef.data()
      functions.logger.log("3 returning user is: ", user)
      return user
    }
  }

  functions.logger.log("The user after the loop: ", user);
  console.log("we are returning undefined");
  return undefined;

  
  } catch (error) {
    functions.logger.log("The error is: " + error)
  }
}

async function getUserWithId(uid) {
  var userRef = await admin.firestore().collection("users").doc(uid).get();
  return userRef.data();
}

// when a user has opted to recieve notifications in a kings cord room
exports.onRecieveKcRoomNotif = functions.firestore .document("/kcMsgNotif/{cmId}/kingsCord/{kcId}") .onCreate(async (snapshot, context) => {
    const cmId = context.params.cmId;
    const kcId = context.params.kcId;

    var info = snapshot.data();
    functions.logger.log("info: ", info);

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

    var topic = cmId + kcId + "topic";
    admin.messaging().sendToTopic(topic, message, options);
  });


  // this is a function to subscribe all users in themBoys to notifs
  exports.onUpdateThemBoysToTopic = functions.firestore.document("/church/ugLflPjapami8sml9ZpQ").onUpdate(async (change, context) => {
      var users = [];
      var topics = [];

      // lets go to members and get all members
      var membersReference = await admin.firestore().collection("communityMembers").doc("ugLflPjapami8sml9ZpQ").collection("members").get();
      membersReference.docs.forEach(async (member) => {
        var userRef = await admin.firestore().collection("users").doc(member.id).get();
        var user = userRef.data()
        users.push(user);
      });
      // lets go to kingscords and get all kcs in cm
      var kingscordsReference = await admin.firestore().collection("church").doc("ugLflPjapami8sml9ZpQ").collection("kingsCord").get();
      var topic;
      topic = "church" + "ugLflPjapami8sml9ZpQ";
      topics.push(topic);
      kingscordsReference.docs.forEach((kc) => {
        topic = "ugLflPjapami8sml9ZpQ" + kc.id + "topic";
        topics.push(topic);
      });
      // lets sub each member to each kc
      for (var i = 0; i < users.length; i++) {
        for (var j = 0; j < topics.length; j++) {
          functions.logger.log("subscribing user to topic: ", users[i].token, topics[j] )
          admin.messaging().subscribeToTopic(users[i].token, topics[j])
        }
      }
      // done.
    })