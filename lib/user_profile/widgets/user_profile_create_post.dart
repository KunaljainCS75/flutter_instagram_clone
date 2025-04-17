// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/app/routes/app_routes.dart';
import 'package:flutter_instagram_clone/app/view/app.dart';
import 'package:flutter_instagram_clone/feed/widgets/feed_page_controller.dart';
import 'package:flutter_instagram_clone/home/provider/home_provider.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class UserProfileCreatePost extends StatelessWidget {
  const UserProfileCreatePost({
    this.canPop = true,
    this.imagePickerKey,
    this.pickVideo = false,
    this.onPopInvoked,
    this.onBackButtonTap,
    super.key,
    this.wantKeepAlive = true,
  });

  final bool canPop;
  final Key? imagePickerKey;
  final bool pickVideo;
  final bool wantKeepAlive;
  final VoidCallback? onBackButtonTap;
  final VoidCallback? onPopInvoked;

  @override
  Widget build(BuildContext context) {
    final pickerSource = pickVideo ? PickerSource.video : PickerSource.both;
    return WillPopScope(
      onWillPop: () =>
          onPopInvoked == null ? Future.value(true) : Future.value(false),
      child: PickImage().customMediaPicker(
        key: imagePickerKey,
        context: context,
        source: ImageSource.both,
        pickerSource: pickerSource,
        multiSelection: !pickVideo,
        wantKeepAlive: wantKeepAlive,
        onMediaPicked: (details) => context.pushNamed(
          AppRoutes.publishPost.name,
          extra: CreatePostProps(details: details, pickVideo: pickVideo),
        ),
        onBackButtonTap:
            onBackButtonTap != null ? () => onBackButtonTap?.call() : null,
      ),
    );
  }
}

class CreatePostProps {
  const CreatePostProps({
    required this.details,
    this.pickVideo = false,
  });

  final SelectedImagesDetails details;
  final bool pickVideo;
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({required this.props, super.key});

  final CreatePostProps props;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _captionController;
  late List<Media> _media;

  List<SelectedByte> get selectedFiles => widget.props.details.selectedFiles;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    _media = selectedFiles
        .map(
          (e) => e.isThatImage
              ? MemoryImageMedia(bytes: e.selectedByte, id: uuid.v4())
              : MemoryVideoMedia(file: e.selectedFile, id: uuid.v4()),
        )
        .toList();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _onShareTap(String caption) async {
    void goHome() {
      if (!widget.props.pickVideo) {
        HomeProvider().animateToPage(1);
        FeedPageController().scrollToTop();
      }
    }
    try {
      toggleLoadingIndeterminate();
      final postId = uuid.v4();
      unawaited(
        FeedPageController().processPostMedia(
          postId: postId,
          selectedFiles: selectedFiles,
          caption: _captionController.text.trim(),
          pickVideo: widget.props.pickVideo,
        ),
      );
      goHome.call();
    } catch (error, stackTrace) {
      toggleLoadingIndeterminate(enable: false);
      logE('Failed to create post', error: error, stackTrace: stackTrace);
      openSnackBar(const SnackbarMessage.error(title: 'Failed to create post!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.l10n.newPostText),
      ),
      bottomNavigationBar: PublishPostButton(
        onShareTap: () => _onShareTap(_captionController.text.trim()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostMedia(
              media: _media,
              withLikeOverlay: false,
              withInViewNotifier: false,
              autoHideCurrentIndex: false,
              mediaCarouselSettings: const MediaCarouselSettings.empty(
                viewportFraction: .9,
              ),
            ),
            const Gap.v(AppSpacing.sm),
            CaptionInputField(
              captionController: _captionController,
              caption: _captionController.text.trim(),
              onSubmitted: _onShareTap,
            ),
          ],
        ),
      ),
    );
  }
}



class CaptionInputField extends StatefulWidget {
  const CaptionInputField({
    required this.captionController,
    required this.caption,
    required this.onSubmitted,
    super.key
  });

  final TextEditingController captionController;
  final String caption;
  final ValueSetter<String> onSubmitted;

  @override
  State<CaptionInputField> createState() => _CaptionInputFieldState();
}

class _CaptionInputFieldState extends State<CaptionInputField> {
  
  late String _initialCaption;

  @override
  void initState() {
    super.initState();
    _initialCaption = widget.caption;
  } 

  @override
  void didUpdateWidget(covariant CaptionInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caption != _initialCaption) {
      setState(() => _initialCaption = widget.caption);
    }
  }

  String _effectiveValue(String? value) => value ?? widget.captionController.text.trim();

  bool _equals(String? value) => _initialCaption == _effectiveValue(value);
  
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      border: InputBorder.none,
      textController: widget.captionController,
      contentPadding: EdgeInsets.zero,
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      hintText: context.l10n.writeCaptionText,
      onFieldSubmitted: (value) => 
          _equals(value) ? null : widget.onSubmitted(_effectiveValue(value))
    );
  }
}



class PublishPostButton extends StatelessWidget {
  const PublishPostButton({required this.onShareTap, super.key});

  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: context.reversedAdaptiveColor,
      padding: EdgeInsets.zero,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Tappable.faded(
              onTap: onShareTap,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Align(
                child: Text(
                  context.l10n.sharePostText,
                  style: context.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
