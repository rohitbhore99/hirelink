const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onApplicationCreated = onDocumentCreated(
  "applications/{applicationId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const recruiterId = data.recruiterId || "";
    if (!recruiterId) {
      logger.warn("Missing recruiterId on application document");
      return;
    }

    const recruiterDoc = await admin.firestore().collection("users").doc(recruiterId).get();
    if (!recruiterDoc.exists) {
      logger.warn("Recruiter user not found", { recruiterId });
      return;
    }

    const token = recruiterDoc.get("fcmToken");
    if (!token) {
      logger.info("No fcmToken for recruiter", { recruiterId });
      return;
    }

    const message = {
      token,
      notification: {
        title: "New Job Application",
        body: "Someone applied to your job",
      },
      data: {
        type: "new_application",
        recruiterId,
        jobId: String(data.jobId || ""),
        applicantId: String(data.applicantId || data.userId || ""),
      },
    };

    try {
      await admin.messaging().send(message);
      logger.info("Recruiter FCM sent", { recruiterId });
    } catch (e) {
      logger.error("Failed sending recruiter FCM", e);
    }
  }
);
