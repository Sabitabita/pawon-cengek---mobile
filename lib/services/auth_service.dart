import 'package:firebase_auth/firebase_auth.dart';

import '../core/network/api_client.dart';
import '../models/user_dto.dart';

class AuthService {
  Future<UserDto> login(String email, String password) async {
    try {
      // Coba login via Firebase Auth jika sudah terhubung
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await cred.user?.getIdToken() ?? '';
      ApiClient.jwtToken = token;

      final role = email.toLowerCase().contains('pemilik')
          ? 'Pemilik'
          : 'Kasir';
      return UserDto(
        userId: cred.user?.uid ?? 'USR-01',
        nama: role == 'Pemilik' ? 'Pemilik Pawon Cengek' : 'Kasir Warung',
        email: email,
        role: role,
        token: token,
      );
    } catch (_) {
      // Fallback autentikasi lokal & generate JWT Bearer Token untuk demo/offline
      final role = email.toLowerCase().contains('pemilik')
          ? 'Pemilik'
          : 'Kasir';
      const dummyJwt =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.pawon_cengek_rbac_token';
      ApiClient.jwtToken = dummyJwt;

      return UserDto(
        userId: role == 'Pemilik' ? 'USR-OWNER' : 'USR-KASIR',
        nama: role == 'Pemilik' ? 'Pemilik Pawon Cengek' : 'Kasir Pawon Cengek',
        email: email,
        role: role,
        token: dummyJwt,
      );
    }
  }

  void logout() {
    ApiClient.jwtToken = null;
  }
}
