import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);
  static const Color _dangerRed = Color(0xFFEF4444);

  bool _isEnabled = false;
  final String _secretKey = 'JBSWY3DPEHPK3PXP';

  void _showEnableDialog() {
    final codeController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enable 2FA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan the QR code or enter this secret key in your authenticator app (Google Authenticator, Authy, etc.):',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF2F2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _secretKey,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: _copperAccent,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _secretKey));
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Secret key copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter 6-digit verification code:',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '123456',
                    hintStyle: TextStyle(color: subtextColor, letterSpacing: 8),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white10
                        : const Color(0xFFF2F2F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _copperAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final code = codeController.text.trim();
                if (code.length != 6) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 6-digit code'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() {
                  _isEnabled = true;
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Two-Factor Authentication enabled successfully',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Verify & Enable'),
            ),
          ],
        );
      },
    );
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Disable 2FA'),
          content: const Text(
            'Are you sure you want to disable two-factor authentication? Your account will be less secure.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isEnabled = false;
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Two-Factor Authentication disabled'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Disable'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back Button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final router = GoRouter.maybeOf(context);
                              if (router != null && router.canPop()) {
                                router.pop();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Title "Two-Factor Authentication"
                      Expanded(
                        child: Text(
                          'Two-Factor Authentication',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Spacer to balance back button
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        // Card (matching media_1789110673548.png)
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Row 1: Status
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      _isEnabled ? 'Enabled' : 'Disabled',
                                      style: TextStyle(
                                        color: _isEnabled
                                            ? const Color(0xFF0D9488)
                                            : subtextColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Divider
                              Divider(
                                height: 1,
                                thickness: 0.6,
                                indent: 18,
                                endIndent: 18,
                                color: dividerColor,
                              ),

                              // Row 2: Action Button (Enable / Disable)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isEnabled
                                      ? _showDisableDialog
                                      : _showEnableDialog,
                                  child: Container(
                                    width: double.infinity,
                                    height: 54,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _isEnabled ? 'Disable' : 'Enable',
                                      style: TextStyle(
                                        color: _isEnabled
                                            ? _dangerRed
                                            : _copperAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
