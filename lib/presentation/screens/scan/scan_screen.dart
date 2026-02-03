import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/food_entry.dart';
import '../../providers/providers.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  File? _imageFile;
  List<FoodItem>? _results;
  bool _loading = false;
  String _mealType = 'lunch';

  final _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _results = null;
    });
    await _analyze();
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await _imageFile!.readAsBytes();
      final items = await ref.read(geminiServiceProvider).analyzeImage(bytes);
      setState(() => _results = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_results == null || _results!.isEmpty) return;

    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    double totalCal = 0, totalPro = 0, totalCarb = 0, totalFat = 0;
    for (final item in _results!) {
      totalCal += item.calories;
      totalPro += item.protein;
      totalCarb += item.carbs;
      totalFat += item.fat;
    }

    final entry = FoodEntry(
      id: const Uuid().v4(),
      userUid: uid,
      date: DateTime.now(),
      mealType: _mealType,
      items: _results!,
      totalCalories: totalCal,
      totalProtein: totalPro,
      totalCarbs: totalCarb,
      totalFat: totalFat,
      imagePath: _imageFile?.path,
    );

    await ref.read(foodRepoProvider).addEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal logged successfully!'), backgroundColor: AppTheme.primary),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Food')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, size: 48, color: AppTheme.textSecondary),
                          SizedBox(height: 8),
                          Text('Take or pick a photo of your meal', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Camera / Gallery buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meal type selector
            Text('Meal Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _mealTypes.map((type) {
                return ChoiceChip(
                  label: Text(type[0].toUpperCase() + type.substring(1)),
                  selected: _mealType == type,
                  onSelected: (_) => setState(() => _mealType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Loading / Results
            if (_loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Analyzing with AI...', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),

            if (_results != null && !_loading) ...[
              Text('Detected Food Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ..._results!.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.fastfood, color: Colors.white, size: 20),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${item.portion}  •  P: ${item.protein.round()}g  C: ${item.carbs.round()}g  F: ${item.fat.round()}g'),
                  trailing: Text('${item.calories.round()}\nkcal',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
              )),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Log This Meal'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
