
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/auth/sign_up/cubit/sign_up_cubit.dart';
import 'package:flutter_instagram_clone/auth/sign_up/widgets/widgets.dart';

/// Sign up form that contains email and password fields.
// ignore: doc_directive_missing_opening_tag
/// {@endtemplate}
class SignUpForm extends StatefulWidget {
  /// {@macro sign_up_form}
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if (state.submissionStatus.isError) {
          openSnackBar(
            SnackbarMessage.error(
              title: signupSubmissionStatusMessage[state.submissionStatus]!.title,
              description: signupSubmissionStatusMessage[state.submissionStatus]
                  ?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (p, c) => p.submissionStatus != c.submissionStatus,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailTextField(),
          SizedBox(height: AppSpacing.xlg / 2),
          FullNameTextField(),
          SizedBox(height: AppSpacing.xlg / 2),
          UsernameTextField(),
          SizedBox(height: AppSpacing.xlg / 2),
          PasswordTextField(),
        ],
      )
    );
  }
}
