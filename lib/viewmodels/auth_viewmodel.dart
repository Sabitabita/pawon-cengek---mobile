import 'package:flutter/material.dart';

import '../models/user_dto.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserDto? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isPemilik => currentUser?.role == 'Pemilik';

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Email dan kata sandi wajib diisi.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authService.login(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Gagal masuk: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _authService.logout();
    currentUser = null;
    notifyListeners();
  }
}
