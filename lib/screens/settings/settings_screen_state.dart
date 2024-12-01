import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../license/license_screen.dart';
import '../../utils/constants.dart';
import '../../widgets/settings/api_key_input.dart';
import '../../widgets/settings/settings_switch.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/search_service.dart';
import '../../services/groq_api_service.dart';
import 'settings_screen.dart';

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _braveApiController = TextEditingController();
  final TextEditingController _groqApiController = TextEditingController();
  bool _isIncognitoMode = false;
  bool _useWhisperModel = false;
  bool _isBraveApiKeyValid = false;
  bool _isGroqApiKeyValid = false;
  bool _isValidating = false;

  final SearchService _searchService = SearchService();
  final GroqApiService _groqApiService = GroqApiService();

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
      _useWhisperModel = prefs.getBool('useWhisperModel') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('braveApiKey', _braveApiController.text);
    await prefs.setString('groqApiKey', _groqApiController.text);
    await prefs.setBool('incognitoMode', _isIncognitoMode);
    await prefs.setBool('useWhisperModel', _useWhisperModel);
  }

  void _showWhisperInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OpenAI Whisper Model'),
          content: Text(
              'The OpenAI Whisper model is a more advanced speech recognition system that can provide better accuracy, especially for non-English languages and accented speech. However, it requires an internet connection and may be slower than the device\'s built-in speech recognition.\n\n'
              'When enabled, the app will use the Whisper model through the Groq API for speech-to-text conversion instead of the device\'s built-in system.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _validateApiKeys() async {
    setState(() {
      _isValidating = true;
      _isBraveApiKeyValid = false;
      _isGroqApiKeyValid = false;
    });

    if (_braveApiController.text.isNotEmpty) {
      try {
        final isValid =
            await _searchService.validateBraveApiKey(_braveApiController.text);
        setState(() {
          _isBraveApiKeyValid = isValid;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error validating Brave API key: $e");
      }
    }

    if (_groqApiController.text.isNotEmpty) {
      try {
        final isValid =
            await _groqApiService.validateApiKey(_groqApiController.text);
        setState(() {
          _isGroqApiKeyValid = isValid;
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error validating Groq API key: $e");
      }
    }

    setState(() {
      _isValidating = false;
    });

    if (_isBraveApiKeyValid && _isGroqApiKeyValid) {
      await _saveSettings();
      Fluttertoast.showToast(
          msg: "API keys validated and settings saved successfully");
    } else {
      Fluttertoast.showToast(
          msg: "One or more API keys are invalid. Please check and try again.");
    }
  }

  void _toggleIncognitoMode(bool value) {
    setState(() {
      _isIncognitoMode = value;
    });
  }

  void _toggleWhisperModel(bool value) {
    setState(() {
      _useWhisperModel = value;
    });
  }

  Future<void> _validateAndSaveSettings() async {
    setState(() => _isValidating = true);
    try {
      await _saveSettings();
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Settings saved successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Error saving settings: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Keys',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ApiKeyInput(
              label: 'Brave Search API Key',
              controller: _braveApiController,
              icon: Iconsax.search_normal,
            ),
            ApiKeyInput(
              label: 'Groq API Key',
              controller: _groqApiController,
              icon: Iconsax.code,
            ),
            SizedBox(height: 24),
            Text(
              'Privacy',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SettingsSwitch(
              title: 'Incognito Mode',
              subtitle: 'Disable search history',
              value: _isIncognitoMode,
              onChanged: _toggleIncognitoMode,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 24),
            Text(
              'Speech Recognition',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SettingsSwitch(
              title: 'Use OpenAI Whisper Model',
              subtitle: 'For improved speech recognition',
              value: _useWhisperModel,
              onChanged: _toggleWhisperModel,
              trailing: Icon(
                Iconsax.info_circle,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: 20,
              ),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 24),
            Text(
              'Theme',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SettingsSwitch(
              title: 'Dark Mode',
              subtitle: 'Toggle dark/light theme',
              value: isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _validateAndSaveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? Colors.grey[800] : Colors.grey[300],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Validate and Save Settings',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(
                Iconsax.information,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              title: Text(
                'Version',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                AppConstants.appVersion,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Iconsax.document,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              title: Text(
                'License',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LicenseScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: "Could not launch $url");
    }
  }
}
