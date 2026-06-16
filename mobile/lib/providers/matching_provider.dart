import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../models/talent_model.dart';
import '../services/supabase_service.dart';
import '../services/matching_service.dart';

final matchingServiceProvider = Provider((ref) => MatchingService());

final talentMatchesProvider = FutureProvider.family<List<MatchModel>, String>(
  (ref, talentId) => ref
      .read(supabaseServiceProvider(ref) as ProviderListenable<dynamic>)
      .getMatchesForTalent(talentId),
);

final employerMatchesProvider = FutureProvider.family<List<MatchModel>, String>(
  (ref, employerId) => ref
      .read(supabaseServiceProvider(ref) as ProviderListenable<dynamic>)
      .getMatchesForEmployer(employerId),
);

final employerTalentsProvider =
    FutureProvider.family<List<TalentModel>, String>(
      (ref, employerId) =>
          ref.read(matchingServiceProvider).getTalentsForEmployer(employerId),
    );

// Helper
SupabaseService supabaseServiceProvider(ref) =>
    ref.read(Provider((ref) => SupabaseService()));
