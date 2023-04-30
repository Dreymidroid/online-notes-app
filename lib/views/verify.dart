// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import '../services/auth/bloc/auth_bloc.dart';

class VerifyView extends StatefulWidget {
  const VerifyView({super.key});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
            top: 250, left: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            const Text(
              "Verification mail have been sent, if not seen click below",
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                onPressed: () async {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventSendEmailVerification());

                },
                child: const Text("Re Send")),
            TextButton(
                onPressed: () async {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventLogOut());

                },
                child: const Text("Restart")),
          
          ],
        ),
      ),
    );
  }
}
