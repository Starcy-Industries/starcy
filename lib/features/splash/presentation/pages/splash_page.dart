import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(InitializeSplash()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            // Check if user is authenticated
            final user = Supabase.instance.client.auth.currentSession?.user;
            if (user == null) {
              context.router.replace(const LoginRoute());
              return;
            }
            // User is authenticated, check their profile data
            Supabase.instance.client
                .from('profiles')
                .select('data, agreedTermsAndConditions')
                .eq('id', user.id)
                .single()
                .then((response) {
              // User has not complete onboarding
              if (response['agreedTermsAndConditions'] == null) {
                context.router.replace(const AppTermsRoute());
                return;
              }

              // Check if profile exists and data.step is 'home'
              final data = response['data'] as Map<String, dynamic>?;
              if (data != null && data['step'] == 'home') {
                // User has completed onboarding
                context.router.replace(const HomeRoute());
                return;
              }

              // User needs to complete onboarding
              context.router.replace(OnboardingRoute());
              return;
            }).catchError((error) {
              // Profile doesn't exist or other error, redirect to onboarding
              if (context.mounted) {
                context.router.replace(const AppTermsRoute());
              }
            });
          }
        },
        child: const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
