import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Métodos helpers para navegación específica
  void goToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  void goToProducts() {
    _currentIndex = 1;
    notifyListeners();
  }

  void goToCart() {
    _currentIndex = 2;
    notifyListeners();
  }

  void goToProfile() {
    _currentIndex = 3;
    notifyListeners();
  }
}