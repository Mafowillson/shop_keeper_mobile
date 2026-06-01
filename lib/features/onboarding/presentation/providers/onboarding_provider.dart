import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class OnboardingProvider extends ChangeNotifier {
  static const _key = 'has_seen_onboarding';

  final SharedPreferences _prefs;
  int _currentPage = 0;
  late bool _hasSeenOnboarding;

  OnboardingProvider(this._prefs) {
    _hasSeenOnboarding = _prefs.getBool(_key) ?? false;
  }

  int get currentPage => _currentPage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  void nextPage() {
    if (_currentPage < 4) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void skipOnboarding() {
    _hasSeenOnboarding = true;
    _prefs.setBool(_key, true);
    _currentPage = 0;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _prefs.setBool(_key, true);
    _currentPage = 0;
    notifyListeners();
  }

  void resetOnboarding() {
    _hasSeenOnboarding = false;
    _currentPage = 0;
    _prefs.setBool(_key, false);
    notifyListeners();
  }
}
