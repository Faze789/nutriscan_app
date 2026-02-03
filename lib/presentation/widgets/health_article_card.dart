import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/health_article.dart';

class HealthArticleCard extends StatefulWidget {
  final HealthArticle article;
  final VoidCallback onTap;
  final int index;

  const HealthArticleCard({super.key, required this.article, required this.onTap, this.index = 0});

  @override
  State<HealthArticleCard> createState() => _HealthArticleCardState();
}

class _HealthArticleCardState extends State<HealthArticleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _categoryColors = <String, Color>{
    'Nutrition': Color(0xFF4CAF50),
    'Fitness': Color(0xFFE91E63),
    'Wellness': Color(0xFF9C27B0),
    'Recipes': Color(0xFFFF9800),
    'Science': Color(0xFF2196F3),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
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
    final color = _categoryColors[widget.article.category] ?? Colors.grey;

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
              child: Material(
                color: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: color.withValues(alpha: 0.1),
                  highlightColor: color.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(widget.article.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(widget.article.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(widget.article.summary, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: widget.article.tags.take(3).map((t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
