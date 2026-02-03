import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/video_recommendation.dart';

class VideoCard extends StatefulWidget {
  final VideoRecommendation video;
  final VoidCallback onTap;
  final int index;

  const VideoCard({super.key, required this.video, required this.onTap, this.index = 0});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: Colors.white.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              widget.video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(widget.video.durationFormatted, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.video.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Text(widget.video.channelName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
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
