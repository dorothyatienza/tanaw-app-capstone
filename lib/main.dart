import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tanaw_app/screens/splash_screen.dart';
import 'package:tanaw_app/state/guardian_mode_state.dart';
import 'package:tanaw_app/state/tts_state.dart';
import 'package:tanaw_app/state/profile_state.dart';
import 'package:tanaw_app/state/connection_state.dart' as app_connection;
import 'package:tanaw_app/state/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => GuardianModeState()),
        ChangeNotifierProvider(create: (_) => TtsState()),
        ChangeNotifierProvider(create: (_) => ProfileState()),
        ChangeNotifierProvider(create: (_) => app_connection.ConnectionState()),
      ],
      child: const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TANAW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}