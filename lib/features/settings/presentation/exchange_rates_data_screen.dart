import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/widgets/currency_picker_sheet.dart';

class ExchangeRatesDataScreen extends StatefulWidget {
  const ExchangeRatesDataScreen({super.key});

  @override
  State<ExchangeRatesDataScreen> createState() =>
      _ExchangeRatesDataScreenState();
}

class _ExchangeRatesDataScreenState extends State<ExchangeRatesDataScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  ExchangeRateService? _exchangeRateService;
  String _baseCurrencyName = 'United States Dollar';
  String _baseCurrencyCode = 'USD';
  double _baseAmount = 1.00;

  static const Map<String, String> _currencyNames = {
    'USD': 'United States Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'AUD': 'Australian Dollar',
    'BRL': 'Brazilian Real',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CZK': 'Czech Koruna',
    'DKK': 'Danish Krone',
    'HKD': 'Hong Kong Dollar',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli Shekel',
    'ISK': 'Icelandic Krona',
    'KRW': 'South Korean Won',
    'MXN': 'Mexican Peso',
    'MYR': 'Malaysian Ringgit',
    'NOK': 'Norwegian Krone',
    'NZD': 'New Zealand Dollar',
    'PHP': 'Philippine Peso',
    'PLN': 'Polish Zloty',
    'RON': 'Romanian Leu',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'THB': 'Thai Baht',
    'TRY': 'Turkish Lira',
    'ZAR': 'South African Rand',
  };

  // Base fallback rates for 1.00 USD
  final List<Map<String, dynamic>> _currencyRates = [
    {'name': 'Australian Dollar', 'code': 'AUD', 'rate': 1.3917},
    {'name': 'Brazilian Real', 'code': 'BRL', 'rate': 5.1246},
    {'name': 'British Pound', 'code': 'GBP', 'rate': 0.7396},
    {'name': 'Canadian Dollar', 'code': 'CAD', 'rate': 1.3816},
    {'name': 'Chinese Yuan', 'code': 'CNY', 'rate': 6.7062},
    {'name': 'Czech Koruna', 'code': 'CZK', 'rate': 20.877},
    {'name': 'Danish Krone', 'code': 'DKK', 'rate': 6.4351},
    {'name': 'Euro', 'code': 'EUR', 'rate': 0.8608},
    {'name': 'Hong Kong Dollar', 'code': 'HKD', 'rate': 7.8411},
    {'name': 'Hungarian Forint', 'code': 'HUF', 'rate': 314.00},
    {'name': 'Icelandic Krona', 'code': 'ISK', 'rate': 120.52},
    {'name': 'Indian Rupee', 'code': 'INR', 'rate': 79.82},
    {'name': 'Japanese Yen', 'code': 'JPY', 'rate': 136.45},
    {'name': 'South Korean Won', 'code': 'KRW', 'rate': 1312.50},
    {'name': 'Mexican Peso', 'code': 'MXN', 'rate': 20.15},
    {'name': 'Norwegian Krone', 'code': 'NOK', 'rate': 9.85},
    {'name': 'New Zealand Dollar', 'code': 'NZD', 'rate': 1.58},
    {'name': 'Polish Zloty', 'code': 'PLN', 'rate': 4.72},
    {'name': 'Swedish Krona', 'code': 'SEK', 'rate': 10.48},
    {'name': 'Singapore Dollar', 'code': 'SGD', 'rate': 1.38},
    {'name': 'Swiss Franc', 'code': 'CHF', 'rate': 0.96},
    {'name': 'Turkish Lira', 'code': 'TRY', 'rate': 18.20},
    {'name': 'South African Rand', 'code': 'ZAR', 'rate': 17.15},
  ];

  PreferencesController? _preferencesController;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      _preferencesController?.addListener(_onPreferencesChanged);
    }
    if (getIt.isRegistered<ExchangeRateService>()) {
      _exchangeRateService = getIt<ExchangeRateService>();
      _exchangeRateService?.addListener(_onRatesChanged);
      if (!_exchangeRateService!.isInitialized) {
        _exchangeRateService!.initialize();
      }
    }
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_onPreferencesChanged);
    _exchangeRateService?.removeListener(_onRatesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  void _onRatesChanged() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _displayRates {
    final service = _exchangeRateService;
    final sortBy = _preferencesController?.exchangeRatesSortBy ??
        (getIt.isRegistered<PreferencesController>()
            ? getIt<PreferencesController>().exchangeRatesSortBy
            : 'Currency Name');

    final List<Map<String, dynamic>> list;
    if (service != null && service.ratesByCurrency.isNotEmpty) {
      list = <Map<String, dynamic>>[];
      for (final entry in service.ratesByCurrency.entries) {
        final code = entry.key;
        final name = _currencyNames[code] ?? code;
        final convertedRate = service.convert(
          fromCurrency: _baseCurrencyCode,
          toCurrency: code,
          amount: 1.0,
        );
        list.add({
          'name': name,
          'code': code,
          'rate': convertedRate ?? entry.value,
        });
      }
    } else {
      list = List<Map<String, dynamic>>.from(_currencyRates);
    }

    if (sortBy == 'Currency Code') {
      list.sort(
        (a, b) => (a['code'] as String).compareTo(b['code'] as String),
      );
    } else if (sortBy == 'Exchange Rate') {
      list.sort(
        (a, b) => ((a['rate'] as num?) ?? 0).compareTo((b['rate'] as num?) ?? 0),
      );
    } else {
      // Default: 'Currency Name'
      list.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
    }
    return list;
  }

  String _formatRate(double rate) {
    final converted = rate * _baseAmount;
    if (converted >= 100) {
      return converted.toStringAsFixed(2);
    } else if (converted >= 10) {
      // If decimal is 3 digits like 20.877
      final s = converted.toStringAsFixed(3);
      return s.endsWith('0') ? converted.toStringAsFixed(2) : s;
    } else {
      return converted.toStringAsFixed(4);
    }
  }

  void _showCurrencyPicker() {
    CurrencyPickerSheet.show(
      context,
      selectedCurrencyCode: _baseCurrencyCode,
      onCurrencySelected: (curr) {
        setState(() {
          _baseCurrencyName = curr['name'] ?? _baseCurrencyName;
          _baseCurrencyCode = curr['code'] ?? _baseCurrencyCode;
        });
      },
    );
  }

  void _showAmountEditor() {
    final controller = TextEditingController(
      text: _baseAmount == _baseAmount.roundToDouble()
          ? _baseAmount.toStringAsFixed(2)
          : _baseAmount.toString(),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Base Amount'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            decoration: const InputDecoration(
              hintText: '1.00',
              prefixText: 'Amount: ',
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
                final val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  setState(() => _baseAmount = val);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Set Amount'),
            ),
          ],
        );
      },
    );
  }

  void _showActionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Block 1: Refresh
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: sheetBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            Navigator.pop(sheetCtx);
                            if (_exchangeRateService != null) {
                              final success = await _exchangeRateService!
                                  .refresh();
                              if (!mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Exchange rates updated successfully'
                                        : 'Failed to update exchange rates: ${_exchangeRateService?.errorMessage ?? "Error"}',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Exchange rates updated successfully',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Refresh',
                              style: TextStyle(
                                color: _copperAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Block 2: Cancel
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: sheetBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => Navigator.pop(sheetCtx),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: _copperAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

                      // Title "Exchange Rates Data"
                      Expanded(
                        child: Text(
                          'Exchange Rates Data',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Options Button (...)
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
                            onTap: _showActionSheet,
                            child: Center(
                              child: Icon(
                                Icons.more_horiz_rounded,
                                color: textColor,
                                size: 20,
                              ),
                            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      children: [
                        // Card 1: Base Currency & Base Amount (media_1789117829328.png)
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Row 1: Base Currency
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showCurrencyPicker,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Base Currency',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              _baseCurrencyName,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _baseCurrencyCode,
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 20,
                                              color: subtextColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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

                              // Row 2: Base Amount
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showAmountEditor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Base Amount',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _baseAmount.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Card 2: Exchange Rates List
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: () {
                              final rates = _displayRates;
                              return List.generate(rates.length, (index) {
                                final item = rates[index];
                                final isLast = index == rates.length - 1;
                                final name = item['name'] as String;
                                final code = item['code'] as String;
                                final rate = item['rate'] as double;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 15,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            code,
                                            style: TextStyle(
                                              color: subtextColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _formatRate(rate),
                                            style: TextStyle(
                                              color: subtextColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        indent: 18,
                                        endIndent: 18,
                                        color: dividerColor,
                                      ),
                                  ],
                                );
                              });
                            }(),
                          ),
                        ),

                        const SizedBox(height: 32),
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
