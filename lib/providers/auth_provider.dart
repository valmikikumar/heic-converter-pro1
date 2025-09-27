import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_constants.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: null,
        );
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final userModel = await _firestoreService.getUser(uid);
      
      state = state.copyWith(
        user: userModel,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        
        // Create user document in Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          isPro: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await _firestoreService.createUser(userModel);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final existingUser = await _firestoreService.getUser(userCredential.user!.uid);
        
        if (existingUser == null) {
          // Create new user
          final userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName,
            photoURL: userCredential.user!.photoURL,
            isPro: false,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          
          await _firestoreService.createUser(userModel);
        } else {
          // Update last login
          await _updateLastLogin(userCredential.user!.uid);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<String?> sendOTP(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
          _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            isLoading: false,
            error: _getAuthErrorMessage(e.code),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
      
      return state.verificationId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final existingUser = await _firestoreService.getUser(userCredential.user!.uid);
        
        if (existingUser == null) {
          // Create new user with phone number
          final userModel = UserModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.phoneNumber ?? '',
            displayName: 'User',
            isPro: false,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          
          await _firestoreService.createUser(userModel);
        } else {
          // Update last login
          await _updateLastLogin(userCredential.user!.uid);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestoreService.updateUser(uid, {'lastLoginAt': Timestamp.now()});
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      state = state.copyWith(
        user: null,
        verificationId: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateProStatus(bool isPro) async {
    if (state.user != null) {
      try {
        await _firestoreService.updateUser(state.user!.uid, {'isPro': isPro});
        
        state = state.copyWith(
          user: state.user!.copyWith(isPro: isPro),
        );
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? verificationId;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.verificationId,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? verificationId,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isPro => user?.isPro ?? false;
}
