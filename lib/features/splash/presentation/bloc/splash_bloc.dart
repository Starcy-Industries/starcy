import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:starcy/utils/shared_prefs.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<InitializeSplash>(_onInitializeSplash);
  }

  Future<void> _onInitializeSplash(
    InitializeSplash event,
    Emitter<SplashState> emit,
  ) async {
    // Check if it's the first time opening the app
    final isFirstTime = await SharedPrefs.isFirstTime();
    
    emit(SplashCompleted(isFirstTime: isFirstTime));
  }
}