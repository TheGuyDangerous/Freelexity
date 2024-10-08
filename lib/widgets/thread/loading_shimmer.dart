import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final bool isDarkMode;

  const LoadingShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[900]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSourcesShimmer(),
            _buildSummaryShimmer(),
            ...List.generate(5, (_) => _buildResultShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcesShimmer() {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryShimmer() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildResultShimmer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Container(
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
