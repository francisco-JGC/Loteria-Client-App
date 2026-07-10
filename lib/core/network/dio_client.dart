import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class DioClient {
  DioClient({Logger? logger}) : _logger = logger ?? Logger() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.maybeGet('API_BASE_URL') ?? '',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('→ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (err, handler) {
          _logger.e(
            '✗ ${err.requestOptions.method} ${err.requestOptions.uri}',
            error: err,
          );
          handler.next(err);
        },
      ),
    );
  }

  late final Dio _dio;
  final Logger _logger;

  Dio get instance => _dio;
}
