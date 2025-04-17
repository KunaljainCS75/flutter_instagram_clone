import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/feed/post/video/video.dart';
import 'package:flutter_instagram_clone/feed/widgets/feed_page_controller.dart';
import 'package:flutter_instagram_clone/home/provider/home_provider.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key, 
    required this.navigationShell
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final videoPlayer = VideoPlayerInheritedWidget.of(context);
    final navigationBarItems = mainNavigationBarItems(
      homeLabel: l10n.homeNavBarItemLabel, 
      searchLabel: l10n.searchNavBarItemLabel, 
      createMediaLabel: l10n.createMediaNavBarItemLabel, 
      reelsLabel: l10n.reelsNavBarItemLabel, 
      userProfileLabel: l10n.profileNavBarItemLabel, 
      userProfileAvatar: const Icon(Icons.person)
    );
    return  BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
       onTap: (index) {
        HomeProvider().togglePageView(enable: index == 0);
        if ([0, 1, 2, 3].contains(index)) {
          if (index case 0) videoPlayer.videoPlayerState.playFeed();
          if (index case 1) videoPlayer.videoPlayerState.playTimeline();
          if (index case 2) {
            HomeProvider().animateToPage(0);
            HomeProvider().togglePageView();
          }
          if (index case 3) videoPlayer.videoPlayerState.playReels();
        } else {
          videoPlayer.videoPlayerState.stopAll();
        }
        if (index != 2) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        }
        if (index == 0) {
          if (!(index == navigationShell.currentIndex)) return;
          FeedPageController().scrollToTop();
        }
      },
      iconSize: AppSpacing.lg * 1.75,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      enableFeedback: true,
      items: navigationBarItems
        .map(
          (e) => BottomNavigationBarItem(
            icon: e.child ?? Icon(e.icon),
            tooltip: e.tooltip,
            label: e.label
          )
      ).toList()
    );
  }
}