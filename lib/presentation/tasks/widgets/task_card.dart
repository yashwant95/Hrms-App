import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../domain/entities/task.dart';
import '../../../widgets/glass_card.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String subtaskId)? onToggleSubtask;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onToggleSubtask,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDone = task.isCompleted;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        color: AppTheme.success,
        icon: Icons.check_circle_rounded,
        label: isDone ? 'Reopen' : 'Complete',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppTheme.danger,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Toggle complete
          widget.onToggle();
          return false; // Don't remove from DOM via Dismissible, let state handle it
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Left: Delete
          widget.onDelete();
          return true;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Row: Checkbox + Title/Details + Priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1-Tap Circular Animated Checkbox
                  GestureDetector(
                    onTap: widget.onToggle,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, right: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppTheme.success : Colors.white,
                          border: Border.all(
                            color: isDone ? AppTheme.success : _getPriorityColor(task.priority).withOpacity(0.6),
                            width: 2,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: AppTheme.success.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Title + Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDone ? Colors.grey[400] : AppTheme.textPrimary,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.grey[400],
                            decorationThickness: 1.8,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDone ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing Popup Menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, size: 20, color: Colors.grey[400]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'TOGGLE') widget.onToggle();
                      if (val == 'DELETE') widget.onDelete();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'TOGGLE',
                        child: Row(
                          children: [
                            Icon(isDone ? Icons.refresh_rounded : Icons.check_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(isDone ? 'Mark Incomplete' : 'Mark Complete'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'DELETE',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.danger),
                            const SizedBox(width: 8),
                            const Text('Delete Task', style: TextStyle(color: AppTheme.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Bottom Metadata Row: Category + Due Date + Subtasks Indicator
              Row(
                children: [
                  const SizedBox(width: 36), // Align with text after checkbox

                  // Category Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!, width: 0.8),
                    ),
                    child: Text(
                      '#${_formatCategory(task.category)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Priority Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 11,
                          color: _getPriorityColor(task.priority),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          task.priority,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(task.priority),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Subtasks Pill (if any)
                  if (task.subtasks.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 13,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Due Date Badge
                  if (task.dueDate != null) _buildDueDateBadge(task),
                ],
              ),

              // Subtasks Checklist List (Expandable)
              if (_isExpanded && task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Column(
                    children: task.subtasks.map((subtask) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => widget.onToggleSubtask?.call(subtask.id),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: subtask.isCompleted ? AppTheme.success : Colors.white,
                                  border: Border.all(
                                    color: subtask.isCompleted ? AppTheme.success : Colors.grey[400]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: subtask.isCompleted
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtask.isCompleted ? Colors.grey[400] : AppTheme.textPrimary,
                                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ] else ...[
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 22),
          ],
        ],
      ),
    );
  }

  Widget _buildDueDateBadge(Task task) {
    if (task.dueDate == null) return const SizedBox.shrink();

    Color bgColor = Colors.grey[100]!;
    Color textColor = Colors.grey[700]!;
    IconData icon = Icons.calendar_today_rounded;
    String label = DateFormat('MMM d').format(task.dueDate!);

    if (task.isCompleted) {
      label = 'Done';
      bgColor = AppTheme.success.withOpacity(0.1);
      textColor = AppTheme.success;
      icon = Icons.check_circle_outline_rounded;
    } else if (task.isOverdue) {
      label = 'Overdue';
      bgColor = AppTheme.danger.withOpacity(0.1);
      textColor = AppTheme.danger;
      icon = Icons.warning_amber_rounded;
    } else if (task.isDueToday) {
      label = 'Today';
      bgColor = Colors.amber.withOpacity(0.15);
      textColor = Colors.amber[900]!;
      icon = Icons.bolt_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return AppTheme.danger;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return AppTheme.success;
      default:
        return AppTheme.primary;
    }
  }

  String _formatCategory(String cat) {
    switch (cat.toUpperCase()) {
      case 'HR_COMPLIANCE':
        return 'HR';
      case 'WORK':
        return 'Work';
      case 'PERSONAL':
        return 'Personal';
      case 'MEETING':
        return 'Meeting';
      default:
        return cat.toLowerCase();
    }
  }
}
