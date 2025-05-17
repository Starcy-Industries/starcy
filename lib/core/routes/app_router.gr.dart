// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppTermsPage]
class AppTermsRoute extends PageRouteInfo<void> {
  const AppTermsRoute({List<PageRouteInfo>? children})
    : super(AppTermsRoute.name, initialChildren: children);

  static const String name = 'AppTermsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppTermsPage();
    },
  );
}

/// generated route for
/// [DataControlsPage]
class DataControlsRoute extends PageRouteInfo<void> {
  const DataControlsRoute({List<PageRouteInfo>? children})
    : super(DataControlsRoute.name, initialChildren: children);

  static const String name = 'DataControlsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DataControlsPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({Key? key, bool? isEdit, List<PageRouteInfo>? children})
    : super(
        OnboardingRoute.name,
        args: OnboardingRouteArgs(key: key, isEdit: isEdit),
        rawPathParams: {'id': isEdit},
        initialChildren: children,
      );

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => OnboardingRouteArgs(isEdit: pathParams.optBool('id')),
      );
      return OnboardingPage(key: args.key, isEdit: args.isEdit);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.key, this.isEdit});

  final Key? key;

  final bool? isEdit;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key, isEdit: $isEdit}';
  }
}

/// generated route for
/// [PersonalizationPage]
class PersonalizationRoute extends PageRouteInfo<void> {
  const PersonalizationRoute({List<PageRouteInfo>? children})
    : super(PersonalizationRoute.name, initialChildren: children);

  static const String name = 'PersonalizationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonalizationPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [UserTermsPage]
class UserTermsRoute extends PageRouteInfo<void> {
  const UserTermsRoute({List<PageRouteInfo>? children})
    : super(UserTermsRoute.name, initialChildren: children);

  static const String name = 'UserTermsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserTermsPage();
    },
  );
}
