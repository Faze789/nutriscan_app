import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/video_recommendation.dart';
import '../../providers/video_provider.dart';
import '../../widgets/category_chip_bar.dart';
import '../../widgets/video_card.dart';

class VideoFeedScreen extends ConsumerWidget {
  const VideoFeedScreen({super.key});

  static const _categories = ['Workout', 'Nutrition', 'Cooking', 'Yoga', 'Motivation'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredVideosProvider);
    final selectedCategory = ref.watch(videoCategoryFilter);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text('Videos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Personalized for your goals', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          const SizedBox(height: 10),
          CategoryChipBar(
            categories: _categories,
            selected: selectedCategory,
            onSelected: (c) => ref.read(videoCategoryFilter.notifier).state = c,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Error loading videos:\n$e', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(videoRecommendationsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (videos) {
                if (videos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.video_library_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No videos yet'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => ref.invalidate(videoRecommendationsProvider),
                          child: const Text('Load Videos'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(videoRecommendationsProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (_, i) => VideoCard(
                      video: videos[i],
                      index: i,
                      onTap: () => _openVideo(context, videos[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVideo(BuildContext context, VideoRecommendation video) async {
    final uri = Uri.tryParse(video.youtubeUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      } catch (_) {}
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => _VideoDetailDialog(video: video),
    );
  }
}

class _VideoDetailDialog extends StatelessWidget {
  final VideoRecommendation video;
  const _VideoDetailDialog({required this.video});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(video.channelName, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                Text(video.durationFormatted, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open in YouTube'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final uri = Uri.tryParse(video.youtubeUrl);
                      if (uri != null) {
                        await launchUrl(uri, mode: LaunchMode.platformDefault);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
