import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:form_fields/form_fields.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:user_repository/user_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
    LoginCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const LoginState.initial());

  final UserRepository _userRepository;

  void changedPasswordVisibility()  
      => emit(state.copyWith(showPassword: !state.showPassword));

  /// Email value was changed, triggering new changes in state.
  void onEmailChanged(String newValue) {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final shouldValidate = previousEmailState.invalid;
    final newEmailState = shouldValidate
        ? Email.dirty(
            newValue,
          )
        : Email.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      email: newEmailState,
    );

    emit(newScreenState);
  }

  /// Email field was unfocused, here is checking if previous state with email
  /// was valid, in order to indicate it in state after unfocus.
  void onEmailUnfocused() {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final previousEmailValue = previousEmailState.value;

    final newEmailState = Email.dirty(
      previousEmailValue,
    );
    final newScreenState = previousScreenState.copyWith(
      email: newEmailState,
    );
    emit(newScreenState);
  }

  /// Password value was changed, triggering new changes in state.
  /// Checking whether or not value is valid in [Password] and emmiting new
  /// [Password] validation state.
  void onPasswordChanged(String newValue) {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final shouldValidate = previousPasswordState.invalid;
    final newPasswordState = shouldValidate
        ? Password.dirty(
            newValue,
          )
        : Password.pure(
            newValue,
          );

    final newScreenState = state.copyWith(
      password: newPasswordState,
    );

    emit(newScreenState);
  }

  void onPasswordUnfocused() {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final previousPasswordValue = previousPasswordState.value;

    final newPasswordState = Password.dirty(
      previousPasswordValue,
    );
    final newScreenState = previousScreenState.copyWith(
      password: newPasswordState,
    );
    emit(newScreenState);
  }

    Future<void> onSubmit() async {
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final isFormValid = FormzValid([email, password]).isFormValid;

    final newState = state.copyWith(
      email: email,
      password: password,
      status: isFormValid ? LogInSubmissionStatus.loading : null,
    );

    emit(newState);

    if (!isFormValid) return;

    try {
      await _userRepository.logInWithPassword(
        email: email.value,
        password: password.value,
      );
      final newState = state.copyWith(status: LogInSubmissionStatus.success);
      emit(newState);
    } catch (e, stackTrace) {
      _errorFormatter(e, stackTrace);
    }
  }

  // / Formats error, that occurred during login process.
  void _errorFormatter(Object e, StackTrace stackTrace) {
    addError(e, stackTrace);
    final status = switch (e) {
      LogInWithPasswordFailure(:final AuthException error) => switch (
            error.statusCode?.parse) {
          HttpStatus.badRequest => LogInSubmissionStatus.invalidCredentials,
          _ => LogInSubmissionStatus.error,
        },
      LogInWithGoogleFailure => LogInSubmissionStatus.googleLogInFailure,
      _ => LogInSubmissionStatus.idle,
    };

    final newState = state.copyWith(
      status: status,
      message: e.toString(),
    );
    emit(newState);
  }

    Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: LogInSubmissionStatus.googleAuthInProgress));
    try {
      await _userRepository.logInWithGoogle();
      emit(state.copyWith(status: LogInSubmissionStatus.success));
    } on LogInWithGoogleCanceled {
      emit(state.copyWith(status: LogInSubmissionStatus.idle));
    } catch (error, stackTrace) {
      _errorFormatter(error, stackTrace);
    }
  }

  Future<void> loginWithGithub() async {
    emit(state.copyWith(status: LogInSubmissionStatus.githubAuthInProgress));
    try {
      await _userRepository.logInWithGithub();
      emit(state.copyWith(status: LogInSubmissionStatus.success));
    } on LogInWithGithubCanceled {
      emit(state.copyWith(status: LogInSubmissionStatus.idle));
    } catch (error, stackTrace) {
      _errorFormatter(error, stackTrace);
    }
  }
}
