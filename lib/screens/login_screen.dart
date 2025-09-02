import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tanaw_app/state/profile_state.dart';
import 'package:provider/provider.dart';
import 'package:tanaw_app/state/auth_state.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Soft blue background
      body: Stack(
        children: [
          if (authState.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(102),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          // Top illustration part
          Container(
            height: screenHeight * 0.4,
            width: double.infinity,
            color: const Color(0xFF153A5B), // Tanaw blue
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/hellologin.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          // Bottom card form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.75,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Hello Again!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF153A5B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome back you\'ve been missed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: authState.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            HapticFeedback.lightImpact();
                            final success = await authState.signInWithEmailAndPassword(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                            if (success && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF153A5B),
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('or connect with',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 14)),
                          ),
                          const Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                              icon: FontAwesomeIcons.google,
                              color: const Color(0xFFDB4437),
                              onPressed: authState.isLoading ? null : () async {
                                final success = await authState.signInWithGoogle();
                                if (success && mounted) {
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final profileState = Provider.of<ProfileState>(context, listen: false);
                                    if (user.displayName != null && user.displayName!.isNotEmpty) {
                                      profileState.updateUserName(user.displayName!);
                                    }
                                    if (user.email != null && user.email!.isNotEmpty) {
                                      profileState.updateUserEmail(user.email!);
                                    }
                                    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
                                      profileState.updateUserImageUrl(user.photoURL);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.white,
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Color(0xFF153A5B)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Signed in as ${user.email ?? user.displayName ?? 'Google user'}',
                                                style: const TextStyle(color: Color(0xFF153A5B), fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomeScreen()),
                                  );
                                }
                              }),
                        ],
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 15),
                            children: const [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF153A5B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF153A5B),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF153A5B)),
            filled: true,
            fillColor: const Color(0xFFF3F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      {required IconData icon,
      required Color color,
      required VoidCallback? onPressed}) {
    return InkWell
    (
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}