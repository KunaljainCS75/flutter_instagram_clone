import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class ForgotPassordEmailFormField extends StatefulWidget {
  const ForgotPassordEmailFormField({super.key});
  
  @override
  State<ForgotPassordEmailFormField> createState() => _ForgotPasswordEmailFormFieldState();
}

class _ForgotPasswordEmailFormFieldState extends State<ForgotPassordEmailFormField> {

  late FocusNode _focusNode;
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode..removeListener(_focusNodeListener)..dispose();
    _debouncer.dispose();
  }

  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      context.read<ForgotPasswordCubit>().onEmailUnfocused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailError = context.select((ForgotPasswordCubit cubit) => cubit.state.email.errorMessage);
    
    return AppTextField(
      filled: true,
      errorText: emailError,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) => _debouncer.run(() {
        context.read<ForgotPasswordCubit>().onEmailChanged(value);
      }),
    );
  }
}