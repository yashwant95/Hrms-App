import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Team')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getAvatarColor(index),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  'Employee ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Software Engineer • ${_getStatus(index)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.phone_outlined, color: AppTheme.primary),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getAvatarColor(int index) {
    const colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  String _getStatus(int index) {
    return index % 3 == 0 ? 'On Leave' : 'Present';
  }
}
