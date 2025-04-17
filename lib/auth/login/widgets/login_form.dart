import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/auth/auth.dart';
import 'package:flutter_instagram_clone/auth/login/widgets/email_form_field.dart';
import 'package:flutter_instagram_clone/auth/login/widgets/password_form_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isError) {
          openSnackBar(
            SnackbarMessage.error(
              title: loginSubmissionStatusMessage[state.status]!.title,
              description: loginSubmissionStatusMessage[state.status]?.description,
            ),
            clearIfQueue: true
          );
        }
      },
      listenWhen: (previous, current) => previous.status != current.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailFormField(),
          SizedBox(height: AppSpacing.lg / 2),
          PasswordFormField()
        ],
      ),
    );
  }
}
