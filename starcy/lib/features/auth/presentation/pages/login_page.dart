import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/features/auth/presentation/widgets/auth_dialog.dart';
import 'package:starcy/utils/sp.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final bool _isAppleLoading = false;
  bool _isGoogleLoading = false;
  final List<String> _phrases = [
    'StarCy',
    'Your First Artificially\nIntelligent Friend',
    'AI that feels Human',
    'Let\'s Talk.',
  ];

  late AnimationController _animationController;
  late Animation<double> _cursorAnimation;

  String _currentTextLine1 = '';
  String _currentTextLine2 = '';
  int _phraseIndex = 0;
  bool _isTyping = true;
  Timer? _timer;
  bool _isSecondLine = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cursorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    _startTypingAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTypingAnimation() {
    final String targetPhrase = _phrases[_phraseIndex];
    final List<String> lines = targetPhrase.split('\n');
    final String targetLine1 = lines.isNotEmpty ? lines[0] : '';
    final String targetLine2 = lines.length > 1 ? lines[1] : '';

    if (_isTyping) {
      if (_currentTextLine1.length < targetLine1.length) {
        _timer = Timer(const Duration(milliseconds: 60), () {
          setState(() {
            _currentTextLine1 =
                targetLine1.substring(0, _currentTextLine1.length + 1);
            _isSecondLine = false;
          });
          _startTypingAnimation();
        });
      } else if (targetLine2.isNotEmpty &&
          _currentTextLine2.length < targetLine2.length) {
        _timer = Timer(const Duration(milliseconds: 60), () {
          setState(() {
            _currentTextLine2 =
                targetLine2.substring(0, _currentTextLine2.length + 1);
            _isSecondLine = true;
          });
          _startTypingAnimation();
        });
      } else {
        _timer = Timer(const Duration(milliseconds: 1500), () {
          setState(() {
            _isTyping = false;
          });
          _startTypingAnimation();
        });
      }
    } else {
      if (_currentTextLine2.isNotEmpty) {
        _timer = Timer(const Duration(milliseconds: 45), () {
          setState(() {
            _currentTextLine2 =
                _currentTextLine2.substring(0, _currentTextLine2.length - 1);
            _isSecondLine = _currentTextLine2.isNotEmpty;
          });
          _startTypingAnimation();
        });
      } else if (_currentTextLine1.isNotEmpty) {
        _timer = Timer(const Duration(milliseconds: 30), () {
          setState(() {
            _currentTextLine1 =
                _currentTextLine1.substring(0, _currentTextLine1.length - 1);
            _isSecondLine = false;
          });
          _startTypingAnimation();
        });
      } else {
        _timer = Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _phraseIndex = (_phraseIndex + 1) % _phrases.length;
            _isTyping = true;
            _isSecondLine = false;
          });
          _startTypingAnimation();
        });
      }
    }
  }

  final supabase = Supabase.instance.client;
  Future<void> _nativeGoogleSignIn() async {
    try {
      setState(() {
        _isGoogleLoading = true;
      });

      /// Web Client ID that you registered with Google Cloud.
      const webClientId =
          '1063915694908-isdokkr3bhct06v3vv5guqm0cpfa5jao.apps.googleusercontent.com';

      /// iOS Client ID that you registered with Google Cloud.
      const iosClientId =
          '1063915694908-dslu9c4locf41aqjrv2nqb5vhj8t057h.apps.googleusercontent.com';

      // Google sign in on Android will work without providing the Android
      // Client ID registered on Google Cloud.

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      final userId = supabase.auth.currentSession?.user.id;
      if (context.mounted && mounted && userId != null) {
        context.router.push(const AppTermsRoute());
      }
    } catch (e) {
      // Handle error
      debugPrint('Google sign in error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentTextLine1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 26.appSp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 4.appSp),
                                AnimatedBuilder(
                                  animation: _cursorAnimation,
                                  builder: (context, child) {
                                    if (_isSecondLine) return const SizedBox();
                                    return Transform.translate(
                                      offset: Offset(
                                        _isTyping ? 0 : -4.appSp,
                                        0,
                                      ),
                                      child: Container(
                                        width: 24.appSp,
                                        height: 24.appSp,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (_currentTextLine2.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentTextLine2,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 26.appSp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(width: 4.appSp),
                                  AnimatedBuilder(
                                    animation: _cursorAnimation,
                                    builder: (context, child) {
                                      if (!_isSecondLine) {
                                        return const SizedBox();
                                      }
                                      return Transform.translate(
                                        offset: Offset(
                                          _isTyping ? 0 : -4.appSp,
                                          0,
                                        ),
                                        child: Container(
                                          width: 24.appSp,
                                          height: 24.appSp,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.appSp),
                    topRight: Radius.circular(28.appSp),
                  ),
                ),
                padding: EdgeInsets.all(24.appSp),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SocialButton(
                        text: 'Continue with Google',
                        image: 'assets/images/google_logo.png',
                        backgroundColor: const Color(0xFF424242),
                        textColor: Colors.white,
                        isLoading: _isGoogleLoading,
                        onPressed: () async {
                          setState(() {
                            _isGoogleLoading = true;
                          });
                          try {
                            if (!kIsWeb &&
                                (Platform.isAndroid || Platform.isIOS)) {
                              await _nativeGoogleSignIn();
                              return;
                            } else {
                              await supabase.auth
                                  .signInWithOAuth(OAuthProvider.google);

                              return;
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isGoogleLoading = false;
                              });
                            }
                          }
                        },
                      ),
                      SizedBox(height: 12.appSp),
                      _CustomButton(
                        text: 'Sign up',
                        backgroundColor: const Color(0xFF424242),
                        textColor: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const AuthDialog(isLogin: false),
                          );
                        },
                      ),
                      SizedBox(height: 12.appSp),
                      _CustomButton(
                        text: 'Log in',
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        borderColor: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const AuthDialog(isLogin: true),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String image;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final FontWeight? fontWeight;
  final bool isLoading;

  const _SocialButton({
    required this.text,
    required this.image,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.fontWeight,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.appSp,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.appSp),
          ),
          disabledBackgroundColor: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                height: 20.appSp,
                width: 20.appSp,
                child: CircularProgressIndicator(
                  strokeWidth: 2.appSp,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else
              Image.asset(
                image,
                height: 20.appSp,
                width: 20.appSp,
              ),
            SizedBox(width: 12.appSp),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 15.appSp,
                fontWeight: fontWeight ?? FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _CustomButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.appSp,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.appSp),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15.appSp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
