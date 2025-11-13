/**
 * Firebase Cloud Functions: Notify users on new video upload
 *
 * Triggers:
 * - Firestore document creation in "videos/{videoId}"
 *
 * Dependencies:
 * - Firebase Admin SDK
 * - Firebase Functions v2
 */

const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Set global options for all functions
setGlobalOptions({
  region: "asia-east2",
  memory: "256MB",
  maxInstances: 10,
});

/**
 * Triggered when a new video document is created in Firestore.
 * Sends FCM notifications to all users except the uploader.
 */
exports.notifyOnNewVideo = onDocumentCreated("videos/{videoId}", async (event) => {
  const video = event.data.data();
  const uploaderName = video.uploadedBy;

  try {
    // Fetch all user tokens except the uploader
    const tokensSnapshot = await admin.firestore().collection("user_tokens").get();
    const tokens = tokensSnapshot.docs
      .map((doc) => doc.data().token)
      .filter((token) => !!token);


    if (tokens.length === 0) {
      console.log("No tokens to notify.");
      return;
    }

    // Prepare FCM multicast message
    const multicastMessage = {
      tokens,
      notification: {
        title: "🎥 New Video Uploaded!",
        body: `${uploaderName} just uploaded a new video.`,
      },
      data: {
        videoUrl: video.videoUrl,
        videoId: event.params.videoId,
      },
    };

    // Send notifications
    const response = await admin.messaging().sendEachForMulticast(multicastMessage);

    // Handle failures and clean up invalid tokens
    for (let i = 0; i < response.responses.length; i++) {
      const resp = response.responses[i];
      if (!resp.success) {
        const failedDocId = tokensSnapshot.docs[i].id;
        console.error(`Failed to send to ${tokens[i]}:`, resp.error);
        await admin.firestore().collection("user_tokens").doc(failedDocId).delete();
      }
    }
  } catch (error) {
    console.error("Error sending notifications:", error);
  }
});
