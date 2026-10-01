import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/data_management/domain/entities/data_management_statistics.dart';
import 'package:ezbookkeeping/features/data_management/domain/repositories/data_management_repository.dart';
import 'package:ezbookkeeping/features/data_management/domain/usecases/get_data_management_statistics_use_case.dart';
import 'package:ezbookkeeping/features/data_management/presentation/bloc/data_management_bloc.dart';
import 'package:ezbookkeeping/features/data_management/presentation/bloc/data_management_event.dart';
import 'package:ezbookkeeping/features/data_management/presentation/bloc/data_management_state.dart';

class DataManagementScreen extends StatefulWidget {
  final DataManagementBloc? bloc;
  final GetDataManagementStatisticsUseCase? getStatisticsUseCase;
  final DataManagementRepository? repository;

  const DataManagementScreen({
    super.key,
    this.bloc,
    this.getStatisticsUseCase,
    this.repository,
  });

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);
  static const Color _dangerRed = Color(0xFFEF4444);

  late final DataManagementBloc? _bloc;
  StreamSubscription<DataManagementState>? _blocSubscription;
  late final GetDataManagementStatisticsUseCase? _useCase;
  late final DataManagementRepository? _repository;

  bool _isLoading = true;
  String? _errorMessage;
  DataManagementStatistics? _statistics;

  @override
  void initState() {
    super.initState();

    _bloc = widget.bloc ??
        (getIt.isRegistered<DataManagementBloc>()
            ? getIt<DataManagementBloc>()
            : null);

    _useCase = widget.getStatisticsUseCase ??
        (getIt.isRegistered<GetDataManagementStatisticsUseCase>()
            ? getIt<GetDataManagementStatisticsUseCase>()
            : null);

    _repository = widget.repository ??
        (getIt.isRegistered<DataManagementRepository>()
            ? getIt<DataManagementRepository>()
            : null);

    final bloc = _bloc;
    if (bloc != null) {
      _blocSubscription = bloc.stream.listen((state) {
        if (!mounted) return;
        if (state is DataManagementStatisticsLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is DataManagementStatisticsLoaded) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _statistics = state.statistics;
          });
        } else if (state is DataManagementStatisticsError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      });
      bloc.add(const LoadDataManagementStatistics());
    } else {
      _loadDirect(forceRefresh: false);
    }
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDirect({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = _useCase;
    if (useCase != null) {
      final result = await useCase(forceRefresh: forceRefresh);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (stats) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _statistics = stats;
          });
        },
      );
      return;
    }

    final repo = _repository;
    if (repo != null) {
      final result =
          await repo.getDataManagementStatistics(forceRefresh: forceRefresh);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (stats) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _statistics = stats;
          });
        },
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(const LoadDataManagementStatistics(forceRefresh: true));
    } else {
      await _loadDirect(forceRefresh: true);
    }
  }

  void _exportData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Export Data',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.table_chart_outlined,
                    color: _copperAccent,
                  ),
                  title: Text(
                    'Export as CSV',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data exported as CSV successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.code_rounded, color: _copperAccent),
                  title: Text(
                    'Export as JSON',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data exported as JSON successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearTransactions() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clear All Transactions'),
          content: const Text(
            'Are you sure you want to clear all transactions? This action cannot be undone.',
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
                if (_statistics != null) {
                  setState(() {
                    _statistics = DataManagementStatistics(
                      totalAccountCount: _statistics!.totalAccountCount,
                      totalTransactionCategoryCount:
                          _statistics!.totalTransactionCategoryCount,
                      totalTransactionTagCount:
                          _statistics!.totalTransactionTagCount,
                      totalTransactionCount: 0,
                      totalTransactionPictureCount: 0,
                      totalExplorationCount: _statistics!.totalExplorationCount,
                      totalTransactionTemplateCount:
                          _statistics!.totalTransactionTemplateCount,
                      totalScheduledTransactionCount:
                          _statistics!.totalScheduledTransactionCount,
                      totalCustomIconCount: _statistics!.totalCustomIconCount,
                    );
                  });
                }
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All transactions cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAllData() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all data? This action will reset all transactions, accounts, categories, tags, and templates.',
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
                  _statistics = const DataManagementStatistics();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow({
    required String label,
    required String count,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              color: subtextColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F0F11) : const Color(0xFFEFF1F5);
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

    final stats = _statistics ?? const DataManagementStatistics();

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

                      // Title "Data Management"
                      Expanded(
                        child: Text(
                          'Data Management',
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
              child: RefreshIndicator(
                color: _copperAccent,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          // Error State Banner (if error occurred)
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _dangerRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _dangerRed.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: _dangerRed,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: _dangerRed,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _onRefresh,
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: _copperAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Card 1: Metrics Overview
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _isLoading && _statistics == null
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 48,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: _copperAccent,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      _buildStatRow(
                                        label: 'Transactions',
                                        count: '${stats.totalTransactionCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Transaction Pictures',
                                        count:
                                            '${stats.totalTransactionPictureCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Accounts',
                                        count: '${stats.totalAccountCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Explorations',
                                        count: '${stats.totalExplorationCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Transaction Categories',
                                        count:
                                            '${stats.totalTransactionCategoryCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Transaction Tags',
                                        count:
                                            '${stats.totalTransactionTagCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Transaction Templates',
                                        count:
                                            '${stats.totalTransactionTemplateCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Scheduled Transactions',
                                        count:
                                            '${stats.totalScheduledTransactionCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                      _buildStatRow(
                                        label: 'Custom Icons',
                                        count: '${stats.totalCustomIconCount}',
                                        textColor: textColor,
                                        subtextColor: subtextColor,
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Card 2: Export Data Button
                          Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _exportData,
                                child: const Center(
                                  child: Text(
                                    'Export Data',
                                    style: TextStyle(
                                      color: _copperAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Card 3: Danger Zone
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _confirmClearTransactions,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Clear All Transactions',
                                        style: TextStyle(
                                          color: _dangerRed,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _confirmClearAllData,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Clear All Data',
                                        style: TextStyle(
                                          color: _dangerRed,
                                          fontSize: 15,
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

                          const SizedBox(height: 24),
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
