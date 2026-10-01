import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:ezbookkeeping/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Please check your inbox.'),
            backgroundColor: Color(0xFF00897B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final secondaryTextColor = onSurfaceColor.withValues(alpha: 0.65);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/ezbookkeeping-192.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.appName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // Headline: Forget Password?
                  Text(
                    context.l10n.forgetPassword,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Please enter your email address used for registration and we\'ll send you an email with a reset password link',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 24),

                  // E-mail Input Field
                  CustomTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: context.l10n.email,
                    hintText: 'Your email address',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.invalidEmail;
                      }
                      if (!value.contains('@')) {
                        return context.l10n.invalidEmail;
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Send Reset Link Button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _emailController,
                    builder: (context, value, _) {
                      final hasInput = value.text.trim().isNotEmpty;
                      return CustomButton(
                        text: 'Send Reset Link',
                        onPressed: _isLoading ? null : _handleSendResetLink,
                        isLoading: _isLoading,
                        backgroundColor: hasInput
                            ? primaryColor
                            : const Color(0xFFD8B296),
                        disabledBackgroundColor: const Color(0xFFD8B296),
                        disabledForegroundColor: Colors.white70,
                        height: 46,
                        borderRadius: BorderRadius.circular(8),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Back to login page link
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.login);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              size: 18,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Back to login page',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),

                  // Footer: Language Selector
                  Center(
                    child: InkWell(
                      onTap: () => LanguageSelectorModal.show(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          AppLanguage.fromLocale(
                            Localizations.localeOf(context),
                          ).nativeName,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Powered by footer
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        children: [
                          TextSpan(text: '${context.l10n.poweredBy} '),
                          TextSpan(
                            text: 'ezBookkeeping',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' v2.0.0-dev (8140384)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
