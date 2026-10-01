import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
import 'package:ezbookkeeping/core/preferences/preferences_storage.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:ezbookkeeping/features/home/presentation/home_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSecureStorage fakeSecureStorage;
  late PreferencesStorage preferencesStorage;
  late PreferencesController preferencesController;

  setUp(() async {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
    fakeSecureStorage = FakeSecureStorage();
    preferencesStorage = PreferencesStorage(secureStorage: fakeSecureStorage);
    preferencesController = PreferencesController(storage: preferencesStorage);
    getIt.registerSingleton<PreferencesController>(preferencesController);
  });

  tearDown(() {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
  });

  testWidgets(
    'Hero card net assets reflects overview account inclusion and deduction',
    (tester) async {
      // When all default fallback accounts are included:
      // Wallet: 1500 (Asset)
      // Bank Account: 5000 (Asset)
      // Credit Card: 1200 (Liability)
      // Savings Account: 3000 (Asset)
      // Total Assets = 9500.00, Total Liabilities = 1200.00, Net Assets = 8300.00

      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(id: 'net-assets-1', type: 'net-assets'),
      ]);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text(r'$ 8,300.00'), findsOneWidget);
      expect(
        find.text('Total assets \$ 9,500.00 | Total liabilities \$ 1,200.00'),
        findsOneWidget,
      );

      // Exclude Bank Account (5000) and Credit Card (1200) from Overview Statistics
      // Only Wallet (1500) and Savings Account (3000) remain
      // Total Assets = 4500.00, Total Liabilities = 0.00, Net Assets = 4500.00
      preferencesController.setOverviewAccountIds([
        'acc_wallet',
        'acc_savings',
      ], mode: 'Selected Accounts');
      await tester.pumpAndSettle();

      expect(find.text(r'$ 4,500.00'), findsOneWidget);
      expect(
        find.text('Total assets \$ 4,500.00 | Total liabilities \$ 0.00'),
        findsOneWidget,
      );

      // Set mode to None (all excluded) -> Net Assets = 0.00
      preferencesController.setOverviewAccountIds([], mode: 'None');
      await tester.pumpAndSettle();

      expect(find.text(r'$ 0.00'), findsWidgets);
      expect(
        find.text('Total assets \$ 0.00 | Total liabilities \$ 0.00'),
        findsOneWidget,
      );
    },
  );
}
