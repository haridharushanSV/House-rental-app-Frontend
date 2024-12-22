// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'auth/auth_service.dart';
// import 'signup_page.dart';
// import 'home_page.dart';

// class CustomButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//   final Color? color;

//   const CustomButton({
//     Key? key,
//     required this.label,
//     required this.onPressed,
//     this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color ?? Theme.of(context).primaryColor,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       onPressed: onPressed,
//       child: Text(
//         label,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

// class CustomTextField extends StatelessWidget {
//   final String hint;
//   final String label;
//   final TextEditingController controller;

//   const CustomTextField({
//     Key? key,
//     required this.hint,
//     required this.label,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hint,
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = AuthService();
//   final _email = TextEditingController();
//   final _password = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo or Branding Section
//               Image.asset(
//                 'assets/logo.png', // Replace with your logo
//                 height: 100,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Login",
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),

//               // Email Field
//               CustomTextField(
//                 hint: "Enter your email",
//                 label: "Email",
//                 controller: _email,
//               ),
//               const SizedBox(height: 20),

//               // Password Field
//               CustomTextField(
//                 hint: "Enter your password",
//                 label: "Password",
//                 controller: _password,
//               ),
//               const SizedBox(height: 30),

//               // Login Button
//               _isLoading
//                   ? const CircularProgressIndicator()
//                   : CustomButton(
//                       label: "Login",
//                       onPressed: _login,
//                       color: Colors.blue,
//                     ),
//               const SizedBox(height: 20),

//               // Sign Up with Google Button
//               CustomButton(
//                 label: "Sign Up with Google",
//                 onPressed: _signUpWithGoogle,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),

//               // Signup Navigation
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("New User? "),
//                   GestureDetector(
//                     onTap: () => goToSignup(context),
//                     child: const Text(
//                       "Signup",
//                       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   goToSignup(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const SignupScreen()),
//     );
//   }

//   goToHome(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => HomePage()),
//     );
//   }

//   _login() async {
//     setState(() => _isLoading = true);
//     try {
//       final user =
//           await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
//       if (user != null) {
//         log("User Logged In");
//         goToHome(context);
//       } else {
//         _showError("Invalid credentials");
//       }
//     } catch (e) {
//       _showError("Something went wrong");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _signUpWithGoogle() async {
//     try {
//       final GoogleSignIn googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//       if (googleUser != null) {
//         final GoogleSignInAuthentication googleAuth =
//             await googleUser.authentication;
//         final credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );

//         final userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);
//         if (userCredential.user != null) {
//           log("Google Sign-In successful");
//           goToHome(context);
//         }
//       }
//     } catch (e) {
//       _showError("Google Sign-In failed. Please try again.");
//     }
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Alert'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth/auth_service.dart';
import 'signup_page.dart';
import 'home_page.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Redirect to home if the user is already logged in
      Future.microtask(() => goToHome(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your logo
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Login",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                hint: "Enter your email",
                label: "Email",
                controller: _email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: "Enter your password",
                label: "Password",
                controller: _password,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      label: "Login",
                      onPressed: _login,
                      color: Colors.blue,
                    ),
              const SizedBox(height: 20),
              CustomButton(
                label: "Sign Up with Google",
                onPressed: _signUpWithGoogle,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New User? "),
                  GestureDetector(
                    onTap: () => goToSignup(context),
                    child: const Text(
                      "Signup",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  _login() async {
    setState(() => _isLoading = true);
    try {
      final user =
          await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
      if (user != null) {
        log("User Logged In");
        goToHome(context);
      } else {
        _showError("Invalid credentials");
      }
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          log("Google Sign-In successful");
          goToHome(context);
        }
      }
    } catch (e) {
      _showError("Google Sign-In failed. Please try again.");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
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
}
