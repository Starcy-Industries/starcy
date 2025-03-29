import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/utils/sp.dart' as sp;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../onboarding/presentation/onboarding_page.dart';
import 'data_controls_page.dart';
import 'profile_section.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  static const double _kDesktopBreakpoint = 550;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final PageController _pageController = PageController();

  void _navigateToDataControls() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void _navigateBack() {
    _pageController.jumpTo(0);
  }

  void _edit(BuildContext context) {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.router.push(const LoginRoute());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log out. Please try again.')),
        );
      }
    }
  }

  void _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint('Failed to launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = 1.sw > SettingPage._kDesktopBreakpoint;
    return Scaffold(
      backgroundColor: isDesktop ? Colors.white : Colors.black,
      body: _SettingsContent(
        isDesktop: isDesktop,
        onEdit: () => _edit(context),
        onLogout: () => _handleLogout(context),
        onLaunchURL: _launchURL,
        onDataControlsTap: _navigateToDataControls,
        onBack: _navigateBack,
        pageController: _pageController,
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.isDesktop,
    required this.onEdit,
    required this.onLogout,
    required this.onLaunchURL,
    required this.onDataControlsTap,
    required this.pageController,
    required this.onBack,
  });

  final bool isDesktop;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final void Function(String) onLaunchURL;
  final VoidCallback onDataControlsTap;
  final PageController pageController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _BackgroundGradient(isDesktop: isDesktop),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _SettingsCard(
              isDesktop: isDesktop,
              onEdit: onEdit,
              onLogout: onLogout,
              onLaunchURL: onLaunchURL,
              onDataControlsTap: onDataControlsTap,
              pageController: pageController,
              onBack: onBack,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: isDesktop ? -0.95.sw : -0.95.sw,
      child: Container(
        width: 1.5.sw,
        height: 1.5.sw,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.75,
            colors: [
              isDesktop
                  ? Colors.transparent
                  : const Color(0xff424952).withValues(alpha: 0.7),
              isDesktop
                  ? Colors.transparent
                  : (Colors.black).withValues(alpha: 0.5)
            ],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDesktop,
    required this.onEdit,
    required this.onLogout,
    required this.onLaunchURL,
    required this.onDataControlsTap,
    required this.pageController,
    required this.onBack,
  });

  final bool isDesktop;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final void Function(String) onLaunchURL;
  final VoidCallback onDataControlsTap;
  final PageController pageController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: !isDesktop,
      child: _SettingsCardContent(
        isDesktop: isDesktop,
        onEdit: onEdit,
        onLogout: onLogout,
        onLaunchURL: onLaunchURL,
        onDataControlsTap: onDataControlsTap,
        pageController: pageController,
        onBack: onBack,
      ),
    );
  }
}

class _SettingsCardContent extends StatelessWidget {
  const _SettingsCardContent({
    required this.isDesktop,
    required this.onEdit,
    required this.onLogout,
    required this.onLaunchURL,
    required this.onDataControlsTap,
    required this.pageController,
    required this.onBack,
  });

  final bool isDesktop;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final void Function(String) onLaunchURL;
  final VoidCallback onDataControlsTap;
  final PageController pageController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: isDesktop ? 65.appSp : 60.appSp,
          child: Image.asset(
            "assets/images/starcyindustries.png",
            color: isDesktop ? Colors.black : Colors.white,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.appSp).copyWith(
                top: isDesktop ? 12.appSp : 16.appSp,
                bottom: isDesktop ? 0.appSp : 16.appSp),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDesktop ? Colors.black : const Color(0xff1E1E1E),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isDesktop ? 28.appSp : 32),
                bottom: Radius.circular(isDesktop ? 0 : 32),
              ),
              border: Border.all(
                color: Colors.grey.shade800.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 50),
                      const ProfileSection(),
                      _AccountSection(
                          onEdit: onEdit, onDataControlsTap: onDataControlsTap),
                      _AboutSection(onLaunchURL: onLaunchURL),
                      _LogoutSection(onLogout: onLogout),
                      SizedBox(height: isDesktop ? 16.appSp : 24.appSp),
                    ],
                  ),
                ),
                DataControlsPage(
                  isDesktop: isDesktop,
                  onPressed: onBack,
                ),
                OnboardingPage(
                  isEdit: true,
                  onBack: onBack,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.onEdit,
    required this.onDataControlsTap,
  });

  final VoidCallback onEdit;
  final VoidCallback onDataControlsTap;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentSession?.user;
    final email = user?.email ?? 'N/A';

    return _SettingsSection(
      title: 'ACCOUNT',
      children: [
        SettingItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: email,
          showArrow: false,
        ),
        const SettingItem(
          icon: Icons.add_circle_outline,
          title: 'Subscription',
          value: 'Free Plan',
          showArrow: false,
        ),
        SettingItem(
          icon: Icons.person_outline,
          title: 'Personalization',
          showArrow: true,
          onTap: onEdit,
        ),
        SettingItem(
          icon: Icons.data_usage_outlined,
          title: 'Data Controls',
          showArrow: true,
          onTap: onDataControlsTap,
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.onLaunchURL});

  final void Function(String) onLaunchURL;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'ABOUT',
      children: [
        SettingItem(
          icon: Icons.help_outline,
          title: 'Help Center',
          showArrow: false,
          onTap: () =>
              onLaunchURL('https://starcyindustries.com/connect-with-us'),
        ),
        SettingItem(
          icon: Icons.book,
          title: 'Terms of Use',
          showArrow: false,
          onTap: () => onLaunchURL('https://starcyindustries.com/terms-of-use'),
        ),
        SettingItem(
          icon: Icons.lock_rounded,
          title: 'Privacy Policy',
          showArrow: false,
          onTap: () =>
              onLaunchURL('https://starcyindustries.com/privacy-policy'),
        ),
        const SettingItem(
          icon: Icons.fiber_manual_record,
          title: 'Version',
          value: '1.2025.012',
          showArrow: false,
          isLast: true,
        ),
      ],
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.appSp),
      child: Column(
        children: [
          SettingItem(
            icon: Icons.login_rounded,
            title: 'Log out',
            showArrow: false,
            isLast: true,
            onTap: onLogout,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.appSp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: Column(children: children)),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.showArrow = true,
    this.isLast = false,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? value;
  final bool showArrow;
  final bool isLast;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.appSp),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.appSp),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 44, 44, 46),
                  borderRadius: BorderRadius.circular(8.appSp),
                ),
                child: Icon(
                  icon,
                  color: color ?? Colors.grey.shade400,
                  size: 20.appSp,
                  weight: 350,
                ),
              ),
              SizedBox(width: 16.appSp),
              Text(
                title,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 14.appSp,
                ),
              ),
              if (value != null || showArrow) ...[
                SizedBox(width: 16.appSp),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (value != null)
                        Expanded(
                          child: Text(
                            value!,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14.appSp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      if (showArrow)
                        Padding(
                          padding: EdgeInsets.only(left: 4.appSp),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade600,
                            size: 22.appSp,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
