import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/forgot_password_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/login.dart';
import 'package:mynotes/views/signup.dart';
import 'package:mynotes/views/verify.dart';
import 'constants/routes.dart';
// import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      routes: {
        loginRoute: (context) => const Login(),
        signupRoute: (context) => const SignUp(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
      debugShowCheckedModeBanner: false,
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(FirebaseAuthProvider()),
        child: const MyHomePage(),
      ),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(
          const AuthEventInitialize(),
        );

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please Wait',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyView();
        } else if (state is AuthStateLoggedOut) {
          return const Login();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const SignUp();
        } else {
          return const Material(
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
      },
    );
  }
}

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   late final TextEditingController _textEditingController;

//   @override
//   void initState() {
//     _textEditingController = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Bloc Test"),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalidNumber) ? state.invalidNumber : '';

//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Current Value is ${state.value}"),
//                 Visibility(
//                   visible: state is CounterStateInvalidNumber,
//                   child: Text("$invalidValue is not a valid value"),
//                 ),
//                 TextField(
//                     decoration: const InputDecoration(hintText: "Type Number"),
//                     keyboardType: TextInputType.number,
//                     controller: _textEditingController),
//                 Row(
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         context.read<CounterBloc>().add(DecrementEvent(_textEditingController.text));
//                       },
//                       child: const Text("__"),
//                     ),

//                     TextButton(
//                       onPressed: () {
//                         context.read<CounterBloc>().add(IncrementEvent(_textEditingController.text));
//                       },
//                       child: const Text("+"),
//                     ),
//                   ],
//                 )
//               ],
//             );
//           },
//           listener: (context, state) {
//             _textEditingController.clear();
//           },
//         ),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;

//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidNumber;

//   const CounterStateInvalidNumber({
//     required this.invalidNumber,
//     required int previousValue,
//   }) : super(previousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;

//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);

//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//             invalidNumber: event.value, previousValue: state.value));
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });

//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);

//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidNumber: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
// }
