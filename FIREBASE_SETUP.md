# Firebase Authentication Setup Guide

This guide will help you set up Firebase Authentication for your TANAW app with Google and Facebook sign-in providers.

## Prerequisites

- Flutter SDK installed
- Android Studio or VS Code
- Google account
- Facebook Developer account (for Facebook sign-in)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select an existing project
3. Enter your project name (e.g., "TANAW App")
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In your Firebase project, click the Android icon (</>) to add an Android app
2. Enter your package name: `com.example.tanaw_app`
3. Enter app nickname: "TANAW App"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/google-services.json` (replace the placeholder file)

## Step 3: Enable Authentication Methods

1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following providers:

### Email/Password
- Click "Email/Password"
- Enable "Email/Password"
- Click "Save"

### Google Sign-in
- Click "Google"
- Enable "Google"
- Add your support email
- Click "Save"

### Facebook Sign-in
- Click "Facebook"
- Enable "Facebook"
- You'll need to configure this in the next step
- Click "Save"

## Step 4: Configure Facebook Sign-in

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or select existing one
3. Add "Facebook Login" product
4. Configure OAuth redirect URIs:
   - Add: `https://YOUR_PROJECT_ID.firebaseapp.com/__/auth/handler`
5. Copy your App ID and App Secret
6. In Firebase Console, paste the App ID and App Secret
7. Save the configuration

## Step 5: Configure Google Sign-in

1. In Firebase Console, go to "Project settings" → "General"
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the "Web client ID" (ends with `.apps.googleusercontent.com`)
5. Update your `google-services.json` with this client ID

## Step 6: Update Dependencies

Run the following command to get the new dependencies:

```bash
flutter pub get
```

## Step 7: Test the Integration

1. Run your app: `flutter run`
2. Test the sign-up flow:
   - Try creating an account with email/password
   - Try signing up with Google
   - Try signing up with Facebook
3. Test the login flow:
   - Try logging in with existing credentials
   - Try social login with existing accounts

## Troubleshooting

### Common Issues

1. **"Google Play services not available"**
   - Make sure you're testing on a device with Google Play Services
   - For emulators, use Google Play Services enabled images

2. **"Facebook login failed"**
   - Verify your Facebook app configuration
   - Check that the redirect URI is correct
   - Ensure your app is not in development mode (if testing on non-developer devices)

3. **"Firebase not initialized"**
   - Make sure `google-services.json` is in the correct location
   - Verify the package name matches in Firebase Console

4. **"Authentication failed"**
   - Check Firebase Console for error logs
   - Verify your API keys are correct
   - Ensure the authentication methods are enabled

### Debug Mode

To see detailed Firebase logs, add this to your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Firebase debug mode
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

## Security Notes

1. **API Keys**: The `google-services.json` file contains sensitive information. Never commit it to public repositories.
2. **OAuth Client IDs**: Keep your OAuth client IDs secure and don't share them publicly.
3. **Testing**: Use test accounts for development and testing.

## Next Steps

After successful setup, you can:

1. Add user profile management
2. Implement password reset functionality
3. Add email verification
4. Set up user roles and permissions
5. Integrate with other Firebase services (Firestore, Storage, etc.)

## Support

If you encounter issues:

1. Check the [Firebase Documentation](https://firebase.google.com/docs)
2. Review [Flutter Firebase Plugin docs](https://firebase.flutter.dev/)
3. Check the [Firebase Console](https://console.firebase.google.com/) for error logs
4. Verify your configuration matches the examples in this guide

## File Structure

Your Firebase integration is now set up with these files:

- `lib/services/auth_service.dart` - Firebase authentication logic
- `lib/state/auth_state.dart` - Authentication state management
- `android/app/google-services.json` - Firebase configuration (replace with your file)
- Updated `lib/screens/login_screen.dart` and `lib/screens/signup_screen.dart`
- Updated Android configuration files

The app now supports:
- ✅ Email/password sign-up and sign-in
- ✅ Google sign-in
- ✅ Facebook sign-in
- ❌ Apple sign-in (removed as requested)
- ✅ Form validation
- ✅ Loading states
- ✅ Error handling with user-friendly messages
