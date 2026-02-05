import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/food_entry.dart';

class MealCard extends StatefulWidget {
  final FoodEntry entry;
  final VoidCallback? onDelete;
  final int index;

  const MealCard({super.key, required this.entry, this.onDelete, this.index = 0});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  IconData get _mealIcon {
    switch (widget.entry.mealType) {
      case 'breakfast': return Icons.wb_sunny_outlined;
      case 'lunch': return Icons.light_mode_outlined;
      case 'dinner': return Icons.nightlight_outlined;
      default: return Icons.cookie_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_mealIcon, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.entry.mealType.isNotEmpty
                                    ? widget.entry.mealType[0].toUpperCase() + widget.entry.mealType.substring(1)
                                    : 'Meal',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                '${widget.entry.totalCalories.round()} kcal',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppTheme.error,
                            onPressed: widget.onDelete,
                          ),
                      ],
                    ),
                    if (widget.entry.items.isNotEmpty) ...[
                      const Divider(height: 20),
                      ...widget.entry.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                            Text('${item.portion}  •  ${item.calories.round()} kcal',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
