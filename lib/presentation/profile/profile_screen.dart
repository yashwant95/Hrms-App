import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
                child: Text('JS', style: TextStyle(fontSize: 32, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yashwant Dewangan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Senior Developer',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Employee Details
            GlassCard(
              child: Column(
                children: [
                  _buildProfileItem('Employee ID', 'EMP-001'),
                  const Divider(),
                  _buildProfileItem('Department', 'Engineering'),
                  const Divider(),
                  _buildProfileItem('Email', 'yashwantdewangan1234@gmail.com'),
                  const Divider(),
                  _buildProfileItem('Phone', '+91 9424137362'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Document Vault
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Document Vault',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: Colors.blue),
                    title: const Text('Employment Contract'),
                    trailing: const Icon(Icons.visibility_outlined),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening PDF viewer...')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.upload_file, color: Colors.green),
                    title: const Text('Upload New Document'),
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                         // Mock Upload
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Uploading ${result.files.single.name}...')),
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

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
