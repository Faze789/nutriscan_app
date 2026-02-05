import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final int glasses;
  final int target;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const WaterTracker({
    super.key,
    required this.glasses,
    this.target = 8,
    required this.onAdd,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 20),
            const SizedBox(width: 8),
            Text('Water', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('$glasses / $target glasses', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.outlined(
              onPressed: glasses > 0 ? onRemove : null,
              icon: const Icon(Icons.remove, size: 18),
              iconSize: 18,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: List.generate(target, (i) {
                  final filled = i < glasses;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: filled ? 1.0 : 0.0),
                        duration: Duration(milliseconds: 300 + i * 60),
                        curve: Curves.easeOutBack,
                        builder: (_, value, __) {
                          return Transform.scale(
                            scale: 0.8 + 0.2 * value,
                            child: Icon(
                              Icons.water_drop,
                              size: 22,
                              color: Color.lerp(Colors.grey.shade300, const Color(0xFF2196F3), value),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              iconSize: 18,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ],
    ),
    );
  }
}
