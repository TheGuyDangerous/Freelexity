import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../license/license_screen.dart';
import '../../utils/constants.dart';
import '../../widgets/settings/api_key_input.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../services/search_service.dart';
import '../../services/groq_api_service.dart';
import 'settings_screen.dart';

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _braveApiController = TextEditingController();
  final TextEditingController _groqApiController = TextEditingController();
  bool _isIncognitoMode = false;
  bool _useWhisperModel = false;
  bool _useGoogleSearch = false;
  bool _enableAmbiguityDetection = true;
  double _ambiguityThreshold = 0.6;
  bool _isBraveApiKeyValid = false;
  bool _isGroqApiKeyValid = false;
  bool _isValidating = false;
  bool _hasUnsavedChanges = false;

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
      _isIncognitoMode = prefs.getBool('isIncognitoMode') ?? false;
      _useWhisperModel = prefs.getBool('useWhisperModel') ?? false;
      _useGoogleSearch = prefs.getBool('useGoogleSearch') ?? false;
      _enableAmbiguityDetection = prefs.getBool('enableAmbiguityDetection') ?? true;
      _ambiguityThreshold = prefs.getDouble('ambiguityThreshold') ?? 0.6;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('braveApiKey', _braveApiController.text);
    await prefs.setString('groqApiKey', _groqApiController.text);
    await prefs.setBool('isIncognitoMode', _isIncognitoMode);
    await prefs.setBool('useWhisperModel', _useWhisperModel);
    await prefs.setBool('useGoogleSearch', _useGoogleSearch);
    await prefs.setBool('enableAmbiguityDetection', _enableAmbiguityDetection);
    await prefs.setDouble('ambiguityThreshold', _ambiguityThreshold);
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

    try {
      if (!_useGoogleSearch && _braveApiController.text.isNotEmpty) {
        final isBraveValid =
            await _searchService.validateBraveApiKey(_braveApiController.text);
        setState(() => _isBraveApiKeyValid = isBraveValid);
      } else {
        setState(() => _isBraveApiKeyValid = true);
      }

      if (_groqApiController.text.isNotEmpty) {
        final isGroqValid =
            await _groqApiService.validateApiKey(_groqApiController.text);
        setState(() => _isGroqApiKeyValid = isGroqValid);
      }

      final validationPassed = _useGoogleSearch
          ? _isGroqApiKeyValid // Only check Groq API when using Google Search
          : _isBraveApiKeyValid && _isGroqApiKeyValid;

      if (validationPassed) {
        await _saveSettings();
        setState(() => _hasUnsavedChanges = false);
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Settings validated and saved successfully",
            backgroundColor: Colors.green,
          );
        }
      } else {
        if (mounted) {
          final message = _useGoogleSearch
              ? "Groq API key is invalid"
              : "One or more API keys are invalid";
          Fluttertoast.showToast(
            msg: message,
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Error validating API keys: $e",
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  void _toggleIncognitoMode(bool value) {
    setState(() {
      _isIncognitoMode = value;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleWhisperModel(bool value) {
    setState(() {
      _useWhisperModel = value;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleGoogleSearch(bool value) {
    setState(() {
      _useGoogleSearch = value;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleAmbiguityDetection(bool value) {
    setState(() {
      _enableAmbiguityDetection = value;
      _hasUnsavedChanges = true;
    });
  }

  void _updateAmbiguityThreshold(double value) {
    setState(() {
      _ambiguityThreshold = value;
      _hasUnsavedChanges = true;
    });
  }

  void _showAmbiguityInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Query Ambiguity Detection'),
          content: Text(
              'This feature detects when your search query might have multiple meanings and helps you clarify what you\'re looking for.\n\n'
              'The ambiguity threshold controls how sensitive the detection is. A higher value means more queries will be considered ambiguous.\n\n'
              'Setting the threshold to 1.0 will detect most ambiguities but may prompt for clarification more often. Setting it to 0.0 will effectively disable the feature.'),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Keys',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            if (!_useGoogleSearch)
              ApiKeyInput(
                label: 'Brave API Key',
                controller: _braveApiController,
                icon: Iconsax.search_normal,
                onChanged: () => setState(() => _hasUnsavedChanges = true),
              ),
            ApiKeyInput(
              label: 'Groq API Key',
              controller: _groqApiController,
              icon: Iconsax.code,
              onChanged: () => setState(() => _hasUnsavedChanges = true),
            ),
            SizedBox(height: 24),
            Text(
              'Search',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Use Google Search',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Use Google Search instead of Brave',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.info_circle),
                      onPressed: () => _showGoogleSearchInfoDialog(),
                    ),
                    Switch(
                      value: _useGoogleSearch,
                      onChanged: _toggleGoogleSearch,
                    ),
                  ],
                ),
                onTap: () => _toggleGoogleSearch(!_useGoogleSearch),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Privacy',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Incognito Mode',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Disable search history',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Switch(
                  value: _isIncognitoMode,
                  onChanged: _toggleIncognitoMode,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Speech Recognition',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Use OpenAI Whisper Model',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'For improved speech recognition',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.info_circle),
                      onPressed: _showWhisperInfoDialog,
                    ),
                    Switch(
                      value: _useWhisperModel,
                      onChanged: _toggleWhisperModel,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Theme',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Dark Mode',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Toggle dark/light theme',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Accent Color',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Choose app accent color',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.seedColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _showColorPicker(context),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Query Disambiguation',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Enable ambiguity detection',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Detect and clarify ambiguous search queries',
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    value: _enableAmbiguityDetection,
                    onChanged: _toggleAmbiguityDetection,
                    activeColor: theme.colorScheme.primary,
                    secondary: Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Visibility(
                    visible: _enableAmbiguityDetection,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ambiguity threshold',
                                style: theme.textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: _showAmbiguityInfoDialog,
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Low', style: theme.textTheme.bodySmall),
                              Expanded(
                                child: Slider(
                                  value: _ambiguityThreshold,
                                  onChanged: _updateAmbiguityThreshold,
                                  min: 0.1,
                                  max: 0.9,
                                  divisions: 8,
                                  label: _ambiguityThreshold.toStringAsFixed(1),
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ),
                              Text('High', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: (_isValidating || !_hasUnsavedChanges)
                  ? null
                  : _validateApiKeys,
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isValidating
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_hasUnsavedChanges
                      ? 'Validate and Save Settings'
                      : 'No Changes to Save'),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Iconsax.information),
              title: Text(
                'Version',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                AppConstants.appVersion,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.document),
              title: Text(
                'License',
                style: theme.textTheme.titleMedium,
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

  void _showColorPicker(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.lime,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.indigo,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          title: Text('Choose Accent Color'),
          content: SizedBox(
            width: 300,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colors.map((color) {
                return InkWell(
                  onTap: () {
                    themeProvider.updateSeedColor(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeProvider.seedColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showGoogleSearchInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Google Search'),
          content: Text(
              'The image search functionality is currently being tested and will not be available for now. '
              'Other search features will work as expected.'),
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

  @override
  void dispose() {
    _braveApiController.dispose();
    _groqApiController.dispose();
    super.dispose();
  }
}
