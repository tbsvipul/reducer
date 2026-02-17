import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for ImageMaster Pro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Effective Date: February 15, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 48),
            
            _buildSection(
              '1. Introduction',
              'ImageMaster Pro ("we", "us", or "our") is dedicated to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
            ),
            
            _buildSection(
              '2. Data Collection & Processing',
              'We believe in "Privacy by Design." \n\n'
              '• Image Processing: All image resizing, compression, and EXIF cleaning are performed LOCALLY on your device. We do not upload your images to our servers.\n'
              '• Minimal Data: We do not collect personally identifiable information (PII) such as your name, email, or address unless you explicitly provide it for support purposes.',
            ),
            
            _buildSection(
              '3. Third-Party Services',
              'We use third-party services that may collect information used to identify you:\n\n'
              '• Google AdMob: Used for displaying advertisements. AdMob may collect device identifiers and location data to serve personalized ads.\n'
              '• Google Play Services: Required for app functionality and updates.',
            ),
            
            _buildSection(
              '4. Permissions',
              'The app requires the following permissions to function correctly:\n\n'
              '• Storage/Gallery: To select images for processing and to save processed images to your device.\n'
              '• Camera: To take photos directly within the app for processing.',
            ),
            
            _buildSection(
              '5. Data Security',
              'We implement industry-standard security measures to protect any data processed by the app. However, as image processing is local, the security of your images depends on your device\'s security.',
            ),
            
            _buildSection(
              '6. Children\'s Privacy',
              'Our app does not address anyone under the age of 13. We do not knowingly collect personal information from children.',
            ),
            
            _buildSection(
              '7. Changes to This Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            
            _buildSection(
              '8. Contact Us',
              'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@imagemaster.pro.',
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 ImageMaster Pro. All rights reserved.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
