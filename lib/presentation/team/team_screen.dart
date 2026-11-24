import 'package:flutter/material.dart';
import '../../config/app_language.dart';
import '../../config/theme.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'My team', 'मेरी टीम'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              minTileHeight: 78,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: _avatarColor(index),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                appText(
                  context,
                  'Employee ${index + 1}',
                  'कर्मचारी ${index + 1}',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                '${appText(context, 'Software Engineer', 'सॉफ़्टवेयर इंजीनियर')} • ${_status(context, index)}',
                style: const TextStyle(fontSize: 15),
              ),
              trailing: IconButton(
                tooltip: appText(
                  context,
                  'Call employee',
                  'कर्मचारी को फ़ोन करें',
                ),
                icon: const Icon(
                  Icons.phone_outlined,
                  color: AppTheme.primary,
                  size: 25,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _avatarColor(int index) {
    const colors = [
      Color(0xFFB54736),
      Color(0xFF18794E),
      Color(0xFF2563A6),
      Color(0xFF9A5B00),
      Color(0xFF6554A4),
    ];
    return colors[index % colors.length];
  }

  static String _status(BuildContext context, int index) {
    return index % 3 == 0
        ? appText(context, 'On leave', 'छुट्टी पर')
        : appText(context, 'Present', 'मौजूद');
  }
}
