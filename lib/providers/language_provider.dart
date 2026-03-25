import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

final localeProvider = StateProvider<Locale>((ref) {
  final lang = StorageService.getLanguage();
  return Locale(lang == 'हिन्दी' ? 'hi' : 'en');
});

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('hi'),
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी';
      case 'en':
      default:
        return 'English';
    }
  }
}

class Strings {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'home': 'Home',
      'search': 'Search',
      'bookings': 'Bookings',
      'profile': 'Profile',
      'good_morning': 'Good morning',
      'services': 'Services',
      'see_all': 'See all',
      'nearby_workers': 'Nearby Workers',
      'latest_jobs': 'Latest Jobs',
      'change': 'Change',
      'logout': 'Logout',
      'working_on_it': 'We are working on this!',
      'applied': 'Applied',
      'post_job': 'Post Job',
      'my_bookings': 'My Bookings',
      'my_applications': 'My Applications',
      'my_job_posts': 'My Job Posts',
      'notifications': 'Notifications',
      'available_now': 'Available Now',
      'top_rated': 'Top Rated',
      'lowest_price': 'Lowest Price',
      'highest_paying': 'Highest Paying',
      'latest_posts': 'Latest Posts',
      'find_workers': 'Find Workers',
      'available_jobs': 'Available Jobs',
      'verified': 'Verified',
      'search_placeholder': 'Search painter, cleaner...',
      'find_workers_hint': 'Painter, cleaner, guard...',
      'find_jobs_hint': 'Design, plumber, security...',
    },
    'hi': {
      'home': 'मुखपृष्ठ (Home)',
      'search': 'खोजें',
      'bookings': 'बुकिंग',
      'profile': 'प्रोफ़ाइल',
      'good_morning': 'नमस्ते',
      'services': 'सेवाएं',
      'see_all': 'सभी देखें',
      'nearby_workers': 'आस-पास के कर्मचारी',
      'latest_jobs': 'नवीनतम नौकरियां',
      'change': 'बदलें',
      'logout': 'लॉग आउट',
      'working_on_it': 'हम इस पर काम कर रहे हैं!',
      'applied': 'आवेदन किया',
      'post_job': 'नौकरी पोस्ट करें',
      'my_bookings': 'मेरी बुकिंग',
      'my_applications': 'मेरे आवेदन',
      'my_job_posts': 'मेरी पोस्ट की गई नौकरियां',
      'notifications': 'सूचनाएं',
      'available_now': 'अभी उपलब्ध है',
      'top_rated': 'शीर्ष रेटेड',
      'lowest_price': 'सबसे कम कीमत',
      'highest_paying': 'सबसे अधिक भुगतान',
      'latest_posts': 'नवीनतम पोस्ट',
      'find_workers': 'कर्मचारी खोजें',
      'available_jobs': 'उपलब्ध नौकरियां',
      'verified': 'सत्यापित',
      'search_placeholder': 'पेंटर, क्लीनर खोजें...',
      'find_workers_hint': 'पेंटर, क्लीनर, गार्ड...',
      'find_jobs_hint': 'डिज़ाइन, प्लंबर, सुरक्षा...',
    },
  };

  static String of(BuildContext context, String key) {
    return _localizedValues[Localizations.localeOf(context).languageCode]?[key] ?? key;
  }
}
