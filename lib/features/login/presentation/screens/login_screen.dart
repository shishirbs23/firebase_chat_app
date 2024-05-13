import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final email = useState<String>('');
    final password = useState<String>('');
    final obscureText = useState<bool>(true);
    final loading = useState<bool>(false);

    AppBar appBar = AppBar(
      title: const Text(
        AppStrings.signIn,
        style: TextStyle(
          color: AppColors.white,
        ),
      ),
      elevation: 1,
      backgroundColor: AppColors.appBarColor,
    );

    TextFormField emailField = TextFormField(
      decoration: const InputDecoration(
        labelText: AppStrings.email,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.pleaseEnterEmail;
        }
        return null;
      },
      onSaved: (value) => email.value = value!,
    );

    TextFormField passwordField = TextFormField(
      decoration: InputDecoration(
        labelText: AppStrings.password,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText.value ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            obscureText.value = !obscureText.value;
          },
        ),
      ),
      obscureText: obscureText.value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.pleaseEnterPassword;
        }
        return null;
      },
      onSaved: (value) => password.value = value!,
    );

    Future<void> handleSignIn() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
      } else {
        return;
      }

      loading.value = true;

      SignInResult result = await FirebaseSettings().signInWithEmailAndPassword(
        email.value,
        password.value,
      );

      if (result.error != null) {
        loading.value = false;

        String msg;

        switch (result.error) {
          case SignInError.invalidEmail:
            msg = AppStrings.invalidEmail;
            break;
          case SignInError.invalidCredential:
            msg = AppStrings.invalidCredential;
            break;
          case SignInError.userNotFound:
            msg = AppStrings.userNotFound;
            break;
          case SignInError.wrongPassword:
            msg = AppStrings.wrongPassword;
            break;
          default:
            msg = AppStrings.commonError;
            break;
        }

        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.redAccent,
          textColor: AppColors.white,
          fontSize: 16.0,
        );
      } else {
        FirebaseFirestore.instance.collection(AppStrings.loggedInUsers).add(
          {
            AppStrings.userId: FirebaseSettings().currentUser?.uid,
            AppStrings.emailField: email.value,
          },
        );

        Fluttertoast.showToast(
          msg: AppStrings.successfullySignedIn,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.greenAccent,
          textColor: AppColors.white,
          fontSize: 16.0,
        );
        context.goNamed(RouteNames.startChat);
        loading.value = false;
      }
    }

    ElevatedButton loginButton = ElevatedButton(
      onPressed: loading.value ? null : handleSignIn,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loading.value ? AppStrings.signingIn : AppStrings.signIn,
              style: TextStyle(
                fontSize: 16.0,
                color: loading.value ? AppColors.grey : AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (loading.value) const SizedBox(width: 12.0),
            if (loading.value)
              const SizedBox(
                height: 22.0,
                width: 22.0,
                child: CircularProgressIndicator(
                  color: Colors.grey,
                  strokeWidth: 3.0,
                ),
              ),
          ],
        ),
      ),
    );

    Future<void> handleGoogleSignIn() async {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Sign in to Firebase with Google credentials
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          // Handle the signed-in user (e.g., store user data, navigate to next screen)
          if (userCredential.user != null) {
            // Perform necessary actions after successful sign-in
            // e.g., save user data to Firestore, navigate to next screen
            // Example: FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({...});

            // Navigate to next screen upon successful sign-in
            print(userCredential.user?.displayName);
            print(userCredential.user?.email);
            print(userCredential.user?.phoneNumber);
            print(userCredential.user?.photoURL);

            // context.goNamed(RouteNames.startChat);
          }
        }
      } catch (e) {
        print('Google Sign-In Error: $e');
        // Handle sign-in errors as needed
      }
    }

    Widget googleSignInButton = ElevatedButton.icon(
      onPressed: loading.value ? null : handleGoogleSignIn,
      icon: Image.asset(
        'assets/images/google_logo.webp',
        height: 25.0,
        width: 25.0,
      ),
      label: const Text('Sign in with Google'),
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blue,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              emailField,
              passwordField,
              const SizedBox(height: 20),
              loginButton,
              const SizedBox(height: 20),
              googleSignInButton
            ],
          ),
        ),
      ),
    );
  }
}
