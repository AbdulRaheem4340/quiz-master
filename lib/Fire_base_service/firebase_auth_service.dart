import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;
  String? get userName => _auth.currentUser?.displayName;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      await userCredential.user?.updateDisplayName(name);

      await _createUserProfile(
        userId: userCredential.user!.uid,
        name: name,
        email: email.trim(),
      );

      debugPrint(
        '✅ User registered successfully: ${userCredential.user?.email}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Registration error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Failed to register. Please try again.');
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final Map<String, dynamic> initialData = {
        'name': name,
        'email': email,
        'avatar': 'https://api.dicebear.com/9.x/avataaars/png?seed=$userId',
        'totalScore': 0,
        'quizzesCompleted': 0,
        'rank': 0,
        'streak': 0,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      await _database.child('users').child(userId).set(initialData);

      await _database.child('leaderboard').child(userId).set({
        'name': name,
        'avatar': initialData['avatar'],
        'totalScore': 0,
        'quizzesCompleted': 0,
        'updatedAt': ServerValue.timestamp,
      });

      debugPrint('✅ User profile & Leaderboard entry created');
    } catch (e) {
      throw Exception('Failed to create user profile');
    }
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint(
        '✅ User logged in successfully: ${userCredential.user?.email}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login error: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Failed to login. Please try again.');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ User canceled Google Sign-In');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        debugPrint('🌟 Creating profile for new Google user...');
        await _createUserProfile(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'Google User',
          email: userCredential.user!.email ?? googleUser.email,
        );
      }

      debugPrint('✅ Google Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Google Sign-In Error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint('✅ User logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      throw Exception('Failed to logout');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      if (user.email == null) throw Exception('User has no email');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      debugPrint('✅ Password changed successfully');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updateDisplayName(name);
      await _database.child('users').child(user.uid).update({
        'name': name,
        'updatedAt': ServerValue.timestamp,
      });
      debugPrint('✅ Display name updated');
    } catch (e) {
      throw Exception('Failed to update display name');
    }
  }

  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      if (user.email == null) throw Exception('User has no email');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);
      debugPrint('✅ Verification email sent');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      if (user.email == null) throw Exception('User has no email');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      await _database.child('users').child(user.uid).remove();
      await _database.child('leaderboard').child(user.uid).remove();
      await user.delete();
      debugPrint('✅ Account deleted');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      await user.sendEmailVerification();
      debugPrint('✅ Verification email sent');
    } catch (e) {
      throw Exception('Failed to send verification email');
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (!isLoggedIn) return null;

      final snapshot = await _database
          .child('users')
          .child(currentUser!.uid)
          .get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final dynamic raw = snapshot.value;
      if (raw is Map) {
        final Map<String, dynamic> clean = {};
        raw.forEach((k, v) => clean[k.toString()] = v);
        return clean;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (!isLoggedIn) throw Exception('No user logged in');
      data['updatedAt'] = ServerValue.timestamp;
      await _database.child('users').child(currentUser!.uid).update(data);
      debugPrint('✅ User data updated');
    } catch (e) {
      throw Exception('Failed to update user data');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect Password or Email. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method (Try Google).';
      case 'operation-not-allowed':
        return 'Sign-in method not enabled.';
      case 'user-disabled':
        return 'Account disabled.';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
  }

  static bool isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email.trim());

  static String? validatePassword(String password) =>
      password.trim().length < 6 ? 'Password must be at least 6 characters' : null;

  static String? validateName(String name) =>
      name.trim().length < 2 ? 'Name must be at least 2 characters' : null;
}
