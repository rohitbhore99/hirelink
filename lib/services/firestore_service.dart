import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAVE USER
  Future<void> saveUser(
    String uid,
    String name,
    String email,
    String? phone,
    String role,
  ) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await _db.collection("users").doc(uid).set({
      "email": email,
      "name": name,
      "phone": phone ?? "",
      "role": role,
      "skills": "",
      "bio": "",
      "fcmToken": token,
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection("users").doc(uid).update(data);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) {
    return _db.collection("users").doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection("users").doc(uid).get();
  }

  Stream<QuerySnapshot> getUserApplications(String userId) {
    return _db
        .collection("applications")
        .where("userId", isEqualTo: userId)
        .snapshots();
  }

  // CREATE OR GET CHAT
  Future<String> createChat(String user1, String user2) async {
    var result = await _db
        .collection("chats")
        .where("users", arrayContains: user1)
        .get();

    for (var doc in result.docs) {
      List users = doc['users'];
      if (users.contains(user2)) {
        return doc.id;
      }
    }

    final user1Doc = await _db.collection("users").doc(user1).get();
    final user2Doc = await _db.collection("users").doc(user2).get();

    final user1Name =
        (user1Doc.data() ?? const {})["name"] as String? ?? "User";
    final user2Name =
        (user2Doc.data() ?? const {})["name"] as String? ?? "User";

    var chat = await _db.collection("chats").add({
      "users": [user1, user2],
      "userNames": {user1: user1Name, user2: user2Name},
      "lastMessage": "",
      "lastMessageAt": Timestamp.now(),
      "createdAt": Timestamp.now(),
    });

    return chat.id;
  }

  // SEND MESSAGE
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    await _db.collection("chats").doc(chatId).collection("messages").add({
      "senderId": senderId,
      "text": text,
      "timestamp": Timestamp.now(),
    });

    await _db.collection("chats").doc(chatId).update({
      "lastMessage": text,
      "lastMessageAt": Timestamp.now(),
      "lastSenderId": senderId,
    });
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots();
  }

  Stream<QuerySnapshot> getChatsForUser(String userId) {
    return _db
        .collection("chats")
        .where("users", arrayContains: userId)
        .orderBy("lastMessageAt", descending: true)
        .limit(30)
        .snapshots();
  }

  // ADD JOB
  Future<void> addJob(
    String title,
    String company, {
    String description = "",
    String location = "Remote",
    String type = "Full-time",
    String salary = "Negotiable",
  }) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection("jobs").add({
      "title": title,
      "company": company,
      "description": description,
      "location": location,
      "type": type,
      "salary": salary,
      "postedBy": userId, // 🔥 IMPORTANT
      "createdAt": Timestamp.now(),
    });
  }

  // GET JOBS
  Stream<QuerySnapshot> getJobs() {
    return _db
        .collection("jobs")
        .orderBy("createdAt", descending: true)
        .limit(100)
        .snapshots();
  }

  // 🔥 ADD THIS METHOD (MISSING)
  Future<void> applyJob(String userId, String jobId) async {
    await _db.collection("applications").add({
      "userId": userId,
      "jobId": jobId,
      "status": "applied",
      "appliedAt": Timestamp.now(),
    });

    var jobDoc = await _db.collection("jobs").doc(jobId).get();
    if (jobDoc.exists) {
      String recruiterId = jobDoc.data()!['postedBy'] as String;

      await sendNotification(
        recruiterId,
        "New Application",
        "Someone applied to your job",
        jobId,
      );
    }
  }

  // CHECK IF ALREADY APPLIED
  Future<bool> hasApplied(String userId, String jobId) async {
    var result = await _db
        .collection("applications")
        .where("userId", isEqualTo: userId)
        .where("jobId", isEqualTo: jobId)
        .get();

    return result.docs.isNotEmpty;
  }

  Stream<QuerySnapshot> getMyJobs(String userId) {
    return _db
        .collection("jobs")
        .where("postedBy", isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    await _db.collection("jobs").doc(jobId).update(data);
  }

  Future<void> deleteJob(String jobId) async {
    await _db.collection("jobs").doc(jobId).delete();
  }

  Stream<QuerySnapshot> getApplicationsForJob(String jobId) {
    return _db
        .collection("applications")
        .where("jobId", isEqualTo: jobId)
        .snapshots();
  }

  Future<void> sendNotification(
    String userId,
    String title,
    String body, [
    String? jobId,
  ]) async {
    await _db.collection("notifications").add({
      "userId": userId,
      "title": title,
      "body": body,
      "jobId": ?jobId,
      "timestamp": Timestamp.now(),
    });
  }
}
