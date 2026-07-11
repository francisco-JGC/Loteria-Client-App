import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.session,
    this.errorMessage,
    this.isSubmitting = false,
  });

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.unauthenticated({String? errorMessage})
      : this._(
          status: AuthStatus.unauthenticated,
          errorMessage: errorMessage,
        );

  const AuthState.authenticated(AuthSession session)
      : this._(status: AuthStatus.authenticated, session: session);

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState._(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage, isSubmitting];
}
