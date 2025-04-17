import 'package:animations/animations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/auth/cubit/manage_password_cubit.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/change_password_view/cubit/change_password_cubit.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/change_password_view/view/change_password_view.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/widgets/forgot_password_email_send_button.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/widgets/forgot_password_form.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:user_repository/user_repository.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
class ManageForgotPasswordPage extends StatelessWidget {
  const ManageForgotPasswordPage({super.key});

  static Route<void> route() => PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
      return const ManageForgotPasswordPage();
    },
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ); 

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ManagePasswordCubit()),
        BlocProvider(create: (context) => ForgotPasswordCubit(
          userRepository: context.read<UserRepository>()
        )),
        BlocProvider(create: (context) => ChangePasswordCubit(
          userRepository: context.read<UserRepository>()
        )),
      ],
      child: const ForgotPasswordPage()
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final showForgotPassword = context.select((ManagePasswordCubit b) => b.state);
    return PageTransitionSwitcher(
      reverse: showForgotPassword,
      transitionBuilder: (
        child,
        animation,
        secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: showForgotPassword ? const ForgotPasswordView() : const ChangePasswordView()
    );
  }
}
//------------------------------------------------------------------------------------//
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(context.l10n.recoveryPasswordText),
        centerTitle: false,
      ),
      body: const AppConstrainedScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.v(AppSpacing.xxxlg * 3),
              ForgotPasswordEmailConfirmationLabel(),
              Gap.v(AppSpacing.lg / 2),
              ForgotPasswordForm(),
              Gap.v(AppSpacing.lg / 2),
              ForgotButtonSendEmailButton()
            ],
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------------//
class ForgotPasswordEmailConfirmationLabel extends StatelessWidget {
  const ForgotPasswordEmailConfirmationLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.forgotPasswordEmailConfirmationText,
      style: context.headlineSmall,
    );
  }
}
