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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Privacy Policy',
              'Last updated: March 26, 2026\n\n'
                  'Your privacy is important to us. This Privacy Policy explains how Water Track ("we", "us", or "our") handles your information when you use our mobile application.',
            ),

            _buildSection(
              '1. Information Collection',
              'We collect minimal information to provide app functionality:\n\n'
                  '• Name: To personalize your experience.\n'
                  '• Height and Weight: To calculate your daily water intake.\n\n'
                  'All data is stored locally on your device using local storage. We do not send or store this data on any external servers.',
            ),

            _buildSection(
              '2. Usage of Information',
              'The information is used only within the app to:\n\n'
                  '• Calculate your hydration needs.\n'
                  '• Track your daily water intake.',
            ),

            _buildSection(
              '3. Data Security',
              'All data is stored locally on your device. We recommend using device security such as PIN or biometric lock.',
            ),

            _buildSection(
              '4. Third-Party Services',
              'Water Track does not use any third-party services that collect user data.',
            ),

            _buildSection(
              '5. Children\'s Privacy',
              'This app does not knowingly collect personal information from children under the age of 13.',
            ),

            _buildSection(
              '6. Changes to This Policy',
              'We may update this Privacy Policy from time to time. Changes will be reflected within the app.',
            ),

            _buildSection(
              '7. Contact Us',
              'If you have any questions, contact us at:\n\nbrindaponkiya1000@gmail.com',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16, // 🔽 smaller title
              fontWeight: FontWeight.w600,
              color: WaterReminderApp.deepWater,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13, // 🔽 smaller content font
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
