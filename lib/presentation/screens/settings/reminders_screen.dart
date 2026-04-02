import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_reminder.dart';
import '../../../services/notification_service.dart';
import '../../providers/providers.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/glass_card.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  Map<String, UserReminder> _reminders = {};

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Reminders')),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reminders) {
          if (_reminders.isEmpty) {
            _reminders = {for (final r in reminders) r.type: r};
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Set reminders to stay on track with your nutrition goals.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              ...ReminderType.all.map((type) => _ReminderTile(
                    type: type,
                    reminder: _reminders[type],
                    onToggle: (active) => _toggleReminder(type, active),
                    onTimeChanged: (time) => _updateTime(type, time),
                  )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleReminder(String type, bool active) async {
    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final existing = _reminders[type];
    final reminder = existing != null
        ? existing.copyWith(isActive: active)
        : UserReminder(
            id: const Uuid().v4(),
            userUid: uid,
            type: type,
            time: ReminderType.defaultTime(type),
            isActive: active,
          );

    setState(() => _reminders[type] = reminder);
    await ref.read(reminderRepoProvider).saveReminder(reminder);

    if (active) {
      await NotificationService.scheduleDaily(
        id: ReminderType.notificationId(type),
        title: '${ReminderType.label(type)} Reminder',
        body: ReminderType.body(type),
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } else {
      await NotificationService.cancelNotification(
          ReminderType.notificationId(type));
    }

    ref.invalidate(remindersProvider);
  }

  Future<void> _updateTime(String type, TimeOfDay time) async {
    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final existing = _reminders[type];
    final reminder = existing != null
        ? existing.copyWith(time: timeStr)
        : UserReminder(
            id: const Uuid().v4(),
            userUid: uid,
            type: type,
            time: timeStr,
            isActive: true,
          );

    setState(() => _reminders[type] = reminder);
    await ref.read(reminderRepoProvider).saveReminder(reminder);

    if (reminder.isActive) {
      await NotificationService.scheduleDaily(
        id: ReminderType.notificationId(type),
        title: '${ReminderType.label(type)} Reminder',
        body: ReminderType.body(type),
        hour: time.hour,
        minute: time.minute,
      );
    }

    ref.invalidate(remindersProvider);
  }
}

class _ReminderTile extends StatelessWidget {
  final String type;
  final UserReminder? reminder;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _ReminderTile({
    required this.type,
    required this.reminder,
    required this.onToggle,
    required this.onTimeChanged,
  });

  IconData get _icon {
    switch (type) {
      case ReminderType.breakfast:
        return Icons.wb_sunny_outlined;
      case ReminderType.lunch:
        return Icons.light_mode_outlined;
      case ReminderType.dinner:
        return Icons.nightlight_outlined;
      case ReminderType.water:
        return Icons.water_drop_outlined;
      case ReminderType.weight:
        return Icons.monitor_weight_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (type) {
      case ReminderType.breakfast:
        return const Color(0xFFFF9800);
      case ReminderType.lunch:
        return AppTheme.primary;
      case ReminderType.dinner:
        return const Color(0xFF673AB7);
      case ReminderType.water:
        return const Color(0xFF2196F3);
      case ReminderType.weight:
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = reminder?.isActive ?? false;
    final timeStr = reminder?.time ?? ReminderType.defaultTime(type);
    final parts = timeStr.split(':');
    final hour = parts.length >= 2 ? (int.tryParse(parts[0]) ?? 8) : 8;
    final minute = parts.length >= 2 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final timeOfDay = TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ReminderType.label(type),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: timeOfDay,
                    );
                    if (picked != null) {
                      onTimeChanged(picked);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        timeOfDay.format(context),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit,
                          size: 12, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeThumbColor: _color,
          ),
        ],
      ),
    );
  }
}
