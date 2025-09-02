import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tanaw_app/state/profile_state.dart';
import 'package:provider/provider.dart';
import 'package:tanaw_app/state/auth_state.dart';
import 'login_screen.dart';
import 'complete_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF153A5B),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            children: [
              Container(
                height: screenHeight * 0.4,
                width: double.infinity,
                color: const Color(0xFF153A5B),
                child: Align(
                  alignment: const Alignment(0.0, -0.2),
                  child: Image.asset(
                    'assets/signuphello.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Be Part of Tanaw!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF153A5B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A smarter way to see the world—together!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(
                            label: 'Email Address',
                            controller: emailController,
                            icon: Icons.email_outlined,
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
                            controller: passwordController,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Confirm Password',
                            controller: confirmPasswordController,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: authState.isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.lightImpact();
                                final success = await authState.signUpWithEmailAndPassword(
                                  emailController.text.trim(),
                                  passwordController.text,
                                );
                                if (success && mounted) {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        title: const Text('Confirm Account Creation'),
                                        content: const Text('Are you sure you want to create a new account?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF153A5B)),
                                            child: const Text('Yes', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ?? false;

                                  if (!confirmed) {
                                    return;
                                  }
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final profileState = Provider.of<ProfileState>(context, listen: false);
                                    if (user.email != null && user.email!.isNotEmpty) {
                                      profileState.updateUserEmail(user.email!);
                                    }
                                    if (user.displayName == null || user.displayName!.isEmpty) {
                                      profileState.updateUserName(user.email?.split('@').first ?? 'User');
                                    } else {
                                      profileState.updateUserName(user.displayName!);
                                    }
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompleteProfileScreen(
                                        onCompleted: () {
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Colors.white,
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Color(0xFF153A5B)),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      'Account created successfully!',
                                                      style: TextStyle(color: Color(0xFF153A5B), fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                            (route) => false,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF153A5B),
                              minimumSize: const Size.fromHeight(55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('or connect with',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),
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
                                            builder: (context) => const LoginScreen()),
                                      );
                                    }
                                  }),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15),
                                children: const [
                                  TextSpan(
                                    text: 'Sign In',
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
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
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text('Continue with Google', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}