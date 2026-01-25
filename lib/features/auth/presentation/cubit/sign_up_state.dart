import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  @override
  List<Object?> get props => [isPasswordVisible, isConfirmPasswordVisible];

  SignUpState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  });
}

class SignUpInitial extends SignUpState {
  const SignUpInitial({
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  @override
  SignUpInitial copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpInitial(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

class SignUpLoading extends SignUpState {
  const SignUpLoading({
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  @override
  SignUpLoading copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpLoading(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

class SignUpSuccess extends SignUpState {
  const SignUpSuccess({
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  @override
  SignUpSuccess copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpSuccess(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

class SignUpFailure extends SignUpState {
  const SignUpFailure(
    this.error, {
    super.isPasswordVisible,
    super.isConfirmPasswordVisible,
  });

  final String error;

  @override
  List<Object?> get props => [
    error,
    isPasswordVisible,
    isConfirmPasswordVisible,
  ];

  @override
  SignUpFailure copyWith({
    String? error,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpFailure(
      error ?? this.error,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}
