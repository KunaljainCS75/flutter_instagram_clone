import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/auth/login/cubit/login_cubit.dart';
import 'package:flutter_instagram_clone/auth/login/widgets/widgets.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        userRepository: context.read<UserRepository>(), 
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg * 2),
            // App Logo
            const AppLogo(fit: BoxFit.fitHeight, width: double.infinity),
            const SizedBox(height: AppSpacing.lg / 2),
        
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
        
                  // Login Form
                  const LoginForm(),
                  const SizedBox(height: AppSpacing.xs),
        
                  // Forgot Password Button
                   const Align(
                    alignment: Alignment.bottomRight,
                    child: ForgotPasswordButton(),
                  ),
                  const SizedBox(height: AppSpacing.xlg / 2),
        
                  // SignIn Button
                  const Align(
                    child: SignInButton(),
                  ),
                  const SizedBox(height: AppSpacing.xlg / 2),
        
        
                  // Divider
                  const AppDivider(),
                  const SizedBox(height: AppSpacing.xlg),
        
                  // Google / Github Sign in Button
                  AuthProviderSignInButton(
                    provider: AuthProvider.google, 
                    onPressed: () => {
                      context.read<LoginCubit>().loginWithGoogle()
                    }
                  ),
        
                  AuthProviderSignInButton(
                    provider: AuthProvider.github, 
                    onPressed: () => {
                      context.read<LoginCubit>().loginWithGithub()
                    }
                  ),
                  // ElevatedButton(onPressed: () => context.read<UserRepository>().logOut(), child: Text("Logout"))
                ],
              ),
            ),
            // ElevatedButton(
            //   onPressed: () =>openSnackBar(SnackbarMessage.success(title: "Snackbar is opened successfully as per your demand")), 
            // child: Text("Snackbar")),
            const SignUpNewAccountButton(),
            ElevatedButton(onPressed: () => context.read<UserRepository>().logOut(), 
            child: const Text("Logout"),)
          ],
        ),
      ),
    );
  }
}
