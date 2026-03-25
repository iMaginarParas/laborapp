import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

final localeProvider = StateProvider<Locale>((ref) {
  final langCode = StorageService.getLanguageCode(); // Expected to be 'hi' or 'en'
  return Locale(langCode ?? 'en');
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
      'job_details': 'Job Details',
      'salary': 'Salary',
      'openings': 'Openings',
      'type': 'Type',
      'full_time': 'Full-time',
      'description': 'Description',
      'apply_now': 'Apply for this Job',
      'apply_success': 'Application submitted successfully! ✅',
      'apply_failed': 'Failed to apply.',
      'own_job_msg': 'This is your own job posting.',
      'dismiss': 'DISMISS',
      'experience': 'Experience',
      'location': 'Location',
      'category': 'Category',
      'skills': 'Skills',
      'hourly_rate': 'Hourly Rate',
      'save_changes': 'Save Changes',
      'edit_profile': 'Edit Worker Profile',
      'create_profile': 'Create Worker Profile',
      'edit_profile_short': 'Edit Profile',
      'professional_profile': 'Professional Profile',
      'help_center': 'Help Center',
      'privacy_policy': 'Privacy Policy',
      'location_not_set': 'Location not set',
      'visible_to_employers': 'Visible to employers',
      'now_available': 'You are now available',
      'now_unavailable': 'You are now unavailable',
      'failed_update_status': 'Failed to update status',
      'could_not_load_profile': 'Could not load profile',
      'retry': 'Retry',
      'choose_language': 'Choose Your Language',
      'trusted_partner': 'Your trusted work partner',
      'continue': 'Continue',
      'cant_read_voice': "Can't read? Use Voice!",
      'mic_hint': 'Tap the 🎙️ mic button on any screen and speak in your language',
      'apply_now_arrow': 'Apply Now →',
      'view_details_arrow': 'View Details →',
      'posted_recently': 'Posted recently',
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
      'job_details': 'नौकरी का विवरण',
      'salary': 'वेतन (Salary)',
      'openings': 'रिक्तियां',
      'type': 'प्रकार',
      'full_time': 'पूर्णकालिक (Full-time)',
      'description': 'विवरण',
      'apply_now': 'इस नौकरी के लिए आवेदन करें',
      'apply_success': 'आवेदन सफलतापूर्वक जमा हो गया! ✅',
      'apply_failed': 'आवेदन करने में विफल।',
      'own_job_msg': 'यह आपकी अपनी नौकरी की पोस्टिंग है।',
      'dismiss': 'खारिज करें',
      'experience': 'अनुभव',
      'location': 'स्थान',
      'category': 'श्रेणी',
      'skills': 'कौशल',
      'hourly_rate': 'प्रति घंटा दर',
      'save_changes': 'बदलाव सहेजें',
      'edit_profile': 'कार्यकर्ता प्रोफ़ाइल संपादित करें',
      'create_profile': 'कार्यकर्ता प्रोफ़ाइल बनाएं',
      'edit_profile_short': 'प्रोफ़ाइल संपादित करें',
      'professional_profile': 'पेशेवर प्रोफ़ाइल',
      'help_center': 'सहायता केंद्र',
      'privacy_policy': 'गोपनीयता नीति',
      'location_not_set': 'स्थान निर्धारित नहीं है',
      'visible_to_employers': 'नियोक्ताओं को दिखाई देता है',
      'now_available': 'अब आप उपलब्ध हैं',
      'now_unavailable': 'अब आप अनुपलब्ध हैं',
      'failed_update_status': 'स्थिति अपडेट करने में विफल',
      'could_not_load_profile': 'प्रोफ़ाइल लोड नहीं हो सकी',
      'retry': 'पुनः प्रयास करें',
      'choose_language': 'अपनी भाषा चुनें',
      'trusted_partner': 'आपका भरोसेमंद काम का साथी',
      'continue': 'जारी रखें',
      'cant_read_voice': 'पढ़ नहीं सकते? आवाज़ का उपयोग करें!',
      'mic_hint': 'किसी भी स्क्रीन पर 🎙️ माइक बटन दबाएं और अपनी भाषा में बोलें',
      'apply_now_arrow': 'अभी आवेदन करें →',
      'view_details_arrow': 'विवरण देखें →',
      'posted_recently': 'हाल ही में पोस्ट किया गया',
    },
  };

  static String of(BuildContext context, String key) {
    return _localizedValues[Localizations.localeOf(context).languageCode]?[key] ?? key;
  }
}
