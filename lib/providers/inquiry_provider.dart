import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inzynierka/models/inquiry.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/inquiry_service.dart';

final inquiryServiceProvider = Provider<InquiryService>((ref) {
  return InquiryService();
});

final inquiryListProvider = FutureProvider<List<Inquiry>>((ref) async {
  final service = ref.watch(inquiryServiceProvider);
  return service.getInquiries();
});

final newInquiriesProvider = Provider<AsyncValue<List<Inquiry>>>((ref) {
  final inquiriesAsync = ref.watch(inquiryListProvider);
  return inquiriesAsync.whenData(
        (inquiries) => inquiries.where((i) => i.status == 'new').toList(),
  );
});

class InquiryController {
  InquiryController(this.ref);

  final Ref ref;

  Future<void> submit({
    String? animalId,
    required String content,
  }) async {
    final person = await ref.read(currentPersonProvider.future);
    if (person == null) return;

    final service = ref.read(inquiryServiceProvider);
    await service.addInquiry({
      'animal_id': animalId,
      'person_id': person.id,
      'content': content,
      'status': 'new',
    });

    ref.invalidate(myInquiriesProvider);
    ref.invalidate(inquiryListProvider);
  }
}

final inquiryControllerProvider = Provider<InquiryController>((ref) {
  return InquiryController(ref);
});

final myInquiriesProvider = FutureProvider<List<Inquiry>>((ref) async {
  final person = await ref.watch(currentPersonProvider.future);
  if (person == null) return [];

  final service = ref.watch(inquiryServiceProvider);
  return service.getInquiriesForPerson(person.id);
});

class StaffInquiryController {
  StaffInquiryController(this.ref);

  final Ref ref;

  Future<void> answer(String inquiryId, String answer) async {
    final service = ref.read(inquiryServiceProvider);
    await service.answerInquiry(inquiryId, answer);

    ref.invalidate(inquiryListProvider);
    ref.invalidate(myInquiriesProvider);
  }
}

final staffInquiryControllerProvider = Provider<StaffInquiryController>((ref) {
  return StaffInquiryController(ref);
});