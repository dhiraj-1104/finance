import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/home/presentation/utils/money_formatter.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_state.dart';

/// Screen displaying complete details for a single transaction matching the ezBookkeeping UI mockup.
class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;
  final TransactionDetailsBloc? bloc;

  const TransactionDetailsScreen({
    super.key,
    required this.transactionId,
    this.bloc,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late final TransactionDetailsBloc? _bloc;
  StreamSubscription<TransactionDetailsState>? _blocSubscription;
  TransactionDetailsState _state = const TransactionDetailsInitial();

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<TransactionDetailsBloc>()) {
      _bloc = getIt<TransactionDetailsBloc>();
    } else {
      _bloc = null;
    }

    final bloc = _bloc;
    if (bloc != null) {
      _state = bloc.state;
      _blocSubscription = bloc.stream.listen((state) {
        if (mounted) {
          setState(() {
            _state = state;
          });
        }
      });
      bloc.add(LoadTransactionDetails(transactionId: widget.transactionId));
    }
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    if (widget.bloc == null && _bloc != null) {
      _bloc.close();
    }
    super.dispose();
  }

  void _retry() {
    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(LoadTransactionDetails(transactionId: widget.transactionId));
    }
  }

  void _showMoreActions(BuildContext context, Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (transaction.editable)
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFC86D3B),
                  ),
                  title: Text(
                    'Edit Transaction',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      AppRoutes.addTransaction,
                      extra: {
                        'transaction': transaction,
                        'title': 'Edit Transaction',
                      },
                    );
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF0D9488),
                ),
                title: Text(
                  'Copy Transaction ID',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ID: ${transaction.id}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE75A4C),
                ),
                title: const Text(
                  'Delete Transaction',
                  style: TextStyle(
                    color: Color(0xFFE75A4C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete Transaction'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101012) : const Color(0xFFF3F4F8);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F5);

    final state = _state;
    final currentTransaction = state is TransactionDetailsLoaded
        ? state.transaction
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  color: textColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Transaction Detail',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz_rounded, size: 20),
                    color: textColor,
                    onPressed: () {
                      if (currentTransaction != null) {
                        _showMoreActions(context, currentTransaction);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(
        state: state,
        isDark: isDark,
        cardBg: cardBg,
        textColor: textColor,
        subtextColor: subtextColor,
        dividerColor: dividerColor,
      ),
    );
  }

  Widget _buildBody({
    required TransactionDetailsState state,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color dividerColor,
  }) {
    if (state is TransactionDetailsLoading ||
        (state is TransactionDetailsInitial && _bloc != null)) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
        ),
      );
    }

    if (state is TransactionDetailsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFE75A4C),
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TransactionDetailsLoaded) {
      final tx = state.transaction;
      return RefreshIndicator(
        color: const Color(0xFF0D9488),
        onRefresh: () async {
          final bloc = _bloc;
          if (bloc != null) {
            bloc.add(
              RefreshTransactionDetails(transactionId: widget.transactionId),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Segmented Type Selector Bar (Expense | Income | Transfer)
              _buildTypeSegmentedBar(type: tx.type, isDark: isDark),
              const SizedBox(height: 14),

              // 2. Main White Rounded Card
              _buildMainDetailsCard(
                tx: tx,
                isDark: isDark,
                cardBg: cardBg,
                textColor: textColor,
                subtextColor: subtextColor,
                dividerColor: dividerColor,
              ),

              // 3. Optional Pictures Card
              if (tx.pictures.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildPicturesCard(
                  tx: tx,
                  isDark: isDark,
                  cardBg: cardBg,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Segmented pill tab bar showing [Expense, Income, Transfer] matching mockup
  Widget _buildTypeSegmentedBar({required int type, required bool isDark}) {
    final activeIndex = _getTypeIndex(type);
    final tabs = ['Expense', 'Income', 'Transfer'];

    final barBg = isDark ? const Color(0xFF222226) : const Color(0xFFE5E7EB);
    final activePillBg = isDark ? const Color(0xFF323238) : Colors.white;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == activeIndex;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? activePillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF1A1C1E))
                      : const Color(0xFF9E9EA7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  int _getTypeIndex(int type) {
    switch (type) {
      case 2:
        return 1; // Income
      case 4:
        return 2; // Transfer
      case 1:
      case 3:
      default:
        return 0; // Expense
    }
  }

  /// Main white rounded card with individual row sections
  Widget _buildMainDetailsCard({
    required Transaction tx,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color dividerColor,
  }) {
    final amountLabel = _getAmountHeaderLabel(tx.type);
    final themeColor = _resolveTypeColor(tx.type);

    final formattedAmount = tx.hideAmount
        ? '***'
        : MoneyFormatter.format(tx.sourceAmount.toString(), currency: 'USD');

    final categoryPath = _resolveCategoryDisplay(tx);
    final sourceAccount =
        tx.sourceAccount?.name ?? _resolveAccountName(tx.sourceAccountId);
    final destAccount =
        tx.destinationAccount?.name ??
        (tx.destinationAccountId != null
            ? _resolveAccountName(tx.destinationAccountId!)
            : null);

    final formattedDateTime = _formatFullDateTime(tx.time, tx.utcOffset);
    final timezoneComparison = _formatTimezoneComparison(tx.utcOffset);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Amount Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amountLabel,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedAmount,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 2. Category Section
          _buildItemRow(
            label: 'Category',
            subtextColor: subtextColor,
            child: _buildCategoryValueWidget(categoryPath, textColor),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 3. Account Section
          _buildItemRow(
            label: tx.isTransfer ? 'Source Account' : 'Account',
            subtextColor: subtextColor,
            child: Text(
              sourceAccount,
              style: TextStyle(
                color: textColor,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (destAccount != null) ...[
            Divider(height: 1, thickness: 0.8, color: dividerColor),
            _buildItemRow(
              label: 'Destination Account',
              subtextColor: subtextColor,
              child: Text(
                destAccount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          if (tx.destinationAmount != null && tx.destinationAmount != 0) ...[
            Divider(height: 1, thickness: 0.8, color: dividerColor),
            _buildItemRow(
              label: 'Destination Amount',
              subtextColor: subtextColor,
              child: Text(
                MoneyFormatter.format(
                  tx.destinationAmount.toString(),
                  currency: 'USD',
                ),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 4. Transaction Time Section
          _buildItemRow(
            label: 'Transaction Time',
            subtextColor: subtextColor,
            child: Text(
              formattedDateTime,
              style: TextStyle(
                color: textColor,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 5. Transaction Timezone Section
          _buildItemRow(
            label: 'Transaction Timezone',
            subtextColor: subtextColor,
            child: Text(
              timezoneComparison,
              style: TextStyle(
                color: textColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 6. Geographic Location Section
          _buildItemRow(
            label: 'Geographic Location',
            subtextColor: subtextColor,
            child: Text(
              'No Location',
              style: TextStyle(
                color: textColor,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 7. Tags Section
          _buildItemRow(
            label: 'Tags',
            subtextColor: subtextColor,
            child: _buildTagsPillList(tx.tagIds, isDark, subtextColor),
          ),

          // 8. Description / Comment Section (if present or showing No Description)
          Divider(height: 1, thickness: 0.8, color: dividerColor),
          _buildItemRow(
            label: 'Description',
            subtextColor: subtextColor,
            child: Text(
              tx.comment.isNotEmpty ? tx.comment : 'No Description',
              style: TextStyle(
                color: tx.comment.isNotEmpty ? textColor : subtextColor,
                fontSize: 15,
                fontWeight: tx.comment.isNotEmpty
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String label,
    required Color subtextColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subtextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryValueWidget(String categoryPath, Color textColor) {
    if (categoryPath.contains(' > ')) {
      final parts = categoryPath.split(' > ');
      return Row(
        children: [
          Text(
            parts[0],
            style: TextStyle(
              color: textColor,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              parts[1],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      categoryPath,
      style: TextStyle(
        color: textColor,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTagsPillList(
    List<String> tagIds,
    bool isDark,
    Color subtextColor,
  ) {
    if (tagIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'None',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tagIds.map((tagId) {
        final tagName = _resolveTagName(tagId);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '# $tagName',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPicturesCard({
    required Transaction tx,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pictures (${tx.pictures.length})',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: tx.pictures.map((pic) {
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFF0F0F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E4EB),
                  ),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: Color(0xFF8E8E93),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getAmountHeaderLabel(int type) {
    switch (type) {
      case 2:
        return 'Income Amount';
      case 4:
        return 'Transfer Amount';
      case 1:
      case 3:
      default:
        return 'Expense Amount';
    }
  }

  Color _resolveTypeColor(int type) {
    switch (type) {
      case 2:
        return const Color(0xFFE75A4C); // Income
      case 4:
        return const Color(0xFF34AEE2); // Transfer
      case 1:
      case 3:
      default:
        return const Color(0xFF0D9488); // Teal
    }
  }

  String _formatFullDateTime(int unixSeconds, int utcOffsetMinutes) {
    if (unixSeconds == 0) return '-';
    final utcDate = DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    );
    final localWithOffset = utcDate.add(Duration(minutes: utcOffsetMinutes));

    final year = localWithOffset.year;
    final month = _fullMonthNames[localWithOffset.month - 1];
    final day = localWithOffset.day.toString().padLeft(2, '0');

    final hour24 = localWithOffset.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final hourStr = hour12.toString().padLeft(2, '0');
    final minStr = localWithOffset.minute.toString().padLeft(2, '0');
    final secStr = localWithOffset.second.toString().padLeft(2, '0');
    final ampm = hour24 >= 12 ? 'PM' : 'AM';

    return '$month $day, $year $hourStr:$minStr:$secStr $ampm';
  }

  static const _fullMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatTimezoneComparison(int txUtcOffsetMinutes) {
    final sign = txUtcOffsetMinutes >= 0 ? '+' : '-';
    final absOffset = txUtcOffsetMinutes.abs();
    final offHours = (absOffset ~/ 60).toString().padLeft(2, '0');
    final offMins = (absOffset % 60).toString().padLeft(2, '0');
    final utcStr = '(UTC$sign$offHours:$offMins)';

    final localOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final diffMinutes = txUtcOffsetMinutes - localOffsetMinutes;

    if (diffMinutes == 0) {
      return '$utcStr same as local time';
    }

    final diffAbs = diffMinutes.abs();
    final diffH = diffAbs ~/ 60;
    final diffM = diffAbs % 60;
    final relation = diffMinutes < 0 ? 'slower than' : 'faster than';

    final buffer = StringBuffer(utcStr)..write(' ');
    if (diffH > 0 && diffM > 0) {
      buffer.write('$diffH hour(s) and $diffM minutes $relation local time');
    } else if (diffH > 0) {
      buffer.write('$diffH hour(s) $relation local time');
    } else {
      buffer.write('$diffM minutes $relation local time');
    }

    return buffer.toString();
  }

  String _resolveCategoryDisplay(Transaction tx) {
    if (tx.categoryName != null && tx.categoryName!.isNotEmpty) {
      return tx.categoryName!;
    }
    if (tx.category != null && tx.category!.name.isNotEmpty) {
      return tx.category!.name;
    }
    if (tx.displayTitle.isNotEmpty) {
      return tx.displayTitle;
    }
    switch (tx.type) {
      case 2:
        return 'Income';
      case 4:
        return 'Transfer';
      case 1:
      case 3:
      default:
        return 'Expense';
    }
  }

  String _resolveAccountName(String accountId) {
    const accountMap = {
      '3843885834860232704': 'Wallet',
      '3843885834860232705': 'Wallet (US Dollar)',
      '3843885834860232706': 'Wallet (Euro)',
      '3843885834860232708': 'Credit Card',
      '3843885834860232709': 'Bank Account',
      '3843885834860232710': 'Savings Account',
      '3843885834860232711': 'Cash',
    };
    return accountMap[accountId] ??
        (RegExp(r'^\d+$').hasMatch(accountId)
            ? 'Credit Card'
            : (accountId.isNotEmpty ? accountId : 'Wallet (US Dollar)'));
  }

  String _resolveTagName(String tagId) {
    const tagMap = {
      '1': 'travel',
      '2': 'vacation',
      '3': 'work',
      '4': 'personal',
      '5': 'essential',
    };
    return tagMap[tagId] ??
        (RegExp(r'^\d+$').hasMatch(tagId) ? 'general' : tagId);
  }
}
