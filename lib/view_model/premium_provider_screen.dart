import 'package:flutter/material.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;
  void setIsPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }
}
