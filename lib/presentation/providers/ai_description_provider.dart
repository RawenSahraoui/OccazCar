import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_description_service.dart';

final aiDescriptionServiceProvider = Provider<AiDescriptionService>((ref) {
  return AiDescriptionService();
});
