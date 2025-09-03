import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create a fresh GoogleSignIn instance to avoid any cached state
      final GoogleSignIn freshGoogleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // First, ensure we're signed out from any previous session
      await freshGoogleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await freshGoogleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in flow
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Clean up the fresh instance
      await freshGoogleSignIn.disconnect();
      
      return userCredential;
    } catch (_) {
      return null;
    }
  }

  // Get Google user info for consent screen (first step of sign-up)
  Future<GoogleSignInAccount?> getGoogleUserForSignUp() async {
    try {
      // Create a fresh GoogleSignIn instance to avoid any cached state
      final GoogleSignIn freshGoogleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // First, ensure we're signed out from any previous session
      await freshGoogleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await freshGoogleSignIn.signIn();
      
      return googleUser; // Return null if user cancelled
    } catch (e) {
      return null;
    }
  }

  // Complete Google sign-up after user consent (second step)
  Future<Map<String, dynamic>?> completeGoogleSignUp(GoogleSignInAccount googleUser) async {
    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if user already exists by trying to sign in with credential
      // This will either sign in existing user or create new account
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if this is a new user (account was just created)
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        // This is a new account that was just created
        // Update the user profile with Google information
        await userCredential.user?.updateDisplayName(googleUser.displayName);
        await userCredential.user?.updatePhotoURL(googleUser.photoUrl);
        
        // Sign out the user immediately after account creation
        await _auth.signOut();
        
        // Return user information for success message
        return {
          'success': true,
          'name': googleUser.displayName,
          'email': googleUser.email,
          'photoUrl': googleUser.photoUrl,
        };
      } else {
        // User already exists, sign them out and show error
        await _auth.signOut();
        return {
          'success': false,
          'error': 'Account already exists. Please log in instead.',
        };
      }
    } catch (e) {
      // Handle any errors during the process
      return {
        'success': false,
        'error': 'Failed to create account. Please try again.',
      };
    }
  }

  // Sign out - Comprehensive session clearing
  Future<void> signOut() async {
    try {
      // Step 1: Sign out from Firebase first
      await _auth.signOut();
      
      // Step 2: Sign out from Google Sign-In
      await _googleSignIn.signOut();
      
      // Step 3: Disconnect from Google Sign-In to fully clear the session
      await _googleSignIn.disconnect();
      
    } catch (e) {
      // If any step fails, try to at least sign out from Firebase
      try {
        await _auth.signOut();
      } catch (_) {
        // If even Firebase signOut fails, we can't do much more
      }
    }
  }

  // Get error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
