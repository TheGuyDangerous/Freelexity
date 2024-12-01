import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final bool isDarkMode;

  const LoadingShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainer;
    final highlightColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface;

    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourcesShimmer(theme),
            _buildSummaryShimmer(theme),
            ...List.generate(5, (_) => _buildResultShimmer(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcesShimmer(ThemeData theme) {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            width: 100,
            height: 30,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryShimmer(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            color: theme.colorScheme.surface,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 100,
            color: theme.colorScheme.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildResultShimmer(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: theme.colorScheme.surface,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            color: theme.colorScheme.surface,
          ),
          SizedBox(height: 8),
          Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
