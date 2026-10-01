import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/templates/domain/repositories/templates_repository.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/get_transaction_templates_use_case.dart';
import 'package:ezbookkeeping/features/templates/models/transaction_template.dart';

class TransactionTemplatesScreen extends StatefulWidget {
  final TemplatesRepository? templatesRepository;
  final GetTransactionTemplatesUseCase? getTransactionTemplatesUseCase;

  const TransactionTemplatesScreen({
    super.key,
    this.templatesRepository,
    this.getTransactionTemplatesUseCase,
  });

  @override
  State<TransactionTemplatesScreen> createState() =>
      _TransactionTemplatesScreenState();
}

class _TransactionTemplatesScreenState
    extends State<TransactionTemplatesScreen> {
  final List<TransactionTemplate> _templates = [];
  bool _showHiddenTemplates = false;
  bool _sortAscending = true;
  bool _isLoading = false;

  late final TemplatesRepository? _repo;

  @override
  void initState() {
    super.initState();
    _repo = widget.templatesRepository ??
        (getIt.isRegistered<TemplatesRepository>()
            ? getIt<TemplatesRepository>()
            : null);
    _loadTemplates();
  }

  Future<void> _loadTemplates({bool forceRefresh = false}) async {
    final repo = _repo;
    if (repo == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await repo.getTemplates(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _templates
          ..clear()
          ..addAll(templates);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  static const Color _copperAccent = Color(0xFFC86D3B);

  List<TransactionTemplate> get _visibleTemplates {
    if (_showHiddenTemplates) {
      return _templates;
    }
    return _templates.where((t) => !t.isHidden).toList();
  }

  void _sortTemplates() {
    setState(() {
      _templates.sort((a, b) {
        final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return _sortAscending ? cmp : -cmp;
      });
      _sortAscending = !_sortAscending;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !_sortAscending
              ? 'Templates sorted by name (A to Z)'
              : 'Templates sorted by name (Z to A)',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.95);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Block 1: Sort & Show Hidden (matching media_1789109548058.png)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _sortTemplates();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sort',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _showHiddenTemplates = !_showHiddenTemplates;
                                });
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _showHiddenTemplates
                                          ? 'Showing hidden transaction templates'
                                          : 'Hidden transaction templates hidden',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _showHiddenTemplates
                                      ? 'Hide Hidden Transaction Templates'
                                      : 'Show Hidden Transaction Templates',
                                  style: const TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Block 2: Cancel Button (matching media_1789109548058.png)
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: blockBg,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: _copperAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTemplates = _visibleTemplates;
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

                      const SizedBox(width: 8),

                      // Title "Transaction Templates"
                      Expanded(
                        child: Text(
                          'Transaction Templates',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Right Pill Button with '...' and '+'
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(21),
                                ),
                                onTap: _showMoreOptions,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(21),
                                ),
                                onTap: () async {
                                  final newTemplate = await context
                                      .push<TransactionTemplate>(
                                        AppRoutes.addTransactionTemplate,
                                      );
                                  if (newTemplate != null) {
                                    setState(() {
                                      _templates.add(newTemplate);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: textColor,
                                    size: 22,
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: cardShadow,
                      ),
                      padding: (visibleTemplates.isEmpty || _isLoading)
                          ? const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            )
                          : EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: _copperAccent),
                              ),
                            )
                          : visibleTemplates.isEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No available template',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                const SizedBox(height: 6),
                                Text(
                                  'Once you add templates, you can long-press the Add button on the home page to quickly add a new transaction',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                for (
                                  int i = 0;
                                  i < visibleTemplates.length;
                                  i++
                                ) ...[
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final updated = await context
                                            .push<TransactionTemplate>(
                                              AppRoutes.addTransactionTemplate,
                                              extra: visibleTemplates[i],
                                            );
                                        if (updated != null) {
                                          setState(() {
                                            final idx = _templates.indexWhere(
                                              (t) =>
                                                  t.id ==
                                                  visibleTemplates[i].id,
                                            );
                                            if (idx != -1) {
                                              _templates[idx] = updated;
                                            }
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.article_outlined,
                                              color: textColor,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                visibleTemplates[i].name,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            if (visibleTemplates[i].isHidden)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Icon(
                                                  Icons.visibility_off_outlined,
                                                  size: 18,
                                                  color: subtextColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (i < visibleTemplates.length - 1)
                                    Divider(
                                      height: 1,
                                      thickness: 0.8,
                                      indent: 18,
                                      endIndent: 18,
                                      color: dividerColor,
                                    ),
                                ],
                              ],
                            ),
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
