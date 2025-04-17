import 'dart:async';
import 'dart:developer';
import 'package:app_ui/app_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_instagram_clone/app/di/di.dart';
import 'package:flutter_instagram_clone/l10n/slang/translations.g.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

typedef AppBuilder = FutureOr<Widget> Function(
  PowerSyncRepository,
  FirebaseRemoteConfigRepository,
  FirebaseMessaging,
  SharedPreferences
);

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logD('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logD('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  logI('Handling a background message: ${message.toMap()}');
}

Future<void> bootstrap(
  AppBuilder builder, 
  {
    required AppFlavor appFlavor,
    required FirebaseOptions options,
  }) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

   await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      setupDi(appFlavor: appFlavor);

      await Firebase.initializeApp(options: options);


      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getTemporaryDirectory(),
      );

      final powerSyncRepository = PowerSyncRepository(env: appFlavor.getEnv);
      await powerSyncRepository.initialize();

      final firebaseMessaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final sharedPreferences = await SharedPreferences.getInstance();

      final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
      final firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository(
        firebaseRemoteConfig: firebaseRemoteConfig,
      );

      SystemUiOverlayTheme.setPortraitOrientation();

      runApp(
        TranslationProvider(
          child: await builder(
            powerSyncRepository,
            firebaseRemoteConfigRepository,
            firebaseMessaging,
            sharedPreferences,
          ),
        ),
      );
    },
    (error, stack) {
      logE(error.toString(), stackTrace: stack);
    },
  );
}
