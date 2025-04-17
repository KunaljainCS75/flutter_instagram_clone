import 'package:flutter/material.dart';

class VideoPlayerState {
  VideoPlayerState();

  final enablePageView = ValueNotifier(true);
  final shouldPlayFeed = ValueNotifier(true);
  final shouldPlayReels = ValueNotifier(true);
  final shouldPlayTimeline = ValueNotifier(true);
  final withSound = ValueNotifier(false);

  // ignore: use_setters_to_change_properties
  void togglePageView({bool enable = true}) {
    enablePageView.value = enable;
  }

  void playFeed() {
    shouldPlayFeed.value = true;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }

  void playTimeline() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = true;
  }

  void playReels() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = true;
    shouldPlayTimeline.value = false;
  }

  void stopAll() {
    shouldPlayFeed.value = false;
    shouldPlayReels.value = false;
    shouldPlayTimeline.value = false;
  }
}
// Here’s a summarized explanation of the `VideoPlayerInheritedWidget` in points:

// 1. **Purpose of `InheritedWidget`**:
//    - It allows sharing data (`videoPlayerState`) efficiently down 
//      the widget tree without passing it explicitly to every widget.

// 2. **Constructor**:
//    - Takes two arguments:
//      - `videoPlayerState`: The state (likely related to the video player) to be shared.
//      - `child`: The subtree of widgets that need access to the shared state.

// 3. **`videoPlayerState` Field**:
//    - Holds the state object that is being passed to child widgets.

// 4. **`updateShouldNotify`**:
//    - Compares the current `videoPlayerState` with the old one (`oldWidget.videoPlayerState`).
//    - Returns `true` if the state has changed, triggering a rebuild of dependent widgets.

// 5. **`of` Method**:
//    - Static helper method to retrieve the nearest `VideoPlayerInheritedWidget` 
//      from the widget tree.
//    - Uses `context.getInheritedWidgetOfExactType` to find the widget.
//    - Asserts that the widget exists, and throws an error if it isn’t found, 
//      with the message "No VideoPlayerState found in context!"

// 6. **`maybeOf` Method**:
//    - Similar to `of`, but instead of asserting, it returns `null` 
//      if the widget isn’t found.
//    - Provides a safer way to access the widget when it may not always be present.

// 7. **Widget Subtree**:
//    - The `child` subtree wrapped by `VideoPlayerInheritedWidget` 
//      can access `videoPlayerState` using `of` or `maybeOf`.

class VideoPlayerInheritedWidget extends InheritedWidget {
  const VideoPlayerInheritedWidget({
    required this.videoPlayerState,
    required super.child,
    super.key,
  });

  final VideoPlayerState videoPlayerState;

  @override
  bool updateShouldNotify(VideoPlayerInheritedWidget oldWidget) =>
      videoPlayerState != oldWidget.videoPlayerState;

  static VideoPlayerInheritedWidget of(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<VideoPlayerInheritedWidget>();
    assert(provider != null, 'No VideoPlayerState found in context!');
    return provider!;
  }

  static VideoPlayerInheritedWidget? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<VideoPlayerInheritedWidget>();
}
