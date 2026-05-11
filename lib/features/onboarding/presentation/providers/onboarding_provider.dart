import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  bool _hasSeenOnboarding = false;

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
    _currentPage = 0;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _currentPage = 0;
    notifyListeners();
  }

  void resetOnboarding() {
    _currentPage = 0;
    _hasSeenOnboarding = false;
    notifyListeners();
  }
}
