import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'Leave', 'छुट्टी'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApplyLeaveSheet(context),
        label: Text(appText(context, 'Apply for leave', 'छुट्टी के लिए आवेदन')),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Cards
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildBalanceCard(
                    context,
                    appText(context, 'Casual leave', 'आकस्मिक छुट्टी'),
                    '8/12',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildBalanceCard(
                    context,
                    appText(context, 'Sick leave', 'बीमारी की छुट्टी'),
                    '4/10',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildBalanceCard(
                    context,
                    appText(context, 'Earned leave', 'अर्जित छुट्टी'),
                    '15/20',
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              appText(context, 'Recent requests', 'हाल के आवेदन'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              index == 0
                                  ? appText(
                                      context,
                                      'Sick leave',
                                      'बीमारी की छुट्टी',
                                    )
                                  : appText(
                                      context,
                                      'Casual leave',
                                      'आकस्मिक छुट्टी',
                                    ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '24 Jan - 25 Jan',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            index == 0
                                ? appText(context, 'Pending', 'लंबित')
                                : appText(context, 'Approved', 'मंज़ूर'),
                            style: TextStyle(
                              color: index == 0 ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    String title,
    String balance,
    Color color,
  ) {
    return GlassCard(
      width: 140,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, color: color),
          const Spacer(),
          Text(
            balance,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showApplyLeaveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ApplyLeaveSheet(),
    );
  }
}

class ApplyLeaveSheet extends StatefulWidget {
  const ApplyLeaveSheet({super.key});

  @override
  State<ApplyLeaveSheet> createState() => _ApplyLeaveSheetState();
}

class _ApplyLeaveSheetState extends State<ApplyLeaveSheet> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Sick Leave';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appText(context, 'Apply for leave', 'छुट्टी के लिए आवेदन'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Leave Type
            DropdownButtonFormField<String>(
              initialValue: _leaveType,
              decoration: InputDecoration(
                labelText: appText(context, 'Leave type', 'छुट्टी का प्रकार'),
              ),
              items:
                  ['Sick Leave', 'Casual Leave', 'Earned Leave', 'Unpaid Leave']
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(_leaveTypeText(context, t)),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _leaveType = v!),
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2027),
                      );
                      setState(() => _startDate = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: appText(
                          context,
                          'Start date',
                          'शुरू होने की तारीख़',
                        ),
                      ),
                      child: Text(
                        _startDate != null
                            ? _startDate.toString().split(' ')[0]
                            : appText(context, 'Select date', 'तारीख़ चुनें'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime(2027),
                      );
                      setState(() => _endDate = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: appText(context, 'End date', 'अंतिम तारीख़'),
                      ),
                      child: Text(
                        _endDate != null
                            ? _endDate.toString().split(' ')[0]
                            : appText(context, 'Select date', 'तारीख़ चुनें'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: appText(context, 'Reason', 'कारण'),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty
                  ? appText(
                      context,
                      'Please enter a reason',
                      'कृपया कारण लिखें',
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _startDate != null &&
                      _endDate != null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appText(
                            context,
                            'Leave request submitted.',
                            'छुट्टी का आवेदन भेज दिया गया।',
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: Text(appText(context, 'Send request', 'आवेदन भेजें')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _leaveTypeText(BuildContext context, String type) {
    switch (type) {
      case 'Sick Leave':
        return appText(context, type, 'बीमारी की छुट्टी');
      case 'Casual Leave':
        return appText(context, type, 'आकस्मिक छुट्टी');
      case 'Earned Leave':
        return appText(context, type, 'अर्जित छुट्टी');
      default:
        return appText(context, type, 'बिना वेतन की छुट्टी');
    }
  }
}
