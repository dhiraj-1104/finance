import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';

class TransactionCategoriesScreen extends StatelessWidget {
  const TransactionCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
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

    final types = ['Expense', 'Income', 'Transfer'];

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

                      // Centered Title "Transaction Categories"
                      Expanded(
                        child: Text(
                          'Transaction Categories',
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

            // Content Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: cardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < types.length; i++) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  AppRoutes.primaryCategories,
                                  extra: types[i],
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        types[i],
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: chevronColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (i < types.length - 1)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              height: 1,
                              color: dividerColor,
                            ),
                        ],
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
