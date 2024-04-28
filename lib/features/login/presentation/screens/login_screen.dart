import 'package:firebase_chat_app/core/config/routing/app_router_generator.dart';
import 'package:firebase_chat_app/utils/app_colors.dart';
import 'package:firebase_chat_app/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_chat_app/core/config/firebase/firebase_settings.dart';

final obscureTextProvider = StateProvider<bool>((ref) => true);
final loadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

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

  TextFormField get emailField => TextFormField(
        decoration: const InputDecoration(
          labelText: AppStrings.email,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.pleaseEnterEmail;
          }
          return null;
        },
        onSaved: (value) => _email = value!,
      );

  TextFormField get passwordField {
    final obscureText = ref.watch(obscureTextProvider);

    return TextFormField(
      decoration: InputDecoration(
        labelText: AppStrings.password,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            ref.read(obscureTextProvider.notifier).state = !obscureText;
          },
        ),
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.pleaseEnterPassword;
        }
        return null;
      },
      onSaved: (value) => _password = value!,
    );
  }

  Widget get loginButton {
    return ElevatedButton(
      onPressed:
          !ref.read(loadingProvider.notifier).state ? handleSignIn : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.read(loadingProvider.notifier).state
                  ? AppStrings.signingIn
                  : AppStrings.signIn,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            if (ref.read(loadingProvider.notifier).state)
              const SizedBox(width: 12.0),
            if (ref.read(loadingProvider.notifier).state)
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
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              emailField,
              passwordField,
              const SizedBox(height: 20),
              loginButton,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;

    SignInResult result = await FirebaseSettings().signInWithEmailAndPassword(
      _email,
      _password,
    );

    if (result.error != null) {
      ref.read(loadingProvider.notifier).state = false;

      switch (result.error) {
        case SignInError.invalidEmail:
          Fluttertoast.showToast(
            msg: AppStrings.invalidEmail,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redAccent,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          break;
        case SignInError.invalidCredential:
          Fluttertoast.showToast(
            msg: AppStrings.invalidCredential,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redAccent,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          break;
        case SignInError.userNotFound:
          Fluttertoast.showToast(
            msg: AppStrings.userNotFound,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redAccent,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          break;
        case SignInError.wrongPassword:
          Fluttertoast.showToast(
            msg: AppStrings.wrongPassword,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redAccent,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          break;
        default:
          Fluttertoast.showToast(
            msg: AppStrings.commonError,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redAccent,
            textColor: AppColors.white,
            fontSize: 16.0,
          );
          break;
      }
    } else {
      ref.read(loadingProvider.notifier).state = false;
      Fluttertoast.showToast(
        msg: AppStrings.successfullySignedIn,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.greenAccent,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
      context.goNamed(RouteNames.chat);
    }
  }
}
