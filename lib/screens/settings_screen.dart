import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'license_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _braveApiController = TextEditingController();
  final TextEditingController _groqApiController = TextEditingController();
  bool _isIncognitoMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _braveApiController.text = prefs.getString('braveApiKey') ?? '';
      _groqApiController.text = prefs.getString('groqApiKey') ?? '';
      _isIncognitoMode = prefs.getBool('incognitoMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('braveApiKey', _braveApiController.text);
    await prefs.setString('groqApiKey', _groqApiController.text);
    await prefs.setBool('incognitoMode', _isIncognitoMode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully')),
    );
  }

  Widget _buildApiKeyInput(
      String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Settings',
            style:
                TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Keys',
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildApiKeyInput('Brave Search API Key', _braveApiController,
                Iconsax.search_normal),
            _buildApiKeyInput('Groq API Key', _groqApiController, Iconsax.code),
            SizedBox(height: 24),
            Text(
              'Privacy',
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title:
                  Text('Incognito Mode', style: TextStyle(color: Colors.white)),
              subtitle: Text('Disable search history',
                  style: TextStyle(color: Colors.white70)),
              value: _isIncognitoMode,
              onChanged: (value) {
                setState(() {
                  _isIncognitoMode = value;
                });
              },
              activeColor: Colors.blue,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .grey[800], // Changed from Colors.blue to a greyish color
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'About',
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Iconsax.info_circle, color: Colors.white70),
              title: Text('Version', style: TextStyle(color: Colors.white)),
              subtitle: Text('1.0.0', style: TextStyle(color: Colors.white70)),
            ),
            ListTile(
              leading: Icon(Iconsax.document, color: Colors.white70),
              title: Text('License', style: TextStyle(color: Colors.white)),
              subtitle: Text('Custom License',
                  style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LicenseScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Iconsax.code, color: Colors.white70),
              title: Text('Source Code', style: TextStyle(color: Colors.white)),
              subtitle: Text('GitHub', style: TextStyle(color: Colors.white70)),
              onTap: () =>
                  _launchURL('https://github.com/TheGuyDangerous/Freelexity'),
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Created with ❣️ by Sannidhya Dubey',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
