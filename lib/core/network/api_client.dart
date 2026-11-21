import 'package:dio/dio.dart';

class ApiClient {
  static String? jwtToken;

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://firestore.googleapis.com/v1/projects/pawon-cengek-app/databases/(default)/documents',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (jwtToken != null && jwtToken!.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $jwtToken';
              }
              return handler.next(options);
            },
            onError: (DioException e, handler) async {
              // Retry otomatis maksimal 2x untuk timeout / gangguan server 503
              final int retryCount = e.requestOptions.extra['retryCount'] ?? 0;
              if (retryCount < 2 &&
                  (e.type == DioExceptionType.connectionTimeout ||
                      e.response?.statusCode == 503)) {
                e.requestOptions.extra['retryCount'] = retryCount + 1;
                await Future.delayed(Duration(seconds: retryCount + 1));
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              }
              return handler.next(e);
            },
          ),
        );

  static String mapHttpError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Data permintaan tidak valid (400). Periksa kembali input Anda.';
      case 401:
        return 'Sesi berakhir atau tidak memiliki izin akses (401). Silakan login ulang.';
      case 404:
        return 'Data menu atau transaksi tidak ditemukan (404).';
      case 500:
        return 'Gangguan pada server (500). Data dialihkan ke penyimpanan lokal.';
      default:
        return 'Koneksi internet terganggu. Aplikasi berjalan dalam mode offline.';
    }
  }
}
