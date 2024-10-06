import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class ImageSection extends StatelessWidget {
  final List<String> images;

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
                    ? _buildImage(images[0], themeProvider)
                    : Container(
                        width: double.infinity,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        child: Center(
                          child: Icon(Iconsax.image,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              size: 40),
                        ),
                      ),
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
                  ? images.sublist(1).map((url) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(url, themeProvider),
                      );
                    }).toList()
                  : List.generate(4, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Iconsax.image,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      );
                    }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, ThemeProvider themeProvider) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Center(
            child: Icon(Iconsax.image,
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                size: 40),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
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
    );
  }
}
