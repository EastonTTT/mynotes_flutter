import 'package:flutter/foundation.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait...',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user, {required super.isLoading});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    String? loadingText,
  }) : super(loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggedOutFailure extends AuthState {
  final Exception exception;
  const AuthStateLoggedOutFailure(this.exception, {required super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception, {required super.isLoading});
}

class AuthStateRegisteringFailure extends AuthState {
  final Exception exception;
  const AuthStateRegisteringFailure(this.exception, {required super.isLoading});
}
