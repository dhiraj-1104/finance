import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:ezbookkeeping/core/localization/locale_storage.dart';
import 'package:ezbookkeeping/core/network/dio_client.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';
import 'package:ezbookkeeping/features/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:ezbookkeeping/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/login.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/logout.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/register.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:ezbookkeeping/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ezbookkeeping/features/home/data/repositories/home_repository_impl.dart';
import 'package:ezbookkeeping/features/home/domain/repositories/home_repository.dart';
import 'package:ezbookkeeping/features/home/domain/usecases/get_transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_bloc.dart';
import 'package:ezbookkeeping/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:ezbookkeeping/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/add_transaction_use_case.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transaction_details.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:ezbookkeeping/features/accounts/data/datasources/accounts_remote_data_source.dart';
import 'package:ezbookkeeping/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/add_account_use_case.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:ezbookkeeping/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:ezbookkeeping/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:ezbookkeeping/features/statistics/domain/usecases/get_statistics_use_case.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:ezbookkeeping/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ezbookkeeping/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/add_transaction_category_use_case.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/get_transaction_categories_use_case.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:ezbookkeeping/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ezbookkeeping/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ezbookkeeping/features/profile/domain/repositories/profile_repository.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/update_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:ezbookkeeping/features/tags/data/datasources/tags_remote_data_source.dart';
import 'package:ezbookkeeping/features/tags/data/repositories/tags_repository_impl.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/add_transaction_tag_use_case.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/get_transaction_tags_use_case.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:ezbookkeeping/features/templates/data/datasources/templates_remote_data_source.dart';
import 'package:ezbookkeeping/features/templates/data/repositories/templates_repository_impl.dart';
import 'package:ezbookkeeping/features/templates/domain/repositories/templates_repository.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/add_transaction_template_use_case.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/get_transaction_templates_use_case.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_bloc.dart';
import 'package:ezbookkeeping/features/data_management/data/datasources/data_management_remote_data_source.dart';
import 'package:ezbookkeeping/features/data_management/data/repositories/data_management_repository_impl.dart';
import 'package:ezbookkeeping/features/data_management/domain/repositories/data_management_repository.dart';
import 'package:ezbookkeeping/features/data_management/domain/usecases/get_data_management_statistics_use_case.dart';
import 'package:ezbookkeeping/features/data_management/presentation/bloc/data_management_bloc.dart';
import 'package:ezbookkeeping/features/tokens/data/datasources/tokens_remote_data_source.dart';
import 'package:ezbookkeeping/features/tokens/data/repositories/tokens_repository_impl.dart';
import 'package:ezbookkeeping/features/tokens/domain/repositories/tokens_repository.dart';
import 'package:ezbookkeeping/features/tokens/domain/usecases/get_tokens_use_case.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_bloc.dart';
import 'package:ezbookkeeping/features/exchange_rates/exchange_rates.dart';
export 'package:ezbookkeeping/features/exchange_rates/exchange_rates.dart';
import 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
import 'package:ezbookkeeping/core/preferences/preferences_storage.dart';
export 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
export 'package:ezbookkeeping/core/preferences/preferences_storage.dart';
export 'package:ezbookkeeping/features/home/models/home_layout_widget.dart';
import 'package:get_it/get_it.dart';

/// Global GetIt service locator instance.
final getIt = GetIt.instance;

