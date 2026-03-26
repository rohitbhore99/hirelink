import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirelink1/features/applications/data/repositories/firebase_applications_repository.dart';
import 'package:hirelink1/features/applications/domain/repositories/applications_repository.dart';
import 'package:hirelink1/features/chat/data/repositories/firebase_chat_repository.dart';
import 'package:hirelink1/features/chat/domain/repositories/chat_repository.dart';
import 'package:hirelink1/features/jobs/data/repositories/firebase_jobs_repository.dart';
import 'package:hirelink1/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:hirelink1/features/notifications/data/repositories/firebase_notifications_repository.dart';
import 'package:hirelink1/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:hirelink1/features/user/data/repositories/firebase_user_repository.dart';
import 'package:hirelink1/features/user/domain/models/user_model.dart';
import 'package:hirelink1/features/user/domain/repositories/user_repository.dart';
import 'package:hirelink1/services/firestore_service.dart';
import 'package:hirelink1/services/storage_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return FirebaseJobsRepository(firestore: ref.watch(firestoreProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository(firestore: ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirebaseUserRepository(firestore: ref.watch(firestoreProvider));
});

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return FirebaseApplicationsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return FirebaseNotificationsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userProfileStreamProvider = StreamProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
});
