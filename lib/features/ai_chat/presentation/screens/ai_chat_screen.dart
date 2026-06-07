import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/message_role.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';
import 'package:shopkeeper/features/ai_chat/presentation/providers/chat_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadHistory().then((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _messageController.clear();
    _focusNode.requestFocus();
    await context.read<ChatProvider>().sendMessage(trimmed);
    _scrollToBottom();
  }

  void _confirmClear() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.startNewChat, style: AppTextStyles.headingM),
        content: Text(
          l10n.deleteConversation,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: AppTextStyles.labelL
                    .copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().clearHistory();
            },
            child: Text(l10n.clear, style: AppTextStyles.labelL),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(onClear: _confirmClear, l10n: l10n),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (provider.messages.isNotEmpty) _scrollToBottom();
                });

                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.ownerPrimary),
                  );
                }

                if (provider.errorMessage != null) {
                  return _ErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.loadHistory(),
                    l10n: l10n,
                  );
                }

                if (provider.messages.isEmpty) {
                  return _EmptyState(
                    l10n: l10n,
                    onSuggestion: (s) => _send(s),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount:
                      provider.messages.length + (provider.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: provider.messages[index]);
                  },
                );
              },
            ),
          ),
          _InputBar(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _send,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClear;
  final AppLocalizations l10n;
  const _Header({required this.onClear, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(4, top + 4, 8, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ownerPrimary, AppColors.ownerPrimaryDark],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: l10n.back,
          ),
          const SizedBox(width: 4),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shopkeeperAI,
                  style: AppTextStyles.headingM
                      .copyWith(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF69F0AE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l10n.poweredByGroq,
                      style: AppTextStyles.labelM.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 22),
            tooltip: l10n.clearChat,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueChanged<String> onSuggestion;
  const _EmptyState({required this.l10n, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      ('📊', l10n.aiSuggestion1),
      ('⚠️', l10n.aiSuggestion2),
      ('💰', l10n.aiSuggestion3),
      ('📈', l10n.aiSuggestion4),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.howCanIHelp,
            style:
                AppTextStyles.displayS.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.askAboutSales,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.suggested,
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => _SuggestionTile(
              emoji: s.$1,
              label: s.$2,
              onTap: () => onSuggestion(s.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _SuggestionTile(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textPrimary)),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: isUser
                ? _UserBubble(message: message)
                : _AiBubble(message: message),
          ),
          if (isUser) const SizedBox(width: 8 + 28 + 8),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.ownerPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Text(message.text,
              style: AppTextStyles.bodyM.copyWith(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(_fmt(message.timestamp),
            style: AppTextStyles.labelS.copyWith(color: AppColors.textHint)),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  final ChatMessage message;
  const _AiBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(message.text,
              style: AppTextStyles.bodyM
                  .copyWith(color: AppColors.textPrimary, height: 1.5)),
        ),
        const SizedBox(height: 4),
        Text(_fmt(message.timestamp),
            style: AppTextStyles.labelS.copyWith(color: AppColors.textHint)),
      ],
    );
  }
}

String _fmt(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child:
            Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.accent),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDot(delay: Duration.zero),
                SizedBox(width: 4),
                _BouncingDot(delay: Duration(milliseconds: 150)),
                SizedBox(width: 4),
                _BouncingDot(delay: Duration(milliseconds: 300)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: -6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(String) onSend;
  final AppLocalizations l10n;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isSending = context.select<ChatProvider, bool>((p) => p.isSending);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isSending,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: onSend,
                style:
                    AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.askAnything,
                  hintStyle:
                      AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SendButton(
              isSending: isSending, onTap: () => onSend(controller.text)),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onTap;
  const _SendButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isSending ? AppColors.border : AppColors.ownerPrimary,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: isSending ? null : onTap,
          child: Center(
            child: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  const _ErrorState(
      {required this.message, required this.onRetry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.wifi_off_rounded,
                    color: AppColors.danger, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.somethingWentWrong, style: AppTextStyles.headingM),
            const SizedBox(height: 6),
            Text(message,
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ownerPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.tryAgain, style: AppTextStyles.labelL),
            ),
          ],
        ),
      ),
    );
  }
}
