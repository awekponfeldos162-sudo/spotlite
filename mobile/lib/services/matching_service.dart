import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/talent_model.dart';

class MatchingService {
  final _client = Supabase.instance.client;

  Future<List<TalentModel>> getTalentsForEmployer(
    String employerId, {
    String? secteur,
    String? localisation,
    int? salaireMax,
  }) async {
    final res = await _client.functions.invoke(
      'matching_engine',
      body: {
        'employer_id': employerId,
        'filtres': {
          if (secteur != null) 'secteur': secteur,
          if (localisation != null) 'localisation': localisation,
          if (salaireMax != null) 'salaire_max': salaireMax,
        },
      },
    );

    final talents = res.data['talents'] as List;
    return talents.map((t) => TalentModel.fromMap(t)).toList();
  }
}
