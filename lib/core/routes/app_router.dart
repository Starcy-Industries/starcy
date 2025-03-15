import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:starcy/features/auth/presentation/pages/app_terms_page.dart';
import 'package:starcy/features/auth/presentation/pages/login_page.dart';
import 'package:starcy/features/auth/presentation/pages/user_terms_page.dart';
import 'package:starcy/features/home/presentation/pages/home_page.dart';
import 'package:starcy/features/home/presentation/pages/personalization_page.dart';
import 'package:starcy/features/onboarding/presentation/onboarding_page.dart';
import 'package:starcy/features/splash/presentation/pages/splash_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          initial: true,
          path: '/',
        ),
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
        ),
        AutoRoute(
          page: AppTermsRoute.page,
          path: '/app-terms',
        ),
        AutoRoute(
          page: OnboardingRoute.page,
          path: '/onboarding',
        ),
        AutoRoute(
          page: UserTermsRoute.page,
          path: '/user-terms',
        ),
        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
        ),
        AutoRoute(
          page: PersonalizationRoute.page,
          path: '/personalization',
        ),
      ];
}
