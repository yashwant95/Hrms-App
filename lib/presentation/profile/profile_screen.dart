import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'My profile', 'मेरी प्रोफ़ाइल')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary,
                child: Text(
                  'JS',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appText(context, 'Yashwant Dewangan', 'यशवंत देवांगन'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              appText(context, 'Senior Developer', 'सीनियर डेवलपर'),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Employee Details
            GlassCard(
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    appText(context, 'Employee ID', 'कर्मचारी आईडी'),
                    'EMP-001',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    context,
                    appText(context, 'Department', 'विभाग'),
                    appText(context, 'Engineering', 'इंजीनियरिंग'),
                  ),
                  const Divider(),
                  _buildProfileItem(
                    context,
                    appText(context, 'Email', 'ईमेल'),
                    'yashwantdewangan1234@gmail.com',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    context,
                    appText(context, 'Phone', 'फ़ोन'),
                    '+91 9424137362',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Document Vault
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                appText(context, 'My documents', 'मेरे दस्तावेज़'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: Colors.blue,
                    ),
                    title: Text(
                      appText(
                        context,
                        'Employment contract',
                        'नौकरी का अनुबंध',
                      ),
                    ),
                    trailing: const Icon(Icons.visibility_outlined),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appText(
                              context,
                              'Opening document…',
                              'दस्तावेज़ खुल रहा है…',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.upload_file, color: Colors.green),
                    title: Text(
                      appText(
                        context,
                        'Upload a document',
                        'दस्तावेज़ अपलोड करें',
                      ),
                    ),
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        // Mock Upload
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appText(
                                  context,
                                  'Uploading ${result.files.single.name}…',
                                  '${result.files.single.name} अपलोड हो रहा है…',
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
