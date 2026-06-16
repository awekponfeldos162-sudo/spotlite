import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/talent_model.dart';
import '../models/employer_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());

final talentProvider = FutureProvider<TalentModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  // ✅ Comparer l'enum directement
  if (user.role != UserRole.talent) return null;
  return ref.read(supabaseServiceProvider).getTalentByProfileId(user.id);
});

final employerProvider = FutureProvider<EmployerModel?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  // ✅ Comparer l'enum directement
  if (user.role != UserRole.employer) return null;
  return ref.read(supabaseServiceProvider).getEmployerByProfileId(user.id);
});
