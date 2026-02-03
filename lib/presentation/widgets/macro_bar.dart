import 'package:flutter/material.dart';

class MacroBar extends StatefulWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  @override
  State<MacroBar> createState() => _MacroBarState();
}

class _MacroBarState extends State<MacroBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _barAnim = Tween<double>(begin: 0, end: _pct).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  double get _pct => widget.target > 0 ? (widget.current / widget.target).clamp(0.0, 1.0) : 0.0;

  @override
  void didUpdateWidget(MacroBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.target != widget.target) {
      _barAnim = Tween<double>(begin: _barAnim.value, end: _pct).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${widget.current.round()}/${widget.target.round()}${widget.unit}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    // Background
                    Container(
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Animated fill with gradient
                    FractionallySizedBox(
                      widthFactor: _barAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [widget.color.withValues(alpha: 0.7), widget.color],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
