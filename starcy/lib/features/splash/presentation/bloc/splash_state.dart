part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashCompleted extends SplashState {
  final bool isFirstTime;
  
  const SplashCompleted({required this.isFirstTime});
  
  @override
  List<Object> get props => [isFirstTime];
}