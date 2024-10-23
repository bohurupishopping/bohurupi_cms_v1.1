import 'package:flutter/material.dart';

class UserRoleModel with ChangeNotifier {
  String _userRole = '';

  String get userRole => _userRole;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }
}
