import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState({this.isPasswordVisible = false, this.rememberMe = false});

  final bool isPasswordVisible;
  final bool rememberMe;

  @override
  List<Object?> get props => [isPasswordVisible, rememberMe];

  LoginState copyWith({bool? isPasswordVisible, bool? rememberMe});
}

class LoginInitial extends LoginState {
  const LoginInitial({super.isPasswordVisible, super.rememberMe});

  @override
  LoginInitial copyWith({bool? isPasswordVisible, bool? rememberMe}) {
    return LoginInitial(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginLoading extends LoginState {
  const LoginLoading({super.isPasswordVisible, super.rememberMe});

  @override
  LoginLoading copyWith({bool? isPasswordVisible, bool? rememberMe}) {
    return LoginLoading(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginSuccess extends LoginState {
  const LoginSuccess({super.isPasswordVisible, super.rememberMe});

  @override
  LoginSuccess copyWith({bool? isPasswordVisible, bool? rememberMe}) {
    return LoginSuccess(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class LoginFailure extends LoginState {
  const LoginFailure(this.error, {super.isPasswordVisible, super.rememberMe});

  final String error;

  @override
  List<Object?> get props => [error, isPasswordVisible, rememberMe];

  @override
  LoginFailure copyWith({
    String? error,
    bool? isPasswordVisible,
    bool? rememberMe,
  }) {
    return LoginFailure(
      error ?? this.error,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}
