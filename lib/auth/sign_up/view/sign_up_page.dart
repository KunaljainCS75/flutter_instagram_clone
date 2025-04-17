import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/auth/auth.dart';
import 'package:flutter_instagram_clone/auth/sign_up/widgets/sign_in_into_account_button.dart';
import 'package:flutter_instagram_clone/auth/sign_up/widgets/sign_up_button.dart';
import 'package:flutter_instagram_clone/auth/sign_up/widgets/sign_up_form.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        notificationsRepository: context.read<NotificationsRepository>(),
        userRepository: context.read<UserRepository>()
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  File? _avatarFile;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg + AppSpacing.xlg),
            const AppLogo(fit: BoxFit.fitHeight),
            const SizedBox(height: AppSpacing.xlg / 2),
            AvatarImagePicker(
              onUpload: (_, avatarFile) {
                setState(() => _avatarFile = avatarFile);
              }
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xlg),
                  const SignUpForm(),
                  const SizedBox(height: AppSpacing.xlg),
                  SignUpButton(
                    avatarFile: _avatarFile,
                  )
                ],
              ),
            ),
            const SignInIntoAccountButton()
          ],
        ),
      ),
    );
  }
}