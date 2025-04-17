import 'package:app_ui/app_ui.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/chats/chats.dart';
import 'package:flutter_instagram_clone/feed/post/post.dart';
import 'package:flutter_instagram_clone/home/home.dart';
import 'package:flutter_instagram_clone/navigation/view/bottom_nav_bar.dart';
import 'package:flutter_instagram_clone/stories/bloc/create_stories_bloc.dart';
import 'package:flutter_instagram_clone/user_profile/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:stories_repository/stories_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return HomeView(navigationShell: navigationShell);
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late VideoPlayerState _videoPlayerState;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1)
      ..addListener(_onPageScroll);
    _videoPlayerState = VideoPlayerState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeProvider().setPageController(_pageController);
    });
  }

  void _onPageScroll() {
    _pageController.position.isScrollingNotifier.addListener(_isPageScrolling);
  }

  void _isPageScrolling() {
    final isScrolling = _pageController.position.isScrollingNotifier.value == true;
    final mainPageView = _pageController.page == 1;
    final navigationBarIndex = widget.navigationShell.currentIndex;
    final isFeed = !isScrolling && mainPageView && navigationBarIndex == 0;
    final isTimeline = !isScrolling && mainPageView && navigationBarIndex == 1;
    final isReels = !isScrolling && mainPageView && navigationBarIndex == 3;

    if (isScrolling) {
      _videoPlayerState.stopAll();
    }
    switch ((isFeed, isTimeline, isReels)) {
      case (true, false, false):
        _videoPlayerState.playFeed();
      case (false, true, false):
        _videoPlayerState.playTimeline();
      case (false, false, true):
        _videoPlayerState.playReels();
      case _:
        _videoPlayerState.stopAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.navigationShell.currentIndex == 0 &&
        !HomeProvider().enablePageView) {
      // Use addPostFrameCallback as it:
      // Schedules a callback to execute after the current frame has finished rendering.
      // Ensures that UI changes or state updates don’t interfere
      // with the current frame rendering.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeProvider().togglePageView();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      create: (context) => CreateStoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        firebaseRemoteConfigRepository: context.read<FirebaseRemoteConfigRepository>(),
      )..add(const CreateStoriesIsFeatureAvailableSubscriptionRequested()),

      child: VideoPlayerInheritedWidget(
        videoPlayerState: _videoPlayerState,
        child: ListenableBuilder(
          listenable: HomeProvider(),
          builder: (context, child) {
            return PageView.builder(
              itemCount: 3,
              controller: _pageController,
              physics: HomeProvider().enablePageView
                  ? null
                  : const NeverScrollableScrollPhysics(),
              // onPageChanged: (page) {
              //   if (page != 0 && page != 2 && page == 1) {
              //     customImagePickerKey.currentState?.resetAll();
              //   }
              onPageChanged: (page) {
                if (page == 1 && widget.navigationShell.currentIndex != 0) {
                  HomeProvider().togglePageView(enable: false);
                }
              },
              itemBuilder: (context, index) {
                return switch (index) {
                  0 => UserProfileCreatePost(
                      canPop: false,
                      // imagePickerKey: customImagePickerKey,
                      onPopInvoked: () => HomeProvider().animateToPage(1),
                      onBackButtonTap: () => HomeProvider().animateToPage(1),
                    ),
                  2 => const ChatsPage(),
                  _ => AppScaffold(
                      body: widget.navigationShell,
                      bottomNavigationBar:
                          BottomNavBar(navigationShell: widget.navigationShell),
                    ),
                };
              },
            );
          },
        ),
      ),
    );
  }
}
