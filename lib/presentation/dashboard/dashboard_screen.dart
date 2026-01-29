import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // access user role from provider later
    const bool isHrAdmin = true; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.push('/profile'),
            child: const CircleAvatar(
              backgroundColor: AppTheme.secondary,
              child: Text('JS', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Morning, John!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: 4),
            Text(
              'Here is what\'s happening today',
              style: TextStyle(color: Colors.grey[600]),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: 24),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  'Present Today',
                  '85%',
                  Icons.people_outline,
                  Colors.blue,
                  onTap: () => context.push('/team'),
                ),
                _buildStatCard(
                  'Pending Leaves',
                  '12',
                  Icons.calendar_today_outlined,
                  Colors.orange,
                  onTap: () => context.push('/leave'),
                ),
                _buildStatCard(
                  'Total Employees',
                  '142',
                  Icons.groups_outlined,
                  Colors.purple,
                  onTap: () => context.push('/team'),
                ),
                _buildStatCard(
                  'Payroll Status',
                  'Draft',
                  Icons.monetization_on_outlined,
                  Colors.green,
                  onTap: () => context.push('/payroll'),
                ),
                _buildStatCard(
                  'My Tasks',
                  '5 Active',
                  Icons.assignment_outlined,
                  Colors.redAccent,
                  onTap: () => context.push('/tasks'),
                ),
              ].animate(interval: 100.ms).fadeIn().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
            ),

            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.fingerprint_outlined, color: AppTheme.danger),
                    title: const Text('Mark Attendance'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/attendance'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_add_outlined, color: AppTheme.primary),
                    title: const Text('New Employee Onboarding'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/team'), // Shortcut to team for now
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.campaign_outlined, color: AppTheme.secondary),
                    title: const Text('Company Announcements'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/announcements'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