/// Registers all core and feature dependencies using [GetIt].
Future<void> setupDependencies({
  TokenStorage? tokenStorage,
  Dio? dio,
  String baseUrl = 'https://ezbookkeeping-demo.mayswind.net',
}) async {
  // Core: LocaleStorage & LocaleController
  if (!getIt.isRegistered<LocaleStorage>()) {
    getIt.registerLazySingleton<LocaleStorage>(() => SecureLocaleStorage());
  }

  if (!getIt.isRegistered<LocaleController>()) {
    final controller = LocaleController(storage: getIt<LocaleStorage>());
    await controller.initialize();
    getIt.registerSingleton<LocaleController>(controller);
  }

  // Core: PreferencesStorage & PreferencesController
  if (!getIt.isRegistered<PreferencesStorage>()) {
    getIt.registerLazySingleton<PreferencesStorage>(
      () => PreferencesStorage(),
    );
  }

  if (!getIt.isRegistered<PreferencesController>()) {
    final prefController = PreferencesController(
      storage: getIt<PreferencesStorage>(),
    );
    await prefController.loadFromStorage();
    getIt.registerSingleton<PreferencesController>(prefController);
  }

  // Core: TokenStorage
  if (!getIt.isRegistered<TokenStorage>()) {
    getIt.registerLazySingleton<TokenStorage>(
      () => tokenStorage ?? SecureTokenStorage(),
    );
  }

  // Core: Dio
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() {
      if (dio != null) return dio;
      final dioClient = DioClient(
        baseUrl: baseUrl,
        tokenStorage: getIt<TokenStorage>(),
      );
      return dioClient.dio;
    });
  }

  // Authentication: Remote Data Source
  if (!getIt.isRegistered<AuthenticationRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthenticationRemoteDataSource>(
      () => AuthenticationRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Authentication: Repository
  if (!getIt.isRegistered<AuthenticationRepository>()) {
    getIt.registerLazySingleton<AuthenticationRepository>(
      () => AuthenticationRepositoryImpl(
        remoteDataSource: getIt<AuthenticationRemoteDataSource>(),
        tokenStorage: getIt<TokenStorage>(),
      ),
    );
  }

  // Authentication: Use Case
  if (!getIt.isRegistered<Login>()) {
    getIt.registerLazySingleton<Login>(
      () => Login(getIt<AuthenticationRepository>()),
    );
  }

  if (!getIt.isRegistered<Register>()) {
    getIt.registerLazySingleton<Register>(
      () => Register(getIt<AuthenticationRepository>()),
    );
  }

  if (!getIt.isRegistered<Logout>()) {
    getIt.registerLazySingleton<Logout>(
      () => Logout(getIt<AuthenticationRepository>()),
    );
  }

  // Authentication: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<AuthenticationBloc>()) {
    getIt.registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(
        login: getIt<Login>(),
        register: getIt<Register>(),
        logout: getIt<Logout>(),
        categoriesRepository: getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null,
      ),
    );
  }

  // Home: Remote Data Source
  if (!getIt.isRegistered<HomeRemoteDataSource>()) {
    getIt.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Home: Repository
  if (!getIt.isRegistered<HomeRepository>()) {
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
    );
  }

  // Home: Use Case
  if (!getIt.isRegistered<GetTransactionAmounts>()) {
    getIt.registerLazySingleton<GetTransactionAmounts>(
      () => GetTransactionAmounts(getIt<HomeRepository>()),
    );
  }

  // Home: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<HomeBloc>()) {
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(getTransactionAmounts: getIt<GetTransactionAmounts>()),
    );
  }

  // Transactions: Remote Data Source
  if (!getIt.isRegistered<TransactionRemoteDataSource>()) {
    getIt.registerLazySingleton<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Transactions: Repository
  if (!getIt.isRegistered<TransactionRepository>()) {
    getIt.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: getIt<TransactionRemoteDataSource>(),
      ),
    );
  }

  // Categories: Remote Data Source
  if (!getIt.isRegistered<CategoriesRemoteDataSource>()) {
    getIt.registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Categories: Repository
  if (!getIt.isRegistered<CategoriesRepository>()) {
    getIt.registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(
        remoteDataSource: getIt<CategoriesRemoteDataSource>(),
      ),
    );
  }

  // Categories: Use Case
  if (!getIt.isRegistered<GetTransactionCategoriesUseCase>()) {
    getIt.registerLazySingleton<GetTransactionCategoriesUseCase>(
      () => GetTransactionCategoriesUseCase(getIt<CategoriesRepository>()),
    );
  }

  if (!getIt.isRegistered<AddTransactionCategoryUseCase>()) {
    getIt.registerLazySingleton<AddTransactionCategoryUseCase>(
      () => AddTransactionCategoryUseCase(getIt<CategoriesRepository>()),
    );
  }

  // Categories: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<CategoriesBloc>()) {
    getIt.registerFactory<CategoriesBloc>(
      () => CategoriesBloc(
        getCategories: getIt<GetTransactionCategoriesUseCase>(),
        addCategory: getIt<AddTransactionCategoryUseCase>(),
      ),
    );
  }

  // Transactions: Use Case
  if (!getIt.isRegistered<GetTransactions>()) {
    getIt.registerLazySingleton<GetTransactions>(
      () => GetTransactions(
        getIt<TransactionRepository>(),
        accountsRepository: getIt.isRegistered<AccountsRepository>()
            ? getIt<AccountsRepository>()
            : null,
        categoriesRepository: getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null,
      ),
    );
  }

  if (!getIt.isRegistered<GetTransactionDetails>()) {
    getIt.registerLazySingleton<GetTransactionDetails>(
      () => GetTransactionDetails(
        getIt<TransactionRepository>(),
        accountsRepository: getIt.isRegistered<AccountsRepository>()
            ? getIt<AccountsRepository>()
            : null,
        categoriesRepository: getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null,
      ),
    );
  }

  // Transactions: AddTransaction Use Case
  if (!getIt.isRegistered<AddTransactionUseCase>()) {
    getIt.registerLazySingleton<AddTransactionUseCase>(
      () => AddTransactionUseCase(getIt<TransactionRepository>()),
    );
  }

  // Transactions: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<TransactionBloc>()) {
    getIt.registerFactory<TransactionBloc>(
      () => TransactionBloc(
        getTransactions: getIt<GetTransactions>(),
        addTransaction: getIt<AddTransactionUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<TransactionDetailsBloc>()) {
    getIt.registerFactory<TransactionDetailsBloc>(
      () => TransactionDetailsBloc(
        getTransactionDetails: getIt<GetTransactionDetails>(),
      ),
    );
  }

  // Accounts: Remote Data Source
  if (!getIt.isRegistered<AccountsRemoteDataSource>()) {
    getIt.registerLazySingleton<AccountsRemoteDataSource>(
      () => AccountsRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Accounts: Repository
  if (!getIt.isRegistered<AccountsRepository>()) {
    getIt.registerLazySingleton<AccountsRepository>(
      () => AccountsRepositoryImpl(
        remoteDataSource: getIt<AccountsRemoteDataSource>(),
      ),
    );
  }

  // Accounts: Use Case
  if (!getIt.isRegistered<GetAccountsUseCase>()) {
    getIt.registerLazySingleton<GetAccountsUseCase>(
      () => GetAccountsUseCase(getIt<AccountsRepository>()),
    );
  }

  if (!getIt.isRegistered<AddAccountUseCase>()) {
    getIt.registerLazySingleton<AddAccountUseCase>(
      () => AddAccountUseCase(getIt<AccountsRepository>()),
    );
  }

  // Accounts: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<AccountsBloc>()) {
    getIt.registerFactory<AccountsBloc>(
      () => AccountsBloc(
        getAccounts: getIt<GetAccountsUseCase>(),
        addAccount: getIt<AddAccountUseCase>(),
      ),
    );
  }

  // Statistics: Remote Data Source
  if (!getIt.isRegistered<StatisticsRemoteDataSource>()) {
    getIt.registerLazySingleton<StatisticsRemoteDataSource>(
      () => StatisticsRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Statistics: Repository
  if (!getIt.isRegistered<StatisticsRepository>()) {
    getIt.registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(
        remoteDataSource: getIt<StatisticsRemoteDataSource>(),
        transactionRepository: getIt.isRegistered<TransactionRepository>()
            ? getIt<TransactionRepository>()
            : null,
        categoriesRepository: getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null,
        accountsRepository: getIt.isRegistered<AccountsRepository>()
            ? getIt<AccountsRepository>()
            : null,
      ),
    );
  }

  // Statistics: Use Case
  if (!getIt.isRegistered<GetStatisticsUseCase>()) {
    getIt.registerLazySingleton<GetStatisticsUseCase>(
      () => GetStatisticsUseCase(getIt<StatisticsRepository>()),
    );
  }

  // Statistics: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<StatisticsBloc>()) {
    getIt.registerFactory<StatisticsBloc>(
      () => StatisticsBloc(getStatistics: getIt<GetStatisticsUseCase>()),
    );
  }

  // Profile: Remote Data Source
  if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Profile: Repository
  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: getIt<ProfileRemoteDataSource>(),
      ),
    );
  }

  // Profile: Use Case
  if (!getIt.isRegistered<GetUserProfileUseCase>()) {
    getIt.registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateUserProfileUseCase>()) {
    getIt.registerLazySingleton<UpdateUserProfileUseCase>(
      () => UpdateUserProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  // Profile: Presentation BLoCs (Factory for stateful BLoCs)
  if (!getIt.isRegistered<UserProfileBloc>()) {
    getIt.registerFactory<UserProfileBloc>(
      () => UserProfileBloc(getUserProfile: getIt<GetUserProfileUseCase>()),
    );
  }

  if (!getIt.isRegistered<UpdateUserProfileBloc>()) {
    getIt.registerFactory<UpdateUserProfileBloc>(
      () => UpdateUserProfileBloc(
        updateUserProfile: getIt<UpdateUserProfileUseCase>(),
      ),
    );
  }

  // Tags: Remote Data Source
  if (!getIt.isRegistered<TagsRemoteDataSource>()) {
    getIt.registerLazySingleton<TagsRemoteDataSource>(
      () => TagsRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Tags: Repository
  if (!getIt.isRegistered<TagsRepository>()) {
    getIt.registerLazySingleton<TagsRepository>(
      () => TagsRepositoryImpl(remoteDataSource: getIt<TagsRemoteDataSource>()),
    );
  }

  // Tags: Use Cases
  if (!getIt.isRegistered<GetTransactionTagsUseCase>()) {
    getIt.registerLazySingleton<GetTransactionTagsUseCase>(
      () => GetTransactionTagsUseCase(getIt<TagsRepository>()),
    );
  }

  if (!getIt.isRegistered<AddTransactionTagUseCase>()) {
    getIt.registerLazySingleton<AddTransactionTagUseCase>(
      () => AddTransactionTagUseCase(getIt<TagsRepository>()),
    );
  }

  // Tags: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<TagsBloc>()) {
    getIt.registerFactory<TagsBloc>(
      () => TagsBloc(
        getTags: getIt<GetTransactionTagsUseCase>(),
        addTag: getIt<AddTransactionTagUseCase>(),
      ),
    );
  }

  // Templates: Remote Data Source
  if (!getIt.isRegistered<TemplatesRemoteDataSource>()) {
    getIt.registerLazySingleton<TemplatesRemoteDataSource>(
      () => TemplatesRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Templates: Repository
  if (!getIt.isRegistered<TemplatesRepository>()) {
    getIt.registerLazySingleton<TemplatesRepository>(
      () => TemplatesRepositoryImpl(
        remoteDataSource: getIt<TemplatesRemoteDataSource>(),
      ),
    );
  }

  // Templates: Use Cases
  if (!getIt.isRegistered<GetTransactionTemplatesUseCase>()) {
    getIt.registerLazySingleton<GetTransactionTemplatesUseCase>(
      () => GetTransactionTemplatesUseCase(getIt<TemplatesRepository>()),
    );
  }

  if (!getIt.isRegistered<AddTransactionTemplateUseCase>()) {
    getIt.registerLazySingleton<AddTransactionTemplateUseCase>(
      () => AddTransactionTemplateUseCase(getIt<TemplatesRepository>()),
    );
  }

  // Templates: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<TemplatesBloc>()) {
    getIt.registerFactory<TemplatesBloc>(
      () => TemplatesBloc(
        addTemplate: getIt<AddTransactionTemplateUseCase>(),
        getTemplates: getIt<GetTransactionTemplatesUseCase>(),
      ),
    );
  }

  // Data Management: Remote Data Source
  if (!getIt.isRegistered<DataManagementRemoteDataSource>()) {
    getIt.registerLazySingleton<DataManagementRemoteDataSource>(
      () => DataManagementRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Data Management: Repository
  if (!getIt.isRegistered<DataManagementRepository>()) {
    getIt.registerLazySingleton<DataManagementRepository>(
      () => DataManagementRepositoryImpl(
        remoteDataSource: getIt<DataManagementRemoteDataSource>(),
      ),
    );
  }

  // Data Management: Use Cases
  if (!getIt.isRegistered<GetDataManagementStatisticsUseCase>()) {
    getIt.registerLazySingleton<GetDataManagementStatisticsUseCase>(
      () =>
          GetDataManagementStatisticsUseCase(getIt<DataManagementRepository>()),
    );
  }

  // Data Management: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<DataManagementBloc>()) {
    getIt.registerFactory<DataManagementBloc>(
      () => DataManagementBloc(
        getStatistics: getIt<GetDataManagementStatisticsUseCase>(),
      ),
    );
  }

  // Tokens: Remote Data Source
  if (!getIt.isRegistered<TokensRemoteDataSource>()) {
    getIt.registerLazySingleton<TokensRemoteDataSource>(
      () => TokensRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Tokens: Repository
  if (!getIt.isRegistered<TokensRepository>()) {
    getIt.registerLazySingleton<TokensRepository>(
      () => TokensRepositoryImpl(
        remoteDataSource: getIt<TokensRemoteDataSource>(),
      ),
    );
  }

  // Tokens: Use Cases
  if (!getIt.isRegistered<GetTokensUseCase>()) {
    getIt.registerLazySingleton<GetTokensUseCase>(
      () => GetTokensUseCase(getIt<TokensRepository>()),
    );
  }

  // Tokens: Presentation BLoC (Factory for stateful BLoCs)
  if (!getIt.isRegistered<TokensBloc>()) {
    getIt.registerFactory<TokensBloc>(
      () => TokensBloc(getTokens: getIt<GetTokensUseCase>()),
    );
  }

  // Exchange Rates: Remote Data Source
  if (!getIt.isRegistered<ExchangeRatesRemoteDataSource>()) {
    getIt.registerLazySingleton<ExchangeRatesRemoteDataSource>(
      () => ExchangeRatesRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
  }

  // Exchange Rates: Repository
  if (!getIt.isRegistered<ExchangeRatesRepository>()) {
    getIt.registerLazySingleton<ExchangeRatesRepository>(
      () => ExchangeRatesRepositoryImpl(
        remoteDataSource: getIt<ExchangeRatesRemoteDataSource>(),
      ),
    );
  }

  // Exchange Rates: Use Cases
  if (!getIt.isRegistered<GetLatestExchangeRatesUseCase>()) {
    getIt.registerLazySingleton<GetLatestExchangeRatesUseCase>(
      () => GetLatestExchangeRatesUseCase(
        getIt<ExchangeRatesRepository>(),
      ),
    );
  }

  // Exchange Rates: Application-wide Singleton Service
  if (!getIt.isRegistered<ExchangeRateService>()) {
    getIt.registerLazySingleton<ExchangeRateService>(
      () => ExchangeRateService(
        getLatestExchangeRates: getIt<GetLatestExchangeRatesUseCase>(),
      ),
    );
  }
}
