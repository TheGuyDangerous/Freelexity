import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String websiteName;
  final String? favicon;

  const FullScreenImage({
    Key? key,
    required this.imageUrl,
    required this.websiteName,
    this.favicon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Hero(
            tag: imageUrl,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Iconsax.image),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Iconsax.close_square, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      if (favicon != null)
                        Image.network(
                          favicon!,
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox(width: 16),
                        ),
                      SizedBox(width: 8),
                      Text(
                        websiteName,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
