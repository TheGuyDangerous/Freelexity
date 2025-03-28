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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your app experience',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'API Keys',
                const Icon(Iconsax.key, size: 20),
                [
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
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Search',
                const Icon(Iconsax.search_normal, size: 20),
                [
                  _buildSettingItem(
                    context,
                    'Use Google Search',
                    'Use Google Search instead of Brave',
                    Iconsax.document,
                    _useGoogleSearch,
                    _toggleGoogleSearch,
                    onInfoPressed: () => _showGoogleSearchInfoDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Privacy',
                const Icon(Iconsax.shield, size: 20),
                [
                  _buildSettingItem(
                    context,
                    'Incognito Mode',
                    'Disable search history',
                    Iconsax.user_minus,
                    _isIncognitoMode,
                    _toggleIncognitoMode,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Speech Recognition',
                const Icon(Iconsax.microphone, size: 20),
                [
                  _buildSettingItem(
                    context,
                    'Use OpenAI Whisper Model',
                    'For improved speech recognition',
                    Iconsax.voice_square,
                    _useWhisperModel,
                    _toggleWhisperModel,
                    onInfoPressed: _showWhisperInfoDialog,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Theme',
                const Icon(Iconsax.brush_2, size: 20),
                [
                  _buildSettingItem(
                    context,
                    'Dark Mode',
                    'Toggle dark/light theme',
                    Iconsax.moon,
                    themeProvider.isDarkMode,
                    (value) => themeProvider.toggleTheme(),
                  ),
                  const SizedBox(height: 16),
                  _buildColorPickerItem(context),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'Query Disambiguation',
                const Icon(Iconsax.message_question, size: 20),
                [
                  _buildSettingItem(
                    context,
                    'Enable ambiguity detection',
                    'Detect and clarify ambiguous search queries',
                    Iconsax.information,
                    _enableAmbiguityDetection,
                    _toggleAmbiguityDetection,
                  ),
                  if (_enableAmbiguityDetection) ...[
                    const SizedBox(height: 16),
                    _buildThresholdSlider(context),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                'About',
                const Icon(Iconsax.info_circle, size: 20),
                [
                  _buildInfoButton(
                    context,
                    'About Freelexity',
                    'Learn more about the app',
                    Iconsax.info_circle,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LicenseScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _hasUnsavedChanges
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'You have unsaved changes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _validateApiKeys,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: _isValidating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text('Save & Validate'),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildSection(
      BuildContext context, String title, Icon icon, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              IconTheme(
                data: IconThemeData(color: theme.colorScheme.primary),
                child: icon,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData iconData,
    bool value,
    Function(bool) onChanged, {
    VoidCallback? onInfoPressed,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        secondary: onInfoPressed != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.info_circle,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: onInfoPressed,
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData iconData,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildThresholdSlider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Iconsax.slider,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ambiguity threshold',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAmbiguityInfoDialog,
                child: Icon(
                  Iconsax.info_circle,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Low',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
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
              Text(
                'High',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerItem(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        title: Text(
          'Accent Color',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Choose app accent color',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Iconsax.colorfilter,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: themeProvider.seedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.seedColor.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        onTap: () => _showColorPicker(context),
      ),
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

  @override
  void dispose() {
    _braveApiController.dispose();
    _groqApiController.dispose();
    super.dispose();
  }
}
