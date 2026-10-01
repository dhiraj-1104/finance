import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
import 'package:ezbookkeeping/core/preferences/preferences_storage.dart';

// Fake FlutterSecureStorage for testing persistence
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
  group('Preferences Persistence & Storage Tests', () {
    test(
      'Preferences are saved and restored on simulated app restart',
      () async {
        final fakeStorage = FakeSecureStorage();
        final storage = PreferencesStorage(secureStorage: fakeStorage);

        // Session 1: User modifies preferences
        final controller1 = PreferencesController(storage: storage);
        controller1.setShowAccountBalance(false);
        controller1.setAutoUpdateExchangeRates(false);
        controller1.setTimezoneForStatistics('Transaction Timezone');
        controller1.setOverviewAccountIds(['acc_1', 'acc_3']);
        controller1.setAccountCategories([
          'Investment Account',
          'Credit Card',
          'Cash',
        ]);
        controller1.setChartColors(['#112233', '#445566']);

        controller1.setDefaultCreditCardAmount('Available Credit');
        controller1.setTotalAmountCalculationMethod('Outflows Only');
        controller1.setShowTransactionTags(false);
        controller1.setDefaultKeywordSearchMatchingMode('Exact Match');
        controller1.setQuickSaveButtonStyle('Bottom Left Floating');
        controller1.setQuickAddButtonAction('Save and Add Another');
        controller1.setAutoSaveDraft('Enabled');

        expect(controller1.showAccountBalance, false);
        expect(controller1.autoUpdateExchangeRates, false);
        expect(controller1.timezoneForStatistics, 'Transaction Timezone');
        expect(controller1.useTransactionTimezone, true);
        expect(controller1.accountsInOverview, 'Selected Accounts');
        expect(controller1.overviewAccountIds, ['acc_1', 'acc_3']);
        expect(controller1.isAccountIncludedInOverview('acc_1'), true);
        expect(controller1.isAccountIncludedInOverview('acc_2'), false);
        expect(controller1.accountCategories.length, 3);
        expect(controller1.chartColors.length, 2);
        expect(controller1.defaultCreditCardAmount, 'Available Credit');
        expect(controller1.totalAmountCalculationMethod, 'Outflows Only');
        expect(controller1.showTransactionTags, false);
        expect(controller1.defaultKeywordSearchMatchingMode, 'Exact Match');
        expect(controller1.quickSaveButtonStyle, 'Bottom Left Floating');
        expect(controller1.quickAddButtonAction, 'Save and Add Another');
        expect(controller1.autoSaveDraft, 'Enabled');

        // Session 2: App restarts (New controller instances loads from storage)
        final controller2 = PreferencesController(storage: storage);
        await controller2.loadFromStorage();

        // Verify all settings persisted across restarts!
        expect(controller2.showAccountBalance, false);
        expect(controller2.autoUpdateExchangeRates, false);
        expect(controller2.timezoneForStatistics, 'Transaction Timezone');
        expect(controller2.useTransactionTimezone, true);
        expect(controller2.accountsInOverview, 'Selected Accounts');
        expect(controller2.overviewAccountIds, ['acc_1', 'acc_3']);
        expect(controller2.isAccountIncludedInOverview('acc_1'), true);
        expect(controller2.isAccountIncludedInOverview('acc_2'), false);
        expect(controller2.accountCategories, [
          'Investment Account',
          'Credit Card',
          'Cash',
        ]);
        expect(controller2.accountCategoryOrder, 'Custom');
        expect(controller2.chartColors, ['#112233', '#445566']);
        expect(controller2.chartColorScheme, 'Custom');
        expect(controller2.defaultCreditCardAmount, 'Available Credit');
        expect(controller2.totalAmountCalculationMethod, 'Outflows Only');
        expect(controller2.showTransactionTags, false);
        expect(controller2.defaultKeywordSearchMatchingMode, 'Exact Match');
        expect(controller2.quickSaveButtonStyle, 'Bottom Left Floating');
        expect(controller2.quickAddButtonAction, 'Save and Add Another');
        expect(controller2.autoSaveDraft, 'Enabled');
      },
    );
  });
}
