import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'auth/auth_service.dart';
import 'login_page.dart';
import 'home_page.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.label,
    required this.controller,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Spacer(),
                const Text(
                  "Signup",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  hint: "Enter Name",
                  label: "Name",
                  controller: _name,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Email",
                  label: "Email",
                  controller: _email,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Enter Password",
                  label: "Password",
                  isPassword: true,
                  controller: _password,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Confirm Password",
                  label: "Confirm Password",
                  isPassword: true,
                  controller: _confirmPassword,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  label: "Signup",
                  onPressed: _signup,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    InkWell(
                      onTap: () => goToLogin(context),
                      child: const Text("Login",
                          style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

  Future<void> _signup() async {
    if (_password.text != _confirmPassword.text) {
      _showError("Passwords do not match. Please try again.");
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user =
          await _auth.createUserWithEmailAndPassword(_email.text, _password.text);

      if (user != null) {
        log("User Created Successfully");

        // Send email verification
        await user.sendEmailVerification();
        await _showMessage(
          "A verification email has been sent to ${_email.text}. Please verify your email to complete signup.",
        );

        // Wait for email verification
        bool isVerified = false;
        while (!isVerified) {
          await Future.delayed(const Duration(seconds: 2));
          await user.reload();
          isVerified = user.emailVerified;
        }

        await _showMessage("Email verified successfully! Redirecting to the home page...");
        goToHome(context);
      }
    } catch (e) {
      _showError("Signup failed: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showMessage(String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showError(String error) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
