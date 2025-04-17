import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/feed/bloc/feed_bloc.dart';
import 'package:flutter_instagram_clone/feed/post/view/post_view.dart';
import 'package:flutter_instagram_clone/feed/widgets/widgets.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:flutter_instagram_clone/network_error/view/network_error.dart';
import 'package:flutter_instagram_clone/stories/stories.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>()
      )..add(const StoriesFetchUserFollowingsStories()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late ScrollController _nestedScrollController;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedPageRequested(page: 0));
    // to initialize "_context variable by context" in FeedPageController:
    _nestedScrollController = ScrollController();
    FeedPageController().init(
        nestedScrollController: _nestedScrollController, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: NestedScrollView(
            controller: _nestedScrollController,
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: FeedAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
                )
              ];
            },
            body: const FeedBody()));
  }
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final feedPageController = FeedPageController();

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await Future.wait([
          Future.microtask(
            () => context.read<FeedBloc>().add(const FeedRefreshRequested())),
          Future.microtask(
            () => context.read<StoriesBloc>().add(
              const StoriesFetchUserFollowingsStories())
            ),
        ]);
        feedPageController.markAnimationAsUnseen();
    },
      child: InViewNotifierCustomScrollView(
        initialInViewIds: const ['0'],
        isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
          return deltaTop < (0.5 * vpHeight) + 80.0 &&
              deltaBottom > (0.5 * vpHeight) - 80.0;
        },
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const StoriesCarousel(),
          const AppSliverDivider(),
          BlocBuilder<FeedBloc, FeedState>(
            // optimize re-build feature
            buildWhen: (prev, curr) {
              if (prev.status == FeedStatus.populated &&
                  const ListEquality<InstaBlock>().equals(
                      prev.feed.feedPage.blocks, curr.feed.feedPage.blocks)) {
                return false;
              }
              if (prev.status == curr.status) return false;
              return true;
            },
            // this will ensure if the states aren't same => then re-build:
            builder: (context, state) {
              final feedPage = state.feed.feedPage;
              final hasMorePosts = feedPage.hasMore;
              final isFailure = state.status == FeedStatus.failure;

              return SliverList.builder(
                  itemCount: state.feed.feedPage.totalBlocks,
                  itemBuilder: (context, index) {
                    final block = feedPage.blocks[index];
                    return _buildBlock(
                        context: context,
                        index: index,
                        feedLength: feedPage.totalBlocks,
                        block: block,
                        feedPageController: feedPageController,
                        hasMorePosts: hasMorePosts,
                        isFailure: isFailure);
                  });
            },
          )
        ],
      ),
    );
  }

  //--------------------------------------------------------------------//
  Widget _buildBlock({
    required BuildContext context,
    required int index,
    required int feedLength,
    required InstaBlock block,
    required FeedPageController feedPageController,
    required bool hasMorePosts,
    required bool isFailure,
  }) {
    if (block is DividerHorizontalBlock) {
      return DividerBlock(feedPageController: feedPageController);
    }
    if (block is SectionHeaderBlock) {
      return switch (block.sectionType) {
        SectionHeaderBlockType.suggested => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  context.l10n.suggestedForYouText,
                  style: context.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppDivider(),
            ],
          ),
      };
    }
    if (index + 1 == feedLength) {
      if (isFailure) {
        if (!hasMorePosts) return const SizedBox.shrink();
        return NetworkError(
          onRetry: () {
            context.read<FeedBloc>().add(const FeedPageRequested());
          },
        );
      } else {
        return Padding(
          padding: EdgeInsets.only(top: feedLength == 0 ? AppSpacing.md : 0),
          child: FeedLoaderItem(
            key: ValueKey(index),
            onPresented: () => hasMorePosts
                ? context.read<FeedBloc>().add(const FeedPageRequested())
                : context
                    .read<FeedBloc>()
                    .add(const FeedRecommendedPostsPageRequested()),
          ),
        );
      }
    }
    if (block is PostBlock) {
      return PostView(
        key: ValueKey(block.id),
        block: block,
        postIndex: index,
        withInViewNotifier: block.isReel,
      );
    }

    return Text('Unknown block type: ${block.type}');
  }
}
