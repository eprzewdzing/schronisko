import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/adopter_preferences.dart';
import 'package:inzynierka/models/match_criteria.dart';

class AdopterPreferencesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AdopterPreferences?> getPreferences(String personId) async {
    final response = await _client
        .from('AdopterPreferences')
        .select()
        .eq('person_id', personId)
        .maybeSingle();

    if (response == null) return null;
    return AdopterPreferences.fromJson(response);
  }

  Future<void> savePreferences({
    required String personId,
    required MatchCriteria criteria,
  }) async {
    await _client.from('AdopterPreferences').upsert(
      {
        'person_id': personId,
        'preferred_species': criteria.preferredSpecies.toList(),
        'preferred_sizes': criteria.preferredSizes.toList(),
        'desired_traits': criteria.desiredTraits.toList(),
        'avoided_traits': criteria.avoidedTraits.toList(),
        'has_no_experience': criteria.hasNoExperience,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'person_id',
    );
  }
}