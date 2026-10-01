import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_state.dart';
import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:ezbookkeeping/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthenticationBloc _authBloc;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthenticationBloc>();
  }

  void _handleAuthState(BuildContext context, AuthenticationState state) {
    if (!mounted) return;
    if (state is AuthenticationLoading) {
      setState(() => _isLoading = true);
    } else if (state is AuthenticationSuccess) {
      setState(() => _isLoading = false);
      final notification = state.loginResult.notificationContent;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notification != null && notification.isNotEmpty
                ? notification
                : 'Logged in successfully!',
          ),
          backgroundColor: const Color(0xFF00897B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    } else if (state is AuthenticationFailure) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is AuthenticationInitial) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) return;

    _authBloc.add(LoginRequested(loginName: username, password: password));
  }

  void _showForgetPasswordSheet(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEAEBED);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);
    final inputBorder = isDark ? Colors.white24 : const Color(0xFFD1D5DB);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? Colors.white70 : const Color(0xFF374151);

    final emailController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top drag pill
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF555555),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title: Forget Password?
                    Text(
                      'Forget Password?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      "Please enter your email address used for registration and we'll send you an email with a reset password link",
                      style: TextStyle(
                        fontSize: 13,
                        color: subtextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Email Input
                    CustomTextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      hintText: 'Your email address',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: inputBg,
                      borderRadius: BorderRadius.circular(8),
                      borderColor: inputBorder,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 18),

                    // Send Reset Link Button
                    CustomButton(
                      text: 'Send Reset Link',
                      isLoading: isSubmitting,
                      onPressed: isSubmitting
                          ? null
                          : () {
                              final email = emailController.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid email address',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final navigator = Navigator.of(sheetCtx);

                              setSheetState(() => isSubmitting = true);

                              Future.delayed(const Duration(seconds: 1), () {
                                if (!mounted) return;
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password reset link sent! Please check your inbox.',
                                    ),
                                    backgroundColor: Color(0xFF00897B),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              });
                            },
                      backgroundColor: const Color(0xFFD8B296),
                      disabledBackgroundColor: const Color(0xFFD8B296),
                      disabledForegroundColor: Colors.white70,
                      height: 46,
                      borderRadius: BorderRadius.circular(8),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Cancel Link
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.pop(sheetCtx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final secondaryTextColor = onSurfaceColor.withValues(alpha: 0.65);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFFBF9F6),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        bloc: _authBloc,
        listener: _handleAuthState,
        child: Stack(
          children: [
            // Ambient soft background circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDark ? 0.05 : 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDark ? 0.04 : 0.03),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // App Logo & Soft Ambient Glow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.16),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/ezbookkeeping-192.png',
                              height: 72,
                              width: 72,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Brand Title
                        Text(
                          'ezBookkeeping',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Demo account info subtext
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            context.l10n.demoAccountHint,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // White Floating Card
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.dividerColor.withValues(
                                alpha: isDark ? 0.2 : 0.08,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.04,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 26.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username Label
                              Text(
                                context.l10n.username,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Username Field with clean underline
                              CustomTextFormField(
                                controller: _usernameController,
                                variant: CustomTextFieldVariant.underline,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]'),
                                  ),
                                ],
                                hintText: context.l10n.usernameOrEmail,
                                hintStyle: TextStyle(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 14,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: isDark ? 0.3 : 0.15,
                                    ),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 18),

                              // Password Label
                              Text(
                                context.l10n.password,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Password Field with clean underline
                              CustomTextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                variant: CustomTextFieldVariant.underline,
                                hintText: context.l10n.yourPassword,
                                hintStyle: TextStyle(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 14,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: isDark ? 0.3 : 0.15,
                                    ),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              // Links Row: Switch to Desktop Version | Forget Password?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _showForgetPasswordSheet(context),
                                    child: Text(
                                      context.l10n.forgetPassword,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Log In Button
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _usernameController,
                                builder: (context, userVal, _) {
                                  final hasInput =
                                      userVal.text.trim().isNotEmpty &&
                                      _passwordController.text
                                          .trim()
                                          .isNotEmpty;

                                  return CustomButton(
                                    text: context.l10n.logIn,
                                    onPressed: _isLoading ? null : _handleLogin,
                                    isLoading: _isLoading,
                                    backgroundColor: hasInput
                                        ? primaryColor
                                        : const Color(0xFFD8B296),
                                    disabledBackgroundColor: const Color(
                                      0xFFD8B296,
                                    ),
                                    disabledForegroundColor: Colors.white70,
                                    height: 44,
                                    borderRadius: BorderRadius.circular(14),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),

                              // "or" Divider
                              Center(
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Log in with GitHub Button
                              CustomButton.outlined(
                                text: 'Log in with GitHub',
                                onPressed: () {},
                                borderColor: const Color(0xFFD8B296),
                                borderWidth: 1.2,
                                height: 46,
                                borderRadius: BorderRadius.circular(10),
                                foregroundColor: primaryColor,
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign up row
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${context.l10n.dontHaveAccount} ',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        context.push(AppRoutes.register),
                                    child: Text(
                                      context.l10n.createAccount,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Footer: Language Selector Trigger matching reference image
                        InkWell(
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
                        const SizedBox(height: 16),

                        // Footer: Powered by
                        RichText(
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
