import '../../domain/entities/auth_session.dart';
import 'authenticated_user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required AuthenticatedUserModel super.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['accessToken'] as String,
      user: AuthenticatedUserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'user': (user as AuthenticatedUserModel).toJson(),
      };
}
