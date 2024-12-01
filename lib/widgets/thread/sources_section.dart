import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class SourcesSection extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;

  const SourcesSection({super.key, required this.searchResults});

  @override
  State<SourcesSection> createState() => SourcesSectionState();
}

class SourcesSectionState extends State<SourcesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _isExpanded ? null : 80,
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.document,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sources',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildFaviconStack(theme),
                      SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              SizedBox(
                height: 80,
                child: ScrollConfiguration(
                  behavior: BouncyScrollBehavior(),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.searchResults.length,
                    itemBuilder: (context, index) {
                      final result = widget.searchResults[index];
                      final isLastItem =
                          index == widget.searchResults.length - 1;
                      return GestureDetector(
                        onTap: () => _showSourceDetails(context, result),
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 16 : 8,
                            right: isLastItem ? 10 : 2,
                            bottom: 16,
                          ),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildFavicon(result['url'], theme),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      result['title'] ?? '',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      Uri.parse(result['url'] ?? '').host,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavicon(String? url, ThemeData theme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          'https://www.google.com/s2/favicons?domain=${Uri.parse(url ?? '').host}&sz=64',
          width: 16,
          height: 16,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.public,
                size: 16, color: theme.colorScheme.onSurface);
          },
        ),
      ),
    );
  }

  Widget _buildFaviconStack(ThemeData theme) {
    List<Widget> favicons = [];
    for (int i = 0; i < widget.searchResults.length && i < 2; i++) {
      favicons.add(
        Positioned(
          left: i * 15.0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://www.google.com/s2/favicons?domain=${Uri.parse(widget.searchResults[i]['url'] ?? '').host}&sz=64',
                width: 16,
                height: 16,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.public,
                      size: 16, color: theme.colorScheme.onSurface);
                },
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 40,
      height: 24,
      child: Stack(children: favicons),
    );
  }

  void _showSourceDetails(BuildContext context, Map<String, dynamic> result) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: _buildPanel(context, result),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, Map<String, dynamic> result) {
    final theme = Theme.of(context);
    String cleanTitle = _cleanText(result['title'] ?? 'No Title');
    String cleanContent = _cleanText(result['scrapedContent'] ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildFavicon(result['url'], theme),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cleanTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                Uri.parse(result['url'] ?? '').host,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 16),
              Text(
                cleanContent,
                style: theme.textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () async {
                  final url = Uri.parse(result['url'] ?? '');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text('Visit Website'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .trim();
  }
}

class BouncyScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics();
  }
}
