import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_translations.dart';
import '../../providers/mood_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/mood_model.dart';
import '../../services/data_loader_service.dart';
import 'mood_result_screen.dart';

class MoodSelectionScreen extends ConsumerStatefulWidget {
  const MoodSelectionScreen({super.key});
  @override
  ConsumerState<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends ConsumerState<MoodSelectionScreen> {
  String? selectedMoodId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    final moods = await DataLoaderService().loadMoodList();
    if (mounted) {
      ref.read(moodProvider.notifier).setMoods(moods);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(moodProvider).moods;
    final selectedMood = selectedMoodId != null ? moods.cast<MoodModel?>().firstWhere((m) => m?.id == selectedMoodId, orElse: () => null) : null;
    final lang = ref.watch(languageProvider);

    // Get bottom padding for gesture navigation bar
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : 34.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F8),
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.1))),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF134E4A)),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('💭 ', style: TextStyle(fontSize: 14)), Text(AppTranslations.get('mood', lang), style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w600))]),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(AppTranslations.get('by_mood', lang), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF134E4A))),
                  const SizedBox(height: 8),
                  Text(AppTranslations.get('how_do_you_feel', lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF134E4A))),
                  const SizedBox(height: 4),
                  Text(AppTranslations.get('special_ayah_dhikr', lang), style: const TextStyle(fontSize: 14, color: Color(0xFF5F9EA0))),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Grid content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: moods.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
                        itemBuilder: (context, index) {
                          final mood = moods[index];
                          final isSelected = selectedMoodId == mood.id;
                          return GestureDetector(
                            onTap: () => setState(() => selectedMoodId = mood.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0D9488).withValues(alpha: 0.15) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF0D9488).withValues(alpha: 0.1), width: isSelected ? 2 : 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                                  const SizedBox(height: 8),
                                  Text(mood.getLabel(lang), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF134E4A)), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            // Bottom button with manual bottom padding
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              child: ElevatedButton(
                onPressed: selectedMood != null ? () { ref.read(moodProvider.notifier).selectMood(selectedMood); Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodResultScreen())); } : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), disabledBackgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.4), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: Text('${AppTranslations.get('continue_button', lang)} →', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
