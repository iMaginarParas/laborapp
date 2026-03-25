import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/language_provider.dart';
import '../../../core/services/storage_service.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLang;

  final List<Map<String, String>> _languages = [
    {"name": "English", "native": "English", "code": "en"},
    {"name": "Hindi", "native": "हिन्दी", "code": "hi"},
    {"name": "Marathi", "native": "मराठी", "code": "mr"},
    {"name": "Tamil", "native": "தமிழ்", "code": "ta"},
    {"name": "Telugu", "native": "తెలుగు", "code": "te"},
    {"name": "Bengali", "native": "বাংলা", "code": "bn"},
    {"name": "Kannada", "native": "ಕನ್ನಡ", "code": "kn"},
    {"name": "Gujarati", "native": "ગુજરાતી", "code": "gu"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentCode = ref.read(localeProvider).languageCode;
      setState(() {
        _selectedLang = currentCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Logo Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Column(
              children: [
                const Text(
                  "Laborgro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your trusted work partner",
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.handshake, color: Colors.orangeAccent, size: 20),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Text(
                    "Choose Your Language",
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.text,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "अपनी भाषा चुनें • ನಿಮ್ಮ ಭಾಷೆ ಆರಿಸಿ • உங்கள் மொழி தேர்வு",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  
                  // Language Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = _selectedLang == lang['code'];
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLang = lang['code']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : const Color(0xFFEBF2F7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : Colors.blue.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lang['native']!,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white70 : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Voice Assistance Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic, color: Colors.grey, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Can't read? Use Voice!",
                                style: TextStyle(
                                  color: Color(0xFFF14646), 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tap the 🎙️ mic button on any screen and speak in your language",
                                style: TextStyle(
                                  color: Colors.grey.shade600, 
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedLang != null) {
                    final newLocale = Locale(_selectedLang!);
                    ref.read(localeProvider.notifier).state = newLocale;
                    final langName = _languages.firstWhere((l) => l['code'] == _selectedLang)['name']!;
                    StorageService.setLanguage(langName);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                  shadowColor: AppColors.primaryColor.withOpacity(0.5),
                ),
                child: const Text(
                  "Continue →",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
