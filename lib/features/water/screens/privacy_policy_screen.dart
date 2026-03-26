import 'package:flutter/material.dart';
import '../../../app.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Privacy Policy',
              'Last updated: March 26, 2026\n\nYour privacy is important to us. This Privacy Policy explains how Daily Water Reminder ("we", "us", or "our") collects, uses, and protects your information when you use our mobile application.',
            ),
            _buildSection(
              '1. Information Collection',
              'We collect minimal personal information to provide you with a personalized experience:\n\n'
              '• Name and Gender: To personalize your dashboard and reminders.\n'
              '• Physical Stats (Weight and Height): To calculate your recommended daily water intake.\n'
              '• Water Intake History: To track your progress and provide statistics.\n\n'
              'All this data is stored LOCALLY on your device using Hive database. We do not upload this data to any external servers.',
            ),
            _buildSection(
              '2. Usage of Information',
              'The information we collect is used solely within the app to:\n\n'
              '• Calculate your hydration needs.\n'
              '• Send you timely reminders.\n'
              '• Display your health progress and streaks.',
            ),
            _buildSection(
              '3. Data Security',
              'Since your data is stored locally on your device, its security depends on your device\'s security. We recommend using built-in device protection like PIN or Biometrics.',
            ),
            _buildSection(
              '4. Changes to This Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            _buildSection(
              '5. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at support@dailywater.com',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: WaterReminderApp.deepWater,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
