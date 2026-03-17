import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/shared/models/notification.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final client = ref.watch(dioClientProvider);
  final response = await client.get('notifications');
  return (response.data as List).map((e) => AppNotification.fromJson(e)).toList();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.read).length;
});
