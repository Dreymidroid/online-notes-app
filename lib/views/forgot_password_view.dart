import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';
import 'package:mynotes/utilities/dialog/password_reset_email_sent_dialog.dart';

import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    _ctrl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentMail) {
            _ctrl.clear();
            await showPasswordResetDialog(context);
          }

          if (state.exception != null) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(
              context,
              'Please make sure you are registered.',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Input Email to get reset link"),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: _ctrl,
                  decoration: const InputDecoration(hintText: 'Email Address...'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final email = _ctrl.text;
          
                    context.read<AuthBloc>().add(
                          AuthEventForgotPassword(email),
                        );
                  },
                  child: const Text('Send Reset Link'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text('Back To Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
