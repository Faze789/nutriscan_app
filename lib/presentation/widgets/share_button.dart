import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const ShareButton({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined, size: 20),
      tooltip: tooltip ?? 'Share',
      onPressed: onPressed,
    );
  }
}
