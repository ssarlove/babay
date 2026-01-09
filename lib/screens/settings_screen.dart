import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsState {}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildToggleSetting(
            'Dark Mode',
            'Use dark theme for better night viewing',
            Icons.dark_mode,
            storageService.isDarkMode,
            (value) {
              storageService.isDarkMode = value;
            },
          ),
          _buildToggleSetting(
            'Night Mode (Red Tint)',
            'Preserves night vision during night feeds',
            Icons.nights_stay,
            storageService.useNightMode,
            (value) {
              storageService.useNightMode = value;
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Analysis'),
          _buildToggleSetting(
            'Auto-Analyze',
            'Automatically analyze when face is detected',
            Icons.auto_awesome,
            storageService.autoAnalyze,
            (value) {
              storageService.autoAnalyze = value;
            },
          ),
          _buildToggleSetting(
            'Show Confidence Score',
            'Display emotion confidence percentages',
            Icons.analytics,
            storageService.showConfidence,
            (value) {
              storageService.showConfidence = value;
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data'),
          _buildToggleSetting(
            'Save History',
            'Store analyzed moods for tracking',
            Icons.history,
            storageService.saveHistory,
            (value) {
              storageService.saveHistory = value;
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildInfoTile(
            'Version',
            '1.0.0',
            Icons.info_outline,
          ),
          _buildInfoTile(
            'Privacy',
            'All processing happens on your device',
            Icons.privacy_tip_outlined,
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.security, size: 40, color: AppTheme.primaryGreen),
                  SizedBox(height: 8),
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All baby images and audio are processed locally on your device. Nothing is ever uploaded to servers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}