import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../providers/task_provider.dart';

class TaskFilterChips extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;
  final TaskState state;

  const TaskFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'ALL', 'label': 'All', 'count': state.totalCount, 'icon': Icons.format_list_bulleted_rounded},
      {'key': 'TODAY', 'label': 'Today', 'count': state.todayTotalCount, 'icon': Icons.bolt_rounded},
      {'key': 'URGENT', 'label': 'Urgent', 'count': state.tasks.where((t) => t.priority == 'HIGH').length, 'icon': Icons.flag_rounded},
      {'key': 'WORK', 'label': 'Work', 'count': state.tasks.where((t) => t.category == 'WORK' || t.category == 'HR_COMPLIANCE' || t.category == 'MEETING').length, 'icon': Icons.work_outline_rounded},
      {'key': 'PERSONAL', 'label': 'Personal', 'count': state.tasks.where((t) => t.category == 'PERSONAL').length, 'icon': Icons.person_outline_rounded},
      {'key': 'COMPLETED', 'label': 'Done', 'count': state.completedCount, 'icon': Icons.check_circle_outline_rounded},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final key = filter['key'] as String;
          final isSelected = activeFilter == key;
          final count = filter['count'] as int;
          final icon = filter['icon'] as IconData;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filter['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[800],
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            backgroundColor: Colors.white,
            selectedColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            onSelected: (_) => onFilterSelected(key),
          );
        },
      ),
    );
  }
}
