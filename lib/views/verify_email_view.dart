import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_services.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('verify your email')),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            const Text("we 've sent you an email to verify your email"),
            const Text("if you haven't received it yet"),
            TextButton(
              onPressed: () async {
                // await AuthServices.firebase().sendEmailVerification();
                context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification(),
                );
              },
              child: Text('click here to send verification again'),
            ),
            TextButton(
              onPressed: () async {
                // await AuthServices.firebase().logOut();
                // Navigator.of(
                //   context,
                // ).pushNamedAndRemoveUntil(registerRoute, (_) => false);
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
