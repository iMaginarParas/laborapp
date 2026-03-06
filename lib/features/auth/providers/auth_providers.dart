import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/home_providers.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/user.dart';

final authRepositoryProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRepository(client);
});

final authStateProvider = StateProvider<String?>((ref) => null);

final currentUserProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getMe();
});
