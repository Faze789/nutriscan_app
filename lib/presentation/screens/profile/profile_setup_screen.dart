import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/calorie_calculator.dart';
import '../../../data/models/user_profile.dart';
import '../../providers/providers.dart';
import '../../providers/dashboard_provider.dart';
import '../home/home_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String uid;
  final String name;
  final String email;

  const ProfileSetupScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
  });

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _isMale = true;
  ActivityLevel _activity = ActivityLevel.moderate;
  DietGoal _goal = DietGoal.maintain;
  bool _loading = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightCtrl.text);
    final height = double.tryParse(_heightCtrl.text);
    final age = int.tryParse(_ageCtrl.text);
    if (weight == null || height == null || age == null) return;

    setState(() => _loading = true);

    final bmr = CalorieCalculator.calculateBMR(
      weightKg: weight, heightCm: height, age: age, isMale: _isMale,
    );
    final tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: _activity.key);
    final target = CalorieCalculator.calculateTargetCalories(tdee: tdee, goal: _goal.name);
    final macros = CalorieCalculator.calculateMacros(targetCalories: target);

    final profile = UserProfile(
      uid: widget.uid,
      name: widget.name,
      email: widget.email,
      weightKg: weight,
      heightCm: height,
      age: age,
      isMale: _isMale,
      activityLevel: _activity,
      goal: _goal,
      dailyCalorieTarget: target,
      proteinTargetG: macros['protein']!,
      carbsTargetG: macros['carbs']!,
      fatTargetG: macros['fat']!,
    );

    try {
      await ref.read(userRepoProvider).saveUser(profile);
      ref.invalidate(userProfileProvider);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tell us about yourself', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text('Gender: '),
                  const SizedBox(width: 12),
                  ChoiceChip(label: const Text('Male'), selected: _isMale, onSelected: (_) => setState(() => _isMale = true)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Female'), selected: !_isMale, onSelected: (_) => setState(() => _isMale = false)),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid weight' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid height' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined)),
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid age' : null,
              ),
              const SizedBox(height: 20),

              Text('Activity Level', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ActivityLevel.values.map((a) {
                  return ChoiceChip(
                    label: Text(a.label),
                    selected: _activity == a,
                    onSelected: (_) => setState(() => _activity = a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text('Goal', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DietGoal.values.map((g) {
                  return ChoiceChip(
                    label: Text(g.label),
                    selected: _goal == g,
                    onSelected: (_) => setState(() => _goal = g),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
