// ignore_for_file: lines_longer_than_80_chars

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/auth/login/cubit/login_cubit.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key});
  
  @override
  State<PasswordFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<PasswordFormField> {

  late TextEditingController _controller;
  late FocusNode _focusNode;
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode..removeListener(_focusNodeListener)..dispose();
    _debouncer.dispose();
  }

  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      context.read<LoginCubit>().onPasswordUnfocused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordError = context.select((LoginCubit cubit) => cubit.state.password.errorMessage);
    final showPassword = context.select((LoginCubit cubit) => cubit.state.showPassword);
    return AppTextField(
      filled: true,
      textController: _controller,
      errorText: passwordError,
      focusNode: _focusNode,
      hintText: context.l10n.passwordText,
      textInputType: TextInputType.visiblePassword,
      obscureText: !showPassword,
      suffixIcon: Tappable.faded(
        backgroundColor: AppColors.transparent,
        onTap: context.read<LoginCubit>().changedPasswordVisibility,
        child: Icon(
          !showPassword ? Icons.visibility : Icons.visibility_off,
          color: context.customAdaptiveColor(light: AppColors.grey),
        ),
      ),
      textInputAction: TextInputAction.done,
      onChanged: (value) => _debouncer.run(() {
        context.read<LoginCubit>().onPasswordChanged(value);
      }),
    );
  }
}