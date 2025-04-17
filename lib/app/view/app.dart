// ignore_for_file: comment_references

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/app.dart';
import 'package:flutter_instagram_clone/feed/bloc/feed_bloc.dart';
import 'package:flutter_instagram_clone/selector/selector.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

/// Key to access the [AppSnackBarState] from the BuildContext
final snackBarKey = GlobalKey<AppSnackbarState>();

// Key to access the [AppLoadingIndeterminateState] from the [BuildContext]
final loadingIndeterminateKey = GlobalKey<AppLoadingIndeterminateState>();

//-----------------------------------------------------------------------------------//
class App extends StatelessWidget {
  const App({
    required this.firebaseRemoteConfigRepository,
    required this.userRepository,
    required this.postsRepository,
    required this.searchRepository,
    required this.chatsRepository,
    required this.notificationsRepository,
    required this.storiesRepository,
    required this.user,
    super.key,
  });

  final User user;
  final UserRepository userRepository;
  final StoriesRepository storiesRepository;
  final PostsRepository postsRepository;
  final ChatsRepository chatsRepository;
  final SearchRepository searchRepository;
  final NotificationsRepository notificationsRepository;
  final FirebaseRemoteConfigRepository firebaseRemoteConfigRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: storiesRepository),
        RepositoryProvider.value(value: postsRepository),
        RepositoryProvider.value(value: searchRepository),
        RepositoryProvider.value(value: notificationsRepository),
        RepositoryProvider.value(value: chatsRepository),
        RepositoryProvider.value(value: firebaseRemoteConfigRepository)
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              user: user, 
              userRepository: userRepository,
              notificationsRepository: notificationsRepository
            ),
          ),
          BlocProvider(create: (_) => LocaleBloc()),
          BlocProvider(create: (_) => ThemeModeBloc()),
          BlocProvider(
            create: (context) =>
              FeedBloc(
                postsRepository: context.read<PostsRepository>(), 
                firebaseRemoteConfigRepository: context.read<FirebaseRemoteConfigRepository>()
            )
          )
        ],
        child: const AppView(),
      ),
    );
  }
}

//-----------------------------------------------------------------------------------//c

void toggleLoadingIndeterminate({bool enable = true, bool autoHide = false}) =>
    loadingIndeterminateKey.currentState
      ?.setVisibility(visible: enable, autoHide: autoHide);

/// Snack bar to show messages to the user
void openSnackBar(
  SnackbarMessage message, {
  bool clearIfQueue = false,
  bool undismissable = false,
}) {
  snackBarKey.currentState
      ?.post(message, clearIfQueue: clearIfQueue, undismissable: undismissable);
}

/// Close all snack bars
void closeSnackbars() => snackBarKey.currentState?.closeAll();
