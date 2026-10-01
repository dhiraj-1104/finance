/// Centralized definition of all API endpoints used across the application.
abstract final class ApiEndpoints {
  // Auth & User endpoints
  static const String authorize = '/api/authorize.json';
  static const String login = '/auth/login';
  static const String logout = '/api/logout.json';
  static const String register = '/api/register.json';
  static const String userProfile = '/api/v1/users/profile/get.json';
  static const String userProfileUpdate = '/api/v1/users/profile/update.json';
  static const String twoFactorStatus = '/users/2fa/status';
  static const String tokensList = '/api/v1/tokens/list.json';

  // Accounts
  static const String accounts = '/api/accounts';
  static const String accountList = '/api/v1/accounts/list.json';
  static const String addAccount = '/api/v1/accounts/add.json';
  static const String accountCategories = '/api/account/categories';

  // Transactions
  static const String transactionAmounts = '/api/v1/transactions/amounts.json';
  static const String transactionList = '/api/v1/transactions/list.json';
  static const String transactionGet = '/api/v1/transactions/get.json';
  static const String addTransaction = '/api/v1/transactions/add.json';
  static const String transactionCategoriesList =
      '/api/v1/transaction/categories/list.json';
  static const String addCategory = '/api/v1/transaction/categories/add.json';
  static const String transactionStatistics =
      '/api/v1/transactions/statistics.json';
  static const String transactionTags = '/api/transaction/tags';
  static const String transactionTagsList =
      '/api/v1/transaction/tags/list.json';
  static const String addTransactionTag = '/api/v1/transaction/tags/add.json';
  static const String transactionTemplates = '/api/transaction/templates';
  static const String transactionTemplatesList =
      '/api/v1/transaction/templates/list.json';
  static const String addTransactionTemplate =
      '/api/v1/transaction/templates/add.json';

  // Exchange Rates & Data
  static const String exchangeRates = '/api/exchange_rates';
  static const String exchangeRatesLatest =
      '/api/v1/exchange_rates/latest.json';
  static const String dataOverview = '/api/data/overview';
  static const String dataStatistics = '/api/v1/data/statistics.json';
}
