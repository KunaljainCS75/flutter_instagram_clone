import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/app.dart';
import 'package:flutter_instagram_clone/app/routes/app_routes.dart';
import 'package:flutter_instagram_clone/auth/auth.dart';
import 'package:flutter_instagram_clone/chats/chat/chat.dart';
import 'package:flutter_instagram_clone/feed/feed.dart';
import 'package:flutter_instagram_clone/feed/post/post.dart';
import 'package:flutter_instagram_clone/home/home.dart';
import 'package:flutter_instagram_clone/reels/view/reels_view.dart';
import 'package:flutter_instagram_clone/search/view/search_page.dart';
import 'package:flutter_instagram_clone/stories/bloc/create_stories_bloc.dart';
import 'package:flutter_instagram_clone/stories/view/stories_page.dart';
import 'package:flutter_instagram_clone/stories/widgets/stories_props.dart';
import 'package:flutter_instagram_clone/timeline/timeline.dart';
import 'package:flutter_instagram_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart' hide FeedPage;
import 'package:stories_editor/stories_editor.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
// This is a global navigator key used to control the root navigator.
// It ensures that some routes (like modals or full-screen pages) are pushed over 
// the entire navigation structure rather than being nested inside a specific section.
GoRouter router(AppBloc appBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(
        path: AppRoutes.userProfile.path!,
        name: AppRoutes.userProfile.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['user_id']!;
          // if we want to pass something in extra when doing steps like
          // context.pushNamed(...route_name..., extra<datatype>)
          // then dataType can be defined below as:
          final props = state.extra as UserProfileProps?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => CreateStoriesBloc(
                storiesRepository: context.read<StoriesRepository>(),
                firebaseRemoteConfigRepository: context.read<FirebaseRemoteConfigRepository>()
              ),
              child: UserProfilePage(
                userId: userId,
                props: props ?? const UserProfileProps.build(),
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: AppRoutes.postEdit.path!,
        name: AppRoutes.postEdit.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra! as PostBlock;

          return NoTransitionPage(child: PostEditPage(post: post));
        },
      ),
      GoRoute(
        path: AppRoutes.chat.path!,
        name: AppRoutes.chat.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['chat_id']!;
          final props = state.extra! as ChatProps;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatPage(chatId: chatId, chat: props.chat),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.post.path!,
        name: AppRoutes.post.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          logI(100);

          return CustomTransitionPage(
            key: state.pageKey,
            child: PostPreviewPage(id: id ?? ''),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.stories.path!,
        name: AppRoutes.stories.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final props = state.extra! as StoriesProps;
          logI(props.stories.length + 100);
          return CustomTransitionPage(
            key: state.pageKey,
            child: StoriesPage(props: props),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.scaled,
                child: child,
              );
            },
          );
        },
      ),
// 🔹 StatefulShellRoute.indexedStack keeps state while switching between pages.
// 🔹 StatefulShellBranch groups related routes into separate sections (like tabs).

