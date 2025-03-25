import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/utils/sp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AppTermsPage extends StatefulWidget {
  const AppTermsPage({super.key});

  @override
  State<AppTermsPage> createState() => _AppTermsPageState();
}

class _AppTermsPageState extends State<AppTermsPage> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = DeviceUtils.getDeviceType() == DeviceType.desktop;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 65.appSp : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.appSp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to StarCy',
                              style: TextStyle(
                                fontSize: 26.appSp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.appSp),
                            Text(
                              'StarCy is your Artificially Intelligent friend that chats like a human and helps with your daily moments.',
                              style: TextStyle(
                                fontSize: 14.appSp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 24.appSp),
                            _buildSection(
                              'Responses can be inaccurate',
                              'StarCy may provide inaccurate information about people, places, or facts.',
                              Icons.flag_outlined,
                            ),
                            SizedBox(height: 24.appSp),
                            _buildSection(
                              'Keep it personal',
                              'Don\'t share sensitive info. Your chats are private, secure, and never used to train our models unless you say so.',
                              Icons.lock_outline_rounded,
                              hasLearnMore: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(24.appSp).copyWith(
                      bottom: isDesktop ? 48.appSp : 24.appSp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 12.appSp, right: 12.appSp),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text:
                                            'By continuing, you agree to our ',
                                      ),
                                      TextSpan(
                                        text: 'Terms',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse(
                                                'https://starcyindustries.com/terms-of-use'));
                                          },
                                      ),
                                      const TextSpan(
                                        text: ' and have read our ',
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse(
                                                'https://starcyindustries.com/privacy-policy'));
                                          },
                                      ),
                                      const TextSpan(
                                        text: '.',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 12.appSp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.appSp),
                        SizedBox(
                          width: double.infinity,
                          height: 48.appSp,
                          child: ElevatedButton(
                            onPressed: _acceptedTerms
                                ? () async {
                                    final supabase = Supabase.instance.client;
                                    final user =
                                        supabase.auth.currentSession?.user;
                                    print(user?.toJson());
                                    if (user == null) {
                                      toastification.show(
                                        context: context,
                                        title: const Text(
                                            'User not authenticated. Please verify your email first and login again',),
                                        autoCloseDuration:
                                            const Duration(seconds: 5),
                                      );
                                      context.router.replace(const LoginRoute());
                                      throw Exception('User not authenticated');
                                    }

                                    Map<String, dynamic>? response;

                                    try {
                                      response = await supabase
                                          .from('profiles')
                                          .select(
                                              'data, agreedTermsAndConditions')
                                          .eq('id', user.id)
                                          .single();
                                    } catch (e) {
                                      //
                                    }

                                    // Save to Supabase
                                    await supabase.from('profiles').upsert({
                                      'id': user.id,
                                      'email': user.email,
                                      'agreedTermsAndConditions':
                                          _acceptedTerms,
                                      'data': response?['data'] ?? {},
                                    });
                                    if (context.mounted) {
                                      context.router.replace(OnboardingRoute());
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(44),
                              ),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.appSp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, IconData icon,
      {bool hasLearnMore = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30.appSp,
              height: 30.appSp,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 30.appSp,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 12.appSp),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.appSp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 42.appSp),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: description,
                    children: [
                      if (hasLearnMore)
                        TextSpan(
                          text: ' Learn more.',
                          style: TextStyle(
                            fontSize: 14.appSp,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  'https://starcyindustries.com/privacy-policy'));
                            },
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 14.appSp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
