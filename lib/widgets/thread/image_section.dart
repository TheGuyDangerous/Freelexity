import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import 'full_screen_image.dart';

class ImageSection extends StatelessWidget {
  final List<Map<String, String?>> images; // Change the type here

  const ImageSection({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (images.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: images.isNotEmpty
                    ? _buildTappableImage(context, images[0], themeProvider)
                    : _buildPlaceholder(themeProvider),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: EdgeInsets.only(left: 8, right: 16),
              children: images.length > 1
                  ? images.sublist(1).map((imageData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildTappableImage(
                            context, imageData, themeProvider),
                      );
                    }).toList()
                  : List.generate(
                      4, (index) => _buildPlaceholder(themeProvider)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableImage(BuildContext context,
      Map<String, String?> imageData, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _openFullScreenImage(context, imageData),
      child: Hero(
        tag: imageData['url'] ?? '',
        child: Image.network(
          imageData['url'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return _buildPlaceholder(themeProvider);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeProvider themeProvider) {
    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Icon(Iconsax.image,
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            size: 40),
      ),
    );
  }

  void _openFullScreenImage(
      BuildContext context, Map<String, String?> imageData) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImage(
            imageUrl: imageData['url'] ?? '',
            websiteName: imageData['websiteName'] ?? 'Unknown',
            favicon: imageData['favicon'],
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
