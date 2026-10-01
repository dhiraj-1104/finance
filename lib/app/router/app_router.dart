import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/app/router/app_route_observer.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/features/authentication/presentation/forget_password_screen.dart';
import 'package:ezbookkeeping/features/authentication/presentation/login_screen.dart';
import 'package:ezbookkeeping/features/authentication/presentation/register_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/account_list_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/add_account_screen.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_details_screen.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_list_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/add_transaction_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_page_layout_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/settings_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/user_profile_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/data_management_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/two_factor_auth_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/application_lock_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/exchange_rates_data_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/about_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/preferences_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/account_category_order_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/chart_color_scheme_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_transaction_categories_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_transaction_tags_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/device_and_sessions_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/text_size_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/statistics_settings_screen.dart';
import 'package:ezbookkeeping/features/statistics/presentation/statistics_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/transaction_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/primary_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/secondary_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/add_category_screen.dart';
import 'package:ezbookkeeping/features/tags/presentation/transaction_tags_screen.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_event.dart';
import 'package:ezbookkeeping/features/templates/presentation/transaction_templates_screen.dart';
import 'package:ezbookkeeping/features/templates/presentation/add_transaction_template_screen.dart';
import 'package:ezbookkeeping/features/templates/models/transaction_template.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';
import 'package:ezbookkeeping/core/theme/theme_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  observers: [AppRouteObserver()],
  redirect: (BuildContext context, GoRouterState state) async {
    if (!getIt.isRegistered<TokenStorage>()) {
      return null;
    }

    String? token;
    try {
      token = await getIt<TokenStorage>().getToken();
    } catch (_) {}

    final isAuthRoute =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register ||
        state.matchedLocation == AppRoutes.forgetPassword;

    final isAuthenticated = token != null && token.trim().isNotEmpty;

    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.forgetPassword,
      name: 'forget_password',
      builder: (context, state) {
        return const ForgetPasswordScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      name: 'add_transaction',
      builder: (context, state) {
        dynamic transactionToEdit;
        String? pageTitle;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          transactionToEdit = map['transaction'];
          pageTitle = map['title'] as String?;
        } else if (state.extra != null) {
          transactionToEdit = state.extra;
        }
        return AddTransactionScreen(
          transactionToEdit: transactionToEdit,
          pageTitle: pageTitle,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) {
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.accounts,
      name: 'accounts',
      builder: (context, state) {
        return const AccountListScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.addAccount,
      name: 'add_account',
      builder: (context, state) {
        return const AddAccountScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.transactions,
      name: 'transactions',
      builder: (context, state) {
        String? accountId;
        String? accountName;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          accountId = map['accountId'] as String?;
          accountName = map['accountName'] as String?;
        } else if (state.extra is String) {
          accountId = state.extra as String;
        } else if (state.uri.queryParameters.containsKey('account_id')) {
          accountId = state.uri.queryParameters['account_id'];
          accountName = state.uri.queryParameters['account_name'];
        }
        return TransactionListScreen(
          accountId: accountId,
          accountName: accountName,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionDetails,
      name: 'transaction_details',
      builder: (context, state) {
        String transactionId = '';
        if (state.extra is String) {
          transactionId = state.extra as String;
        } else if (state.extra is Map<String, dynamic>) {
          transactionId =
              (state.extra as Map<String, dynamic>)['transactionId']
                  as String? ??
              '';
        } else if (state.uri.queryParameters.containsKey('id')) {
          transactionId = state.uri.queryParameters['id'] ?? '';
        }
        return TransactionDetailsScreen(transactionId: transactionId);
      },
    ),
    GoRoute(
      path: AppRoutes.userProfile,
      name: 'user_profile',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<UserProfileBloc>()),
            BlocProvider(create: (context) => getIt<UpdateUserProfileBloc>()),
          ],
          child: const UserProfileScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionCategories,
      name: 'transaction_categories',
      builder: (context, state) {
        return const TransactionCategoriesScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.primaryCategories,
      name: 'primary_categories',
      builder: (context, state) {
        String categoryType = 'Expense';
        if (state.extra is String) {
          categoryType = state.extra as String;
        } else if (state.extra is Map<String, dynamic>) {
          categoryType =
              (state.extra as Map<String, dynamic>)['categoryType']
                  as String? ??
              'Expense';
        }
        return PrimaryCategoriesScreen(categoryType: categoryType);
      },
    ),
    GoRoute(
      path: AppRoutes.secondaryCategories,
      name: 'secondary_categories',
      builder: (context, state) {
        String primaryCategoryName = 'Food & Drink';
        String? parentId;
        String categoryType = 'Expense';
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          primaryCategoryName =
              map['primaryCategoryName'] as String? ?? primaryCategoryName;
          parentId = map['parentId'] as String?;
          categoryType = map['categoryType'] as String? ?? categoryType;
        }
        return SecondaryCategoriesScreen(
          primaryCategoryName: primaryCategoryName,
          parentId: parentId,
          categoryType: categoryType,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addCategory,
      name: 'add_category',
      builder: (context, state) {
        bool isPrimary = false;
        String? primaryCategoryName;
        String? parentId;
        String categoryType = 'Expense';
        Color? initialColor;
        IconData? initialIcon;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          isPrimary = map['isPrimary'] as bool? ?? false;
          primaryCategoryName = map['primaryCategoryName'] as String?;
          parentId = map['parentId'] as String?;
          categoryType = map['categoryType'] as String? ?? 'Expense';
          initialColor = map['initialColor'] as Color?;
          initialIcon = map['initialIcon'] as IconData?;
        }
        return AddCategoryScreen(
          isPrimary: isPrimary,
          primaryCategoryName: primaryCategoryName,
          parentId: parentId,
          categoryType: categoryType,
          initialColor: initialColor,
          initialIcon: initialIcon,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionTags,
      name: 'transaction_tags',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              getIt<TagsBloc>()..add(const LoadTagsRequested()),
          child: const TransactionTagsScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionTemplates,
      name: 'transaction_templates',
      builder: (context, state) {
        return const TransactionTemplatesScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.addTransactionTemplate,
      name: 'add_transaction_template',
      builder: (context, state) {
        final template = state.extra as TransactionTemplate?;
        return AddTransactionTemplateScreen(templateToEdit: template);
      },
    ),
    GoRoute(
      path: AppRoutes.dataManagement,
      name: 'data_management',
      builder: (context, state) {
        return const DataManagementScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.twoFactorAuth,
      name: 'two_factor_auth',
      builder: (context, state) {
        return const TwoFactorAuthScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.deviceAndSessions,
      name: 'device_and_sessions',
      builder: (context, state) {
        return const DeviceAndSessionsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.textSize,
      name: 'text_size',
      builder: (context, state) {
        final currentTheme = ThemeScope.maybeOf(context);
        final initial =
            (state.extra as String?) ??
            currentTheme?.currentTextScale.label ??
            'Default';
        return TextSizeScreen(initialSize: initial);
      },
    ),
    GoRoute(
      path: AppRoutes.applicationLock,
      name: 'application_lock',
      builder: (context, state) {
        final status = state.extra as String?;
        return ApplicationLockScreen(initialStatus: status);
      },
    ),
    GoRoute(
      path: AppRoutes.exchangeRatesData,
      name: 'exchange_rates_data',
      builder: (context, state) {
        return const ExchangeRatesDataScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.about,
      name: 'about',
      builder: (context, state) {
        return const AboutScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.statistics,
      name: 'statistics',
      builder: (context, state) {
        return const StatisticsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.preferences,
      name: 'preferences',
      builder: (context, state) {
        return const PreferencesScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.accountCategoryOrder,
      name: 'account_category_order',
      builder: (context, state) {
        return const AccountCategoryOrderScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.chartColorScheme,
      name: 'chart_color_scheme',
      builder: (context, state) {
        return const ChartColorSchemeScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.filterAccounts,
      name: 'filter_accounts',
      builder: (context, state) {
        FilterAccountsTarget target = FilterAccountsTarget.overview;
        String? title;
        if (state.extra is FilterAccountsTarget) {
          target = state.extra as FilterAccountsTarget;
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          target = map['target'] as FilterAccountsTarget? ??
              FilterAccountsTarget.overview;
          title = map['title'] as String?;
        } else if (state.uri.queryParameters['target'] == 'total') {
          target = FilterAccountsTarget.total;
        }
        return FilterAccountsScreen(
          target: target,
          title: title,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.filterTransactionCategories,
      name: 'filter_transaction_categories',
      builder: (context, state) {
        return const FilterTransactionCategoriesScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.filterTransactionTags,
      name: 'filter_transaction_tags',
      builder: (context, state) {
        return const FilterTransactionTagsScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.homePageLayout,
      name: 'home_page_layout',
      builder: (context, state) {
        return const HomePageLayoutScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.statisticsSettings,
      name: 'statistics_settings',
      builder: (context, state) {
        return const StatisticsSettingsScreen();
      },
    ),
  ],
);
