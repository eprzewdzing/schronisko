import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inzynierka/models/inquiry.dart';

class InquiryService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Inquiry>> getInquiries() async {
    final response = await _client.from('Inquiry').select();

    return (response as List)
        .map((json) => Inquiry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addInquiry(Map<String, dynamic> data) async {
    await _client.from('Inquiry').insert(data);
  }
}