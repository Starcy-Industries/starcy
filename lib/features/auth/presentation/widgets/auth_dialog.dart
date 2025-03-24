import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:starcy/features/auth/presentation/widgets/auth_dialog.dart';
import 'package:starcy/utils/sp.dart';
import 'package:starcy/core/services/background_task_handler.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({
    super.key,
    required this.isLogin,
  });

  final bool isLogin;

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final bool _isLogin = widget.isLogin;
  bool _isLoading = false;
  String? _errorMessage;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Login logic
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        print("response.user?.toJson() ${response.user?.toJson()}");
        print("response.session?.toJson() ${response.session?.toJson()}");
        if (response.user != null && mounted) {
          try {
            final res = await supabase
                .from('profiles')
                .select('data, agreedTermsAndConditions')
                .eq('id', response.user!.id)
                .single();
            if (context.mounted && mounted) {
              // Start background task after successful login
              // await BackgroundTaskService.startBackgroundTask();

              if (res['agreedTermsAndConditions'] == true) {
                Navigator.of(context).pop();
                context.router.push(const HomeRoute());
              } else {
                Navigator.of(context).pop();
                context.router.push(const AppTermsRoute());
              }
            }
          } catch (e) {
            if (context.mounted && mounted) {
              Navigator.of(context).pop();
              context.router.push(const AppTermsRoute());
            }
          }
        }
      } else {
        // Signup logic
        final response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null && mounted) {
          try {
            final res = await supabase
                .from('profiles')
                .select('data, agreedTermsAndConditions')
                .eq('id', response.user!.id)
                .single();
            if (context.mounted && mounted) {
              if (res['agreedTermsAndConditions'] == true) {
                Navigator.of(context).pop();
                context.router.push(const HomeRoute());
              } else {
                Navigator.of(context).pop();
                context.router.push(const AppTermsRoute());
              }
            }
          } catch (e) {
            if (context.mounted && mounted) {
              Navigator.of(context).pop();
              context.router.push(const AppTermsRoute());
            }
          }
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.appSp),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400.appSp,
          maxHeight: _isLogin ? 400.appSp : 480.appSp,
        ),
        padding: EdgeInsets.all(24.appSp),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Log in' : 'Sign up',
                style: TextStyle(
                  fontSize: 24.appSp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.appSp),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.appSp),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!_isLogin && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (!_isLogin) ...[
                SizedBox(height: 16.appSp),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              if (_errorMessage != null) ...[
                SizedBox(height: 16.appSp),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.appSp,
                  ),
                ),
              ],
              SizedBox(height: 24.appSp),
              _buildButton(
                text: _isLogin ? 'Log in' : 'Sign up',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                isLoading: _isLoading,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontSize: 15.appSp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.appSp),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.appSp),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.appSp),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.appSp),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.appSp,
          vertical: 12.appSp,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
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
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.appSp,
                width: 20.appSp,
                child: CircularProgressIndicator(
                  strokeWidth: 2.appSp,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Text(
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
