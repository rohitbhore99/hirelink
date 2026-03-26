import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_failure.dart';

class FirebaseErrorMapper {
  static AppFailure map(Object error) {
    if (error is FirebaseException) {
      return AppFailure(error.message ?? 'Firebase error', cause: error);
    }
    if (error is FirebaseAuthException) {
      return AppFailure(error.message ?? 'Auth error', cause: error);
    }
    return AppFailure('Unexpected error', cause: error);
  }
}
