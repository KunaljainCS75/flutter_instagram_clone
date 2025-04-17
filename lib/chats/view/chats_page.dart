// ignore_for_file: deprecated_member_use

import 'package:app_ui/app_ui.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_clone/app/bloc/app_bloc.dart';
import 'package:flutter_instagram_clone/chats/chats.dart';
import 'package:flutter_instagram_clone/home/provider/home_provider.dart';
import 'package:flutter_instagram_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

// ✅ BlocProvider creates and provides the ChatsBloc.
// ✅ It ensures ChatsBloc is available inside ChatsView.
// ✅ It immediately dispatches ChatsSubscriptionRequested to start fetching chats.
// ✅ Inside ChatsView, BlocBuilder (if used) listens to state changes and rebuilds UI dynamically.

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return BlocProvider(
      create: (context) =>
          ChatsBloc(chatsRepository: context.read<ChatsRepository>())
            ..add(ChatsSubscriptionRequested(userId: user.id)),
      child: const ChatsView(),
    );
  }
}

class ChatsView extends StatelessWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: CustomScrollView(
        slivers: [
          ChatsAppBar(),
          ChatsListView(),
        ],
      ),
    );
  }
}

class ChatsAppBar extends StatelessWidget {
  const ChatsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return SliverAppBar(
      leading: IconButton(
        onPressed: () => HomeProvider().animateToPage(1),
        icon: Icon(
          Icons.adaptive.arrow_back,
          size: AppSize.iconSizeMedium,
        ),
      ),
      centerTitle: false,
      pinned: true,
      title: Text(
        user.displayUsername,
        style: context.titleLarge?.copyWith(fontWeight: AppFontWeight.bold),
      ),
      actions: [
        Tappable.faded(
          onTap: () async {
            void createChat(String participantId) =>
                context.read<ChatsBloc>().add(
                      ChatsCreateChatRequested(
                        userId: user.id,
                        participantId: participantId,
                      ),
                    );

            final participantId = await context.push('/timeline/search', extra: true) as String?;
            if (participantId == null) return;
            createChat(participantId);
          },
          child: const Icon(Icons.add, size: AppSize.iconSize),
        ),
      ],
    );
  }
}

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = context.select((ChatsBloc bloc) => bloc.state.chats);
    if (chats.isEmpty) return const ChatsEmpty();
    return SliverList.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatInboxTile(chat: chat);
      },
    );
  }
}

class ChatsEmpty extends StatelessWidget {
  const ChatsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.flip(
                flipX: true,
                child: Assets.icons.chatCircle.svg(
                  height: 86,
                  width: 86,
                  colorFilter: ColorFilter.mode(
                    context.adaptiveColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Text(
                context.l10n.noChatsText,
                style: context.headlineLarge
                    ?.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
              AppButton(
                text: context.l10n.startChatText,
                onPressed: () async {
                  final participantId = await context.push(
                    '/timeline/search',
                    extra: true,
                  ) as String?;
                  if (participantId == null) return;
                  void createChat() => context.read<ChatsBloc>().add(
                        ChatsCreateChatRequested(
                          userId: user.id,
                          participantId: participantId,
                        ),
                      );
                  createChat();
                },
              ),
            ].spacerBetween(height: AppSpacing.sm),
          ),
        ),
      ),
    );
  }
}
