import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/utils/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthServices.firebase().logIn(
                  email: email,
                  password: password,
                );
                final user = AuthServices.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(noteRoute, (_) => false);
                } else {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on InvalidEmailAuthException catch (_) {
                await showErrorDialog(context, 'Invalid email or password.');
              } on InvalidCredentialsAuthException catch (_) {
                await showErrorDialog(context, 'Invalid email or password.');
              } catch (e) {
                print(e);
                await showErrorDialog(context, 'Error: $e');
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: Text('Click here to register!'),
          ),
        ],
      ),
    );
  }
}
