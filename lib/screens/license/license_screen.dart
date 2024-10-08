import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('License', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Iconsax.document,
                size: 48, color: isDarkMode ? Colors.white : Colors.black),
            SizedBox(height: 16),
            Text(
              '${AppConstants.appName} License',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Copyright (c) ${DateTime.now().year} Sannidhya Dubey',
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
            SizedBox(height: 24),
            Text(
              'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use the Software for personal, non-commercial purposes only, subject to the following conditions:',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            ),
            SizedBox(height: 16),
            _buildLicensePoint(context,
                '1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.'),
            _buildLicensePoint(context,
                '2. Commercial use of the Software is strictly prohibited without obtaining a separate commercial license from the copyright holder.'),
            _buildLicensePoint(context,
                '3. Redistribution of the Software is allowed only if it is for non-commercial purposes and includes this license and copyright notice.'),
            SizedBox(height: 24),
            Text(
              'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
            SizedBox(height: 24),
            Text(
              'For commercial licensing options, please contact:',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              AppConstants.contactEmail,
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensePoint(BuildContext context, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.tick_square,
              size: 16, color: isDarkMode ? Colors.white70 : Colors.black54),
          SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87)),
          ),
        ],
      ),
    );
  }
}
