import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/search_suggestion.dart';
import 'grid_background.dart';
import 'sparkle_logo.dart';
import '../../screens/thread/thread_loading_screen.dart';

class _InfiniteScrollRow extends StatefulWidget {
  final List<SearchSuggestion> suggestions;
  final bool scrollLeft; // Direction of scroll

  const _InfiniteScrollRow({
    required this.suggestions,
    this.scrollLeft = true,
  });

  @override
  State<_InfiniteScrollRow> createState() => _InfiniteScrollRowState();
}

class _InfiniteScrollRowState extends State<_InfiniteScrollRow> {
  late ScrollController _scrollController;
  late Timer _scrollTimer;
  final double _scrollSpeed = 1.0; // Pixels per frame

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startScrolling();
  }

  void _startScrolling() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_scrollController.hasClients) {
        final currentOffset = _scrollController.offset;
        final maxOffset = _scrollController.position.maxScrollExtent;

        double nextOffset;
        if (widget.scrollLeft) {
          nextOffset = currentOffset + _scrollSpeed;
          if (nextOffset >= maxOffset) {
            nextOffset = 0;
          }
        } else {
          nextOffset = currentOffset - _scrollSpeed;
          if (nextOffset <= 0) {
            nextOffset = maxOffset;
          }
        }

        _scrollController.jumpTo(nextOffset);
      }
    });
  }

  void _handleTap(SearchSuggestion suggestion) {
    // Pause scrolling while handling tap
    _scrollTimer.cancel();

    // Navigate to search
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ThreadLoadingScreen(query: suggestion.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // Resume scrolling after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.suggestions.length * 2,
      itemBuilder: (context, index) {
        final suggestion =
            widget.suggestions[index % widget.suggestions.length];
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 16 : 8,
            right: 8,
          ),
          child: _SuggestionChip(
            suggestion: suggestion,
            onTap: () => _handleTap(suggestion),
          ),
        );
      },
    );
  }
}

class SearchInitialView extends StatelessWidget {
  const SearchInitialView({super.key});

  List<SearchSuggestion> get _suggestions => const [
        // First Row
        SearchSuggestion(text: "What is love hormone?", emoji: "💝"),
        SearchSuggestion(text: "Who owns Antarctica?", emoji: "🌏"),
        SearchSuggestion(text: "Tallest building in world", emoji: "🏢"),
        SearchSuggestion(text: "How do planes fly?", emoji: "✈️"),
        SearchSuggestion(text: "Why is sky blue?", emoji: "🌤"),
        SearchSuggestion(text: "Deep ocean creatures", emoji: "🦑"),
        SearchSuggestion(text: "Space exploration history", emoji: "🚀"),
        SearchSuggestion(text: "How do rainbows form?", emoji: "🌈"),

        // Second Row
        SearchSuggestion(text: "How did pagers work?", emoji: "📟"),
        SearchSuggestion(text: "iPhone 16 rumors", emoji: "📱"),
        SearchSuggestion(text: "Ancient Egypt facts", emoji: "🔮"),
        SearchSuggestion(text: "How do bees make honey?", emoji: "🐝"),
        SearchSuggestion(text: "Volcanic eruptions", emoji: "🌋"),
        SearchSuggestion(text: "Northern lights explained", emoji: "✨"),
        SearchSuggestion(text: "How do vaccines work?", emoji: "💉"),
        SearchSuggestion(text: "World's fastest animals", emoji: "🐆"),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = _suggestions;
    final firstRowSuggestions = suggestions.sublist(0, 8);
    final secondRowSuggestions = suggestions.sublist(8);
    final thirdRowSuggestions = const [
      SearchSuggestion(text: "What's open source?", emoji: "🔓"),
    ];

    return Stack(
      children: [
        CustomPaint(
          painter: GridBackgroundPainter(
            color: theme.colorScheme.onSurface,
            opacity: 0.03,
            gridSize: 100,
            strokeWidth: 1.0,
          ),
          size: Size.infinite,
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SparkleLogo(
                        size: 64,
                        color: const Color(0xFF7EB6FF),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Where knowledge begins',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  height: 48,
                  child: _InfiniteScrollRow(
                    suggestions: firstRowSuggestions,
                    scrollLeft: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: _InfiniteScrollRow(
                    suggestions: secondRowSuggestions,
                    scrollLeft: false,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: Center(
                    child: _SuggestionChip(
                      suggestion: thirdRowSuggestions[0],
                      onTap: () {
                        // TODO: Handle suggestion tap
                      },
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final SearchSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                suggestion.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                suggestion.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
