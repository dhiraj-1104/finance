import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ezbookkeeping/core/logger/app_logger.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/exchange_rate.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/usecases/get_latest_exchange_rates_use_case.dart';

/// Application-wide singleton service managing latest exchange rates in memory.
class ExchangeRateService extends ChangeNotifier {
  final GetLatestExchangeRatesUseCase getLatestExchangeRates;

  ExchangeRateService({required this.getLatestExchangeRates});

  LatestExchangeRates? _latestRates;
  Map<String, double> _ratesByCurrency = const {};
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  Future<bool>? _initializationFuture;

  /// Full domain entity of latest exchange rates.
  LatestExchangeRates? get latestRates => _latestRates;

  /// Fast in-memory map of uppercase currency code -> rate against [baseCurrency].
  Map<String, double> get ratesByCurrency => _ratesByCurrency;

  /// List of exchange rates.
  List<ExchangeRate> get exchangeRates =>
      _latestRates?.exchangeRates ?? const [];

  /// The base currency returned from the API (defaults to 'EUR' if not yet fetched).
  String get baseCurrency => _latestRates?.baseCurrency ?? 'EUR';

  /// Last update timestamp from the API.
  DateTime? get updateTime => _latestRates?.updateTime;

  /// Exchange rates data source provider name (e.g., 'European Central Bank').
  String? get dataSource => _latestRates?.dataSource;

  /// Reference URL of the data source provider.
  String? get referenceUrl => _latestRates?.referenceUrl;

  /// Whether the initial startup fetch has been attempted.
  bool get isInitialized => _isInitialized;

  /// Whether a fetch/refresh request is currently in flight.
  bool get isLoading => _isLoading;

  /// Last error message if fetching failed.
  String? get errorMessage => _errorMessage;

  /// Initializes exchange rates during app startup.
  ///
  /// Uses single-flight synchronization so concurrent calls await the same API request.
  /// Does not throw uncaught exceptions to ensure app startup is never blocked.
  Future<bool> initialize({bool forceRefresh = false}) {
    if (_isInitialized && !forceRefresh && _latestRates != null) {
      return Future.value(true);
    }

    if (_initializationFuture != null) {
      return _initializationFuture!;
    }

    _initializationFuture = _fetchRates(forceRefresh: forceRefresh)
        .whenComplete(() {
          _initializationFuture = null;
        });

    return _initializationFuture!;
  }

  /// Explicitly refreshes the latest exchange rates bypassing cache.
  Future<bool> refresh() async {
    return initialize(forceRefresh: true);
  }

  Future<bool> _fetchRates({required bool forceRefresh}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getLatestExchangeRates(forceRefresh: forceRefresh);

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _isInitialized = true;
          _isLoading = false;
          AppLogger.warning(
            'Failed to fetch latest exchange rates: ${failure.message}',
          );
          notifyListeners();
          return false;
        },
        (rates) {
          _latestRates = rates;
          _ratesByCurrency = rates.ratesByCurrency;
          _isInitialized = true;
          _isLoading = false;
          _errorMessage = null;
          AppLogger.info(
            'Exchange rates successfully initialized: ${_ratesByCurrency.length} currencies (Base: ${rates.baseCurrency})',
          );
          notifyListeners();
          return true;
        },
      );
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isInitialized = true;
      _isLoading = false;
      AppLogger.error(
        'Unexpected error fetching exchange rates: $e',
        e,
        stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Returns the exchange rate for a given currency code against [baseCurrency].
  double? getRate(String currency) {
    final code = currency.trim().toUpperCase();
    if (code.isEmpty) return null;
    return _ratesByCurrency[code];
  }

  /// Converts [amount] from [fromCurrency] to [toCurrency] using base-currency cross-rate arithmetic.
  ///
  /// Returns `null` if rates are unavailable or invalid (<= 0), avoiding inaccurate conversions.
  double? convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) {
    final from = fromCurrency.trim().toUpperCase();
    final to = toCurrency.trim().toUpperCase();

    if (from.isEmpty || to.isEmpty) return null;
    if (from == to) return amount;

    if (_ratesByCurrency.isEmpty) return null;

    final base = baseCurrency.toUpperCase();

    // Direct Conversion: Base Currency -> Target Currency (e.g., EUR -> USD)
    if (from == base) {
      final toRate = _ratesByCurrency[to];
      if (toRate == null || toRate <= 0) return null;
      return amount * toRate;
    }

    // Direct Inverse: Target Currency -> Base Currency (e.g., USD -> EUR)
    if (to == base) {
      final fromRate = _ratesByCurrency[from];
      if (fromRate == null || fromRate <= 0) return null;
      return amount / fromRate;
    }

    // Cross-Currency Conversion (e.g., USD -> INR via EUR base)
    // Formula: (amount / fromRate) * toRate
    final fromRate = _ratesByCurrency[from];
    final toRate = _ratesByCurrency[to];

    if (fromRate == null || fromRate <= 0 || toRate == null || toRate <= 0) {
      return null;
    }

    return (amount / fromRate) * toRate;
  }
}
