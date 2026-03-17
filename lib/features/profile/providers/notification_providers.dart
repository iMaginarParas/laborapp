import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/constants/api_constants.dart';
import 'package:flutter_app/shared/models/notification.dart';
import 'package:flutter_app/features/home/providers/home_providers.dart';
import 'package:flutter/foundation.dart';


final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  try {
    final client = ref.watch(dioClientProvider);
    final response = await client.get(ApiConstants.notifications);
    if (response.data is List) {
      return (response.data as List).map((e) => AppNotification.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    debugPrint("Error fetching notifications: $e");
    return [];
  }
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.read).length;
});
