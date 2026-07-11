import 'package:dio/dio.dart';

import 'token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStore, this.onUnauthorized});

  final TokenStore tokenStore;
  final void Function()? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = tokenStore.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
