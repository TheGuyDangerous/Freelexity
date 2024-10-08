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
    Fluttertoast.showToast(msg: "Settings saved successfully");
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings',
                style: TextStyle(
                    fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('API Keys',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
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
                Text('Privacy',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                SettingsSwitch(
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  title: 'Incognito Mode',
                  subtitle: 'Disable search history',
                  value: _isIncognitoMode,
                  onChanged: (value) {
                    setState(() {
                      _isIncognitoMode = value;
                    });
                  },
                ),
                SizedBox(height: 24),
                Text('Speech Recognition',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                SettingsSwitch(
                  title: 'Use OpenAI Whisper Model',
                  subtitle: 'For improved speech recognition',
                  value: _useWhisperModel,
                  onChanged: (value) {
                    setState(() {
                      _useWhisperModel = value;
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(Iconsax.info_circle,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]
                            : Colors.black),
                    onPressed: _showWhisperInfoDialog,
                  ),
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                ),
                SizedBox(height: 24),
                SettingsSwitch(
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark/light theme',
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isValidating ? null : _validateApiKeys,
                  // ignore: sort_child_properties_last
                  child: _isValidating
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.grey[600],
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Validate and Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize:
                        Size(double.infinity, 50), // Ensure consistent height
                  ),
                ),
                SizedBox(height: 32),
                Text('About',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Iconsax.info_circle,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600]),
                  title: Text('Version'),
                  subtitle: Text(AppConstants.appVersion),
                ),
                ListTile(
                  leading: Icon(Iconsax.document,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600]),
                  title: Text('License'),
                  subtitle: Text('Custom License'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LicenseScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Iconsax.code,
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600]),
                  title: Text('Source Code'),
                  subtitle: Text('GitHub'),
                  onTap: () => _launchURL(AppConstants.githubUrl),
                ),
                SizedBox(height: 32),
                Center(
                  child: Text(
                    'Created with ❣️ by Sannidhya Dubey',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
