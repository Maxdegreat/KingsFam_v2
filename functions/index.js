const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

//name of our cloud function
exports.onFollowUserr = functions.firestore.document("/followers/{userrId}/userFollowers/{followerId}")
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
      
      followedUserrRef.update({followers: followedUserrDoc.get("followers") + 1});

    } else {
      followedUserrRef.update({ followers: 1 });
    }

    //increment user's fdollowwing account by 1
    const userrRef = admin.firestore().collection("users").doc(followerId);
    const userrDoc = await userrRef.get();
    if (userrDoc.get("following") !== undefined) {
     
      userrRef.update({following: userrDoc.get("following") + 1});
    } else {
      userrRef.update({ following: 1 });
    }

    //add followed users post to users post feed
    // const followedUserPostRef = admin
    //   .firestore()
    //   .collection("posts")
    //   .where("author", "==", followedUserrRef);
    // const userFeedRef = admin
    //   .firestore()
    //   .collection("feeds")
    //   .doc(followerId)
    //   .collection("userFeed");

    // const followedUserPostsSnapshot = await followedUserPostRef.get();
    // followedUserPostsSnapshot.forEach((doc) => {
    //   if (doc.exists) {
    //     userFeedRef.doc(doc.id).set(doc.data());
    //   }
    // });
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
    userFollowerSnapshot.forEach(async (doc) => { // doc.id is the user followilng's id
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
  .document('/posts/{postId}')
  .onUpdate(async (snapshot, context) => {
    const postId = context.params.postId;

    // Get author id.
    const authorRef = snapshot.after.get('author');
    const authorId = authorRef.path.split('/')[1];

    // Update post data in each follower's feed.
    const updatedPostData = snapshot.after.data();
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(authorId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(async (doc) => {
      const postRef = admin
        .firestore()
        .collection('feeds')
        .doc(doc.id)
        .collection('userFeed');
      const postDoc = await postRef.doc(postId).get();
      if (postDoc.exists) {
        postDoc.ref.update(updatedPostData);
      }
    });
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
    if (chatDoc.exists) {
      const readStatus = chatData.readStatus;
      for (let userId in readStatus) {
        if (readStatus.hasOwnProperty(userId) && userId !== messageData.senderId) 
        {
          readStatus[userId] = false;
        } else {
            readStatus[userId] = true;
        }
      }
      chatRef.update({
          recentMessage: messageData.text,
          recentSender: messageData.senderId,
          date: messageData.date,
          readStatus: readStatus,
      });
      
      const dataMap = {
        'id' : String(chatId),
        'name': String(chatData.name),
        'imageUrl': String(chatData.imageUrl),
        'recentSender': String(chatData.recentSender),
        'recentMessage': String(chatData.recentMessage),
        //'searchPram': chatData.searchPram,
        'date': JSON.stringify(chatData.date),
        'memberIds': String(chatData.memberIds),
        'memberInfo': String(chatData.memberInfo),
        'readStatus': String(chatData.readStatus)
      }

      //notifications
      const memberInfo = chatData.memberInfo;
      const senderId = messageData.senderId;
      let body = memberInfo[senderId].username;
      if(messageData.text !== null ) {
          body += `: ${messageData.text}`;
      } else  {
          body += ' sent an image';
      }

      const payload = {
          notification: {
            title: chatData['name'],
            body: body,
          },
          data: dataMap
      };



      const options = {
          priority: 'high',
          timeToLive: 60 * 60 * 24,
      };

      for (const userId in memberInfo) {
          if (userId !== senderId) {
              const token = memberInfo[userId].token;
              if ( token !== '') {
                  admin.messaging().sendToDevice(token, payload, options);
              }
          }
      }
    }
  });

//             exports.onUpdatePost = functions.firestore
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
