import '../../services/supabase_service.dart';
import '../models/diet_plan.dart';

class DietPlanRepository {
  static const _table = 'diet_plans';

  Future<DietPlan?> getLatestPlan(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DietPlan.fromSupabase(response);
  }

  Future<void> savePlan(DietPlan plan) async {
    await SupabaseService.client.from(_table).upsert(plan.toSupabase());
  }
}