// The navigationShell is the stateful container that manages the switching 
// between different branches (e.g., Feed, Reels, Search).
// When navigating between branches, Flutter keeps their state alive, preventing reloading.
      StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/feed',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                        child: const FeedPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        });
                  }),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.timeline.route,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                      child: const TimelinePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: CurveTween(curve: Curves.easeInOut)
                              .animate(animation),
                          child: child,
                        );
                      });
                },
                routes: [
                  GoRoute(
                    name: AppRoutes.search.name,
                    path: AppRoutes.search.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final withResult = state.extra as bool?;

                      return NoTransitionPage(
                        key: state.pageKey,
                        child: SearchPage(withResult: withResult),
                      );
                    },
                  ),
                ],
              )
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.createMedia.route,
                  redirect: (context, state) => null)
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/reels',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                        child: const ReelsView(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurveTween(curve: Curves.easeInOut)
                                .animate(animation),
                            child: child,
                          );
                        });
                  })
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.user.route,
                pageBuilder: (context, state) {
                  final user =
                      context.select((AppBloc bloc) => bloc.state.user);
                  final props = state.extra as UserProfileProps?;
                  return CustomTransitionPage(
                      child: UserProfilePage(
                        userId: user.id,
                        props: props ?? const UserProfileProps.build(),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      });
                },
                routes: [
                  GoRoute(
                    path: AppRoutes.createPost.name,
                    name: AppRoutes.createPost.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final pickVideo = state.extra as bool? ?? false;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: UserProfileCreatePost(
                          pickVideo: pickVideo,
                          wantKeepAlive: false,
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        name: AppRoutes.publishPost.name,
                        path: AppRoutes.publishPost.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final props = state.extra! as CreatePostProps;

                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: CreatePostPage(props: props),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: AppRoutes.createStories.name,
                    name: AppRoutes.createStories.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final onDone = state.extra as dynamic Function(String)?;
                      // Inside StoriesEditor, when the user selects a file or completes editing,
                      // it calls the onDone callback with the file path (e.g., selectedFilePath).
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: StoriesEditor(
                          onDone: onDone,
                          storiesEditorLocalizationDelegate:
                              storiesEditorLocalizationDelegate(context),
                          galleryThumbnailQuality: 900,
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.scaled,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.editProfile.name,
                    name: AppRoutes.editProfile.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const UserProfileEdit(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.editProfileInfo.path!,
                        name: AppRoutes.editProfileInfo.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final query = state.uri.queryParameters;
                          final label = state.pathParameters['label']!;
                          final appBarTitle = query['title']!;
                          final description = query['description'];
                          final infoValue = query['value'];
                          final infoType = state.extra as ProfileEditInfoType?;

                          return MaterialPage<void>(
                            fullscreenDialog: true,
                            child: ProfileInfoEditPage(
                              appBarTitle: appBarTitle,
                              description: description,
                              infoValue: infoValue,
                              infoLabel: label,
                              infoType: infoType!,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: AppRoutes.userStatistics.name,
                    name: AppRoutes.userStatistics.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id']!;
                      final tabIndex = state.extra! as int;

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => UserProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          )
                            ..add(const UserProfileSubscriptionRequested())
                            ..add(
                              const UserProfileFollowingsCountSubscriptionRequested(),
                            )
                            ..add(
                              const UserProfileFollowersCountSubscriptionRequested(),
                            ),
                          child: UserProfileStatistics(tabIndex: tabIndex),
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.userPosts.name,
                    name: AppRoutes.userPosts.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final userId = state.uri.queryParameters['user_id']!;
                      final index =
                          (state.uri.queryParameters['index']!).parse.toInt();

                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: BlocProvider(
                          create: (context) => UserProfileBloc(
                            userId: userId,
                            userRepository: context.read<UserRepository>(),
                            postsRepository: context.read<PostsRepository>(),
                          ),
                          child: UserProfilePosts(
                            userId: userId,
                            index: index,
                          ),
                        ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ]),
          ])
    ],
    redirect: (context, state) {
      final authenticated = appBloc.state.status == AppStatus.authenticated;
      final authenticating = state.matchedLocation == '/auth';
      final isInFeed = state.matchedLocation == '/feed';

      if (isInFeed && !authenticated) return '/auth';
      if (!authenticated) return '/auth';
      if (authenticating && authenticated) return '/feed';

      return null;
    },
    refreshListenable: GoRouterAppBlocRefreshStream(appBloc.stream),
  );
}

/// {@template go_router_refresh_stream}
/// A [ChangeNotifier] that notifies listeners when a [Stream] emits a value.
/// This is used to rebuild the UI when the [AppBloc] emits a new state.
/// {@endtemplate}
class GoRouterAppBlocRefreshStream extends ChangeNotifier {
  /// {@macro go_router_refresh_stream}
  GoRouterAppBlocRefreshStream(Stream<AppState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((appState) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
