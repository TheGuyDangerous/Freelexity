import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';

class SourcesSection extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;

  const SourcesSection({super.key, required this.searchResults});

  @override
  _SourcesSectionState createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
          color: themeProvider.isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[300]!.withOpacity(0.5),
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
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sources',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildFaviconStack(),
                      SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
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
                        onTap: () =>
                            _showSourceDetails(context, result, themeProvider),
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 16 : 8,
                            right: isLastItem ? 10 : 2,
                            bottom: 16,
                          ),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildFavicon(result['url']),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      result['title'] ?? '',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      Uri.parse(result['url'] ?? '').host,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 12,
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

  Widget _buildFavicon(String? url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipOval(
        child: Image.network(
          'https://www.google.com/s2/favicons?domain=${Uri.parse(url ?? '').host}&sz=64',
          width: 16,
          height: 16,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.public, size: 16);
          },
        ),
      ),
    );
  }

  Widget _buildFaviconStack() {
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
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: ClipOval(
              child: Image.network(
                'https://www.google.com/s2/favicons?domain=${Uri.parse(widget.searchResults[i]['url'] ?? '').host}&sz=64',
                width: 16,
                height: 16,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.public, size: 16);
                },
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 24,
      child: Stack(children: favicons),
    );
  }

  void _showSourceDetails(BuildContext context, Map<String, dynamic> result,
      ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: _buildPanel(context, result, themeProvider),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, Map<String, dynamic> result,
      ThemeProvider themeProvider) {
    // Clean up the title and content
    String cleanTitle = _cleanText(result['title'] ?? 'No Title');
    String cleanContent = _cleanText(result['scrapedContent'] ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            cleanTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: cleanContent.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      cleanContent,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'No info available',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _launchURL(result['url']),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[300],
              foregroundColor:
                  themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            child: Text('View Source'),
          ),
        ),
      ],
    );
  }

  String _cleanText(String text) {
    // Remove any non-printable characters and weird symbols
    String cleaned = text.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

    // Remove any extra whitespace
    cleaned = cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Decode HTML entities
    cleaned = _decodeHtmlEntities(cleaned);

    // If the text is empty after cleaning, return a default message
    return cleaned.isNotEmpty ? cleaned : 'No information available';
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Future<void> _launchURL(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch $url');
    }
  }
}

class BouncyScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics();
  }
}
