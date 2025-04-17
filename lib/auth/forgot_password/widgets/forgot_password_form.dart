import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/widgets/widgets.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';


class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          openSnackBar(
            SnackbarMessage.success(
              title: context.l10n.verificationTokenSentText(state.email.value)
            )
          );
        }
        if (state.status.isError) {
           openSnackBar(
            SnackbarMessage.error(
              title: forgotPasswordStatusMessage[state.status]!.title,
              description: forgotPasswordStatusMessage[state.status]?.description
            ),
            clearIfQueue: true
          );
        }
      },
      listenWhen: (previous, current) => previous.status != current.status,
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForgotPassordEmailFormField()
          ],
        ),
    );
  }
}