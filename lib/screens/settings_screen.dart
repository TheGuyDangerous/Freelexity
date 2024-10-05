import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _braveApiController = TextEditingController();
  final TextEditingController _groqApiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _braveApiController.text = prefs.getString('braveApiKey') ?? '';
      _groqApiController.text = prefs.getString('groqApiKey') ?? '';
    });
  }

  Future<void> _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('braveApiKey', _braveApiController.text);
    await prefs.setString('groqApiKey', _groqApiController.text);
    print('Saved Groq API key: ${_groqApiController.text}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API keys saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _braveApiController,
              decoration: const InputDecoration(
                labelText: 'Brave Search API Key',
                hintText: 'Enter your Brave Search API key',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _groqApiController,
              decoration: const InputDecoration(
                labelText: 'Groq API Key',
                hintText: 'Enter your Groq API key',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveApiKeys,
              child: const Text('Save API Keys'),
            ),
          ],
        ),
      ),
    );
  }
}
