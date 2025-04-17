import 'package:api_repository/api_repository.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter_instagram_clone/app/di/di.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/bootstrap.dart';
import 'package:flutter_instagram_clone/firebase_options_dev.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  const apiRepository = ApiRepository();
  bootstrap((
      powerSyncRepository, 
      firebaseRemoteConfigRepository,
      firebaseMessaging,
      sharedPreferences
    ) async {
      final webClientId = getIt<AppFlavor>().getEnv(Env.webClientId);
      final iOSClientId = getIt<AppFlavor>().getEnv(Env.iOSClientId);
      final tokenStorage = InMemoryTokenStorage();
      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        // clientId: iOSClientId
      );

      final firebaseNotificationsClient = FirebaseNotificationsClient(
        firebaseMessaging: firebaseMessaging
      );

      final notificationsRepository = NotificationsRepository(
        notificationsClient: firebaseNotificationsClient
      );

      final supabaseAuthenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository, 
        tokenStorage: tokenStorage, 
        googleSignIn: googleSignIn
      );

      final powerSyncDatabaseClient = PowerSyncDatabaseClient(
        powerSyncRepository: powerSyncRepository
      );


      final persistentStorage = PersistentStorage(sharedPreferences: sharedPreferences);
      final storiesStorage = StoriesStorage(storage: persistentStorage);

      final userRepository = UserRepository(
        databaseClient: powerSyncDatabaseClient,
        authenticationClient: supabaseAuthenticationClient
      );
      final postsRepository = PostsRepository(databaseClient: powerSyncDatabaseClient);
      final chatsRepository = ChatsRepository(databaseClient: powerSyncDatabaseClient);
      final searchRepository = SearchRepository(databaseClient: powerSyncDatabaseClient);
      final storiesRepository = StoriesRepository(
        storage: storiesStorage,
        databaseClient: powerSyncDatabaseClient
      );
      
      return App(
        userRepository: userRepository,
        postsRepository: postsRepository, 
        searchRepository: searchRepository,
        storiesRepository: storiesRepository,
        chatsRepository: chatsRepository,
        notificationsRepository: notificationsRepository,
        firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
        user: await userRepository.user.first
      );
    }, 
    options: DefaultFirebaseOptions.currentPlatform,
    appFlavor: AppFlavor.development(),
  );
}
