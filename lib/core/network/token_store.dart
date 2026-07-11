class TokenStore {
  String? _token;

  String? get token => _token;

  void set(String token) => _token = token;
  void clear() => _token = null;
}
