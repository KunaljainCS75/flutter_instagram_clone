import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/app.dart';
import 'package:flutter_instagram_clone/app/routes/routes.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:flutter_instagram_clone/selector/selector.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = router(context.read<AppBloc>());
//  BlocProvider: Ensures a BLoC is available for widgets in its subtree.
//  BlocBuilder: Reacts to state changes from a BLoC and 
//  rebuilds the relevant part of the UI.
    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => LocaleSettings.setLocaleRaw(locale.languageCode)
        );
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return AnimatedSwitcher(
              duration: 1000.ms,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling
                  // to avoid system font size change effects
                ),
                child: MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    themeMode: themeMode,
                    theme: const AppTheme().theme,
                    darkTheme: const AppDarkTheme().theme,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    builder: (context, child) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => initUtilities(context, locale)
                      );
                      return Stack(
                        children: [
                          child!,
                          AppSnackbar(key: snackBarKey),
                          AppLoadingIndeterminate(key: loadingIndeterminateKey)
                        ],
                      );
                    },
                    routerConfig: routerConfig,
                    locale: locale,
                  ),
              ),
            );
          },
        );
      },
    );
  }
}


// Scaffold(
//   body: Center(child: Text(getIt<AppFlavor>().getEnv(Env.webClientId))),
// ),