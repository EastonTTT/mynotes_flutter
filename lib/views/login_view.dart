import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/error_dialog.dart';
import 'package:mynotes/utils/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Logging in...',
            );
          }
          if (state.exception is InvalidCredentialsAuthException) {
            await showErrorDialog(context, 'Invalid email or password.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error.');
          }
        }
      },
      child: Scaffold(
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
                  //   await AuthServices.firebase().logIn(
                  //     email: email,
                  //     password: password,
                  //   );
                  //   final user = AuthServices.firebase().currentUser;
                  //   if (user?.isEmailVerified ?? false) {
                  //     Navigator.of(
                  //       context,
                  //     ).pushNamedAndRemoveUntil(noteRoute, (_) => false);
                  //   } else {
                  //     Navigator.of(context).pushNamed(verifyEmailRoute);
                  //   }

                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                } on Exception catch (e) {}
                // on InvalidEmailAuthException catch (_) {
                //   await showErrorDialog(context, 'Invalid email or password.');
                // } on InvalidCredentialsAuthException catch (_) {
                //   await showErrorDialog(context, 'Invalid email or password.');
                // } catch (e) {
                //   print(e);
                //   await showErrorDialog(context, 'Error: $e');
                // }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegeister());
                // Navigator.of(
                //   context,
                // ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: Text('Click here to register!'),
            ),
          ],
        ),
      ),
    );
  }
}
