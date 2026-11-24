import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_language.dart';
import '../../config/theme.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final modules = auth.modules;
    final role = (user?['role'] as String?) ?? 'EMPLOYEE';
    final name =
        (user?['displayName'] as String?) ??
        (user?['email'] as String?)?.split('@').first ??
        'Your account';

    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'More', 'और सेवाएँ'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        role.replaceAll('_', ' '),
                        style: const TextStyle(
                          color: Color(0xFFE0F2F1),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/profile'),
                  tooltip: appText(context, 'Open profile', 'प्रोफ़ाइल खोलें'),
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(appText(context, 'Work', 'काम')),
          _MenuCard(
            items: [
              if (modules.contains('payroll'))
                _MenuItem(
                  Icons.account_balance_wallet,
                  appText(context, 'My payslips', 'मेरी वेतन पर्ची'),
                  appText(
                    context,
                    'View salary and payment history',
                    'तनख़्वाह और भुगतान देखें',
                  ),
                  '/payroll',
                ),
              if (modules.contains('tasks'))
                _MenuItem(
                  Icons.check_circle_outline,
                  appText(context, 'My tasks', 'मेरे काम'),
                  appText(
                    context,
                    'See pending and completed tasks',
                    'बाक़ी और पूरे हुए काम देखें',
                  ),
                  '/tasks',
                ),
              if (modules.contains('field_work'))
                _MenuItem(
                  Icons.directions_walk,
                  appText(context, 'Field work', 'बाहर का काम'),
                  appText(
                    context,
                    'View visits and work route',
                    'मुलाक़ात और काम का रास्ता देखें',
                  ),
                  '/field-timeline',
                ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(appText(context, 'People & updates', 'लोग और सूचनाएँ')),
          _MenuCard(
            items: [
              if (modules.contains('core_hr'))
                _MenuItem(
                  Icons.groups_outlined,
                  appText(context, 'My team', 'मेरी टीम'),
                  appText(
                    context,
                    'Find colleagues and team status',
                    'साथियों और टीम की जानकारी',
                  ),
                  '/team',
                ),
              if (modules.contains('core_hr'))
                _MenuItem(
                  Icons.campaign_outlined,
                  appText(context, 'Company updates', 'कंपनी की सूचनाएँ'),
                  appText(
                    context,
                    'Read announcements and notices',
                    'घोषणाएँ और ज़रूरी सूचना पढ़ें',
                  ),
                  '/announcements',
                ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(appText(context, 'Preferences', 'पसंद')),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1E8EC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3F2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText(context, 'App language', 'ऐप की भाषा'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            appText(
                              context,
                              'Choose the language you prefer',
                              'अपनी पसंद की भाषा चुनें',
                            ),
                            style: TextStyle(
                              color: Colors.blueGrey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'en',
                      label: Text('English'),
                      icon: Icon(Icons.language),
                    ),
                    ButtonSegment(
                      value: 'hi',
                      label: Text('हिन्दी'),
                      icon: Icon(Icons.translate),
                    ),
                  ],
                  selected: {language.isHindi ? 'hi' : 'en'},
                  onSelectionChanged: (selection) =>
                      language.setLanguage(selection.first),
                  showSelectedIcon: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuCard(
            items: [
              _MenuItem(
                Icons.person_outline_rounded,
                appText(context, 'Account profile', 'खाता प्रोफ़ाइल'),
                appText(
                  context,
                  'View your employee details',
                  'कर्मचारी की जानकारी देखें',
                ),
                '/profile',
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
              label: Text(
                appText(context, 'Log out', 'लॉग आउट'),
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE7C8C5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              appText(context, 'HRMS • Version 1.0.0', 'HRMS • संस्करण 1.0.0'),
              style: TextStyle(color: Colors.blueGrey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    return parts
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
        .join();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9, left: 2),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _MenuItem(this.icon, this.title, this.subtitle, this.route);
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E8EC)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              minTileHeight: 76,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3F2),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(items[i].icon, color: AppTheme.primary, size: 24),
              ),
              title: Text(
                items[i].title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                items[i].subtitle,
                style: TextStyle(fontSize: 13, color: Colors.blueGrey[700]),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 26),
              onTap: () => context.push(items[i].route),
            ),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 70, endIndent: 14),
          ],
        ],
      ),
    );
  }
}
