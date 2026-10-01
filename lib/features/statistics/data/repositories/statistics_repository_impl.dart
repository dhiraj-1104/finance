import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_data.dart';
import 'package:ezbookkeeping/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';

/// Implementation of [StatisticsRepository] coordinating data parsing and domain mapping.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final TransactionRepository? transactionRepository;
  final CategoriesRepository? categoriesRepository;
  final AccountsRepository? accountsRepository;

  const StatisticsRepositoryImpl({
    required this.remoteDataSource,
    this.transactionRepository,
    this.categoriesRepository,
    this.accountsRepository,
  });

  @override
  Future<Either<Failure, StatisticData>> getStatistics(
    StatisticsRequest request,
  ) async {
    try {
      // 1. Fetch categories and accounts lookup maps for name and icon hydration
      Map<String, CategoryItem> categoriesMap = {};
      if (categoriesRepository != null) {
        try {
          categoriesMap = await categoriesRepository!.getCategoriesMap();
        } catch (_) {}
      }

      Map<String, Account> accountsMap = {};
      if (accountsRepository != null) {
        try {
          final accEither = await accountsRepository!.getAccounts();
          accEither.fold((_) {}, (accList) {
            for (final a in accList) {
              accountsMap[a.id] = a;
              for (final sub in a.subAccounts) {
                accountsMap[sub.id] = sub;
              }
            }
          });
        } catch (_) {}
      }

      // 2. Fetch remote statistics from API endpoint
      final json = await remoteDataSource.getStatistics(request);
      final result = json['result'];

      List<dynamic> rawItems = [];
      if (result is List) {
        rawItems = result;
      } else if (result is Map<String, dynamic>) {
        if (result['items'] is List) {
          rawItems = result['items'] as List<dynamic>;
        } else if (result['categories'] is List) {
          rawItems = result['categories'] as List<dynamic>;
        } else if (result['data'] is List) {
          rawItems = result['data'] as List<dynamic>;
        } else if (result['trends'] is List) {
          rawItems = result['trends'] as List<dynamic>;
        } else {
          rawItems = result.values.whereType<Map<String, dynamic>>().toList();
        }
      }

      final categories = <StatisticCategoryItem>[];
      double total = 0;

      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          final catId =
              item['categoryId']?.toString() ??
              item['category_id']?.toString() ??
              item['id']?.toString();
          final accId =
              item['accountId']?.toString() ?? item['account_id']?.toString();

          final matchedCat = (catId != null) ? categoriesMap[catId] : null;
          final matchedAcc = (accId != null) ? accountsMap[accId] : null;

          final name =
              item['name']?.toString() ??
              item['categoryName']?.toString() ??
              item['category_name']?.toString() ??
              item['accountName']?.toString() ??
              item['account_name']?.toString() ??
              matchedCat?.name ??
              matchedAcc?.name ??
              item['title']?.toString() ??
              'Other';

          final id = catId ?? accId ?? name;

          final iconId =
              item['categoryIconId']?.toString() ??
              item['category_icon_id']?.toString() ??
              item['iconId']?.toString() ??
              item['icon_id']?.toString() ??
              item['icon']?.toString();

          final colorHex =
              item['color']?.toString() ??
              item['categoryColor']?.toString() ??
              item['category_color']?.toString();

          final IconData icon =
              matchedCat?.icon ??
              (matchedAcc != null
                  ? CategoryIconHelper.getIcon(
                      matchedAcc.icon,
                      categoryName: name,
                    )
                  : CategoryIconHelper.getIcon(iconId, categoryName: name));

          final Color color =
              matchedCat?.color ??
              (matchedAcc != null
                  ? CategoryIconHelper.parseColor(
                      matchedAcc.color,
                      fallback: _getColorForIndex(categories.length),
                    )
                  : CategoryIconHelper.parseColor(
                      colorHex,
                      fallback: _getColorForIndex(categories.length),
                    ));

          final rawAmount =
              item['totalAmount'] ??
              item['amount'] ??
              item['total_amount'] ??
              item['balance'] ??
              item['value'] ??
              0;

          double amount = 0.0;
          if (rawAmount is num) {
            amount = rawAmount.toDouble().abs() / 100.0;
          } else if (rawAmount is String) {
            final val = double.tryParse(rawAmount) ?? 0.0;
            amount = val.abs() / 100.0;
          }

          categories.add(
            StatisticCategoryItem(
              id: id,
              name: name,
              icon: icon,
              color: color,
              amount: amount,
              percentage: 0,
            ),
          );
          total += amount;
        }
      }

      if (categories.isNotEmpty) {
        final withPercentages = categories.map((c) {
          final pct = total > 0 ? (c.amount / total) * 100 : 0.0;
          return c.copyWith(percentage: double.parse(pct.toStringAsFixed(2)));
        }).toList();

        return Right(
          StatisticData(totalAmount: total, categories: withPercentages),
        );
      }

      // 3. Fallback: If remote statistics API returned no items, aggregate from transaction list
      if (transactionRepository != null) {
        final txResult = await _aggregateFromTransactions(
          request,
          categoriesMap,
          accountsMap,
        );
        if (txResult != null && txResult.categories.isNotEmpty) {
          return Right(txResult);
        }
      }

      return const Right(StatisticData(totalAmount: 0.0, categories: []));
    } catch (e) {
      if (transactionRepository != null) {
        try {
          final txResult = await _aggregateFromTransactions(request, {}, {});
          if (txResult != null) {
            return Right(txResult);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<StatisticData?> _aggregateFromTransactions(
    StatisticsRequest request,
    Map<String, CategoryItem> categoriesMap,
    Map<String, Account> accountsMap,
  ) async {
    if (transactionRepository == null) return null;

    final txRequest = TransactionListRequest(
      minTime: request.startTime ?? 0,
      maxTime: request.endTime ?? 0,
      count: 50,
    );

    final txEither = await transactionRepository!.getTransactions(txRequest);
    return txEither.fold((failure) => null, (txResult) {
      final transactions = txResult.items;
      if (transactions.isEmpty) return null;

      final isIncomeScope =
          request.chartDataType == 3 ||
          request.chartDataType == 4 ||
          request.chartDataType == 6;

      final isAccountScope =
          request.chartDataType == 5 || request.chartDataType == 6;

      final filtered = transactions.where((t) {
        if (isIncomeScope) {
          return t.isIncome || t.sourceAmount > 0;
        } else if (request.chartDataType == 7) {
          return true;
        } else {
          return t.isExpense || t.sourceAmount < 0;
        }
      }).toList();

      if (filtered.isEmpty) return null;

      final groupTotals = <String, double>{};
      final groupIcons = <String, IconData>{};
      final groupColors = <String, Color>{};

      for (final t in filtered) {
        String key;
        IconData icon;
        Color color;

        if (isAccountScope) {
          final acc = accountsMap[t.sourceAccountId] ?? t.sourceAccount;
          key = acc?.name ?? 'Account';
          icon = CategoryIconHelper.getIcon(acc?.icon, categoryName: key);
          color = CategoryIconHelper.parseColor(
            acc?.color,
            fallback: _getColorForIndex(groupTotals.length),
          );
        } else {
          final cat = categoriesMap[t.categoryId] ?? t.category;
          key = cat?.name ?? t.categoryName ?? 'Other';
          icon =
              cat?.icon ?? CategoryIconHelper.getIcon(null, categoryName: key);
          color = cat?.color ?? _getColorForIndex(groupTotals.length);
        }

        final amount = (t.sourceAmount.abs()) / 100.0;
        groupTotals[key] = (groupTotals[key] ?? 0.0) + amount;
        groupIcons[key] = icon;
        groupColors[key] = color;
      }

      final categories = <StatisticCategoryItem>[];
      double total = 0.0;

      groupTotals.forEach((name, amount) {
        total += amount;
        categories.add(
          StatisticCategoryItem(
            id: name,
            name: name,
            icon:
                groupIcons[name] ??
                CategoryIconHelper.getIcon(null, categoryName: name),
            color: groupColors[name] ?? _getColorForIndex(categories.length),
            amount: amount,
            percentage: 0,
          ),
        );
      });

      if (categories.isNotEmpty) {
        final withPercentages = categories.map((c) {
          final pct = total > 0 ? (c.amount / total) * 100 : 0.0;
          return c.copyWith(percentage: double.parse(pct.toStringAsFixed(2)));
        }).toList();

        return StatisticData(totalAmount: total, categories: withPercentages);
      }

      return null;
    });
  }

  static Color _getColorForIndex(int index) {
    const palette = [
      Color(0xFFC14660),
      Color(0xFFE35444),
      Color(0xFFF38426),
      Color(0xFFF8BA3E),
      Color(0xFF3AC79F),
      Color(0xFF27C5C4),
      Color(0xFF34AEE2),
      Color(0xFF1E5888),
    ];
    return palette[index % palette.length];
  }
}
