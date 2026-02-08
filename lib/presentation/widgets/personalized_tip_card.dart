import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/utils/personalization_engine.dart';

class PersonalizedTipCard extends StatefulWidget {
  final PersonalizedTip tip;
  final int index;
  const PersonalizedTipCard({super.key, required this.tip, this.index = 0});

  @override
  State<PersonalizedTipCard> createState() => _PersonalizedTipCardState();
}

class _PersonalizedTipCardState extends State<PersonalizedTipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  static const _iconMap = <String, IconData>{
    'water_drop': Icons.water_drop,
    'directions_walk': Icons.directions_walk,
    'restaurant': Icons.restaurant,
    'fitness_center': Icons.fitness_center,
    'egg': Icons.egg,
    'balance': Icons.balance,
    'timer': Icons.timer,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
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
    final color = Color(int.tryParse('FF${widget.tip.colorHex}', radix: 16) ?? 0xFF4CAF50);
    final icon = _iconMap[widget.tip.icon] ?? Icons.lightbulb;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.04)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.tip.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(widget.tip.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
