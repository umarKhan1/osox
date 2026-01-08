import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> startAnimation() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    emit(SplashCompleted());
  }
}
