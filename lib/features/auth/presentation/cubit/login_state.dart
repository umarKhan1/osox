import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial({this.isPasswordVisible = false, this.rememberMe = false});

  final bool isPasswordVisible;
  final bool rememberMe;

  @override
  List<Object?> get props => [isPasswordVisible, rememberMe];

  LoginInitial copyWith({bool? isPasswordVisible, bool? rememberMe}) {
    return LoginInitial(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  const LoginFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
