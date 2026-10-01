import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that fetches the list of transactions matching the given filter criteria
/// and hydrates each transaction with resolved Category and Account objects from in-memory cache.
class GetTransactions {
  const GetTransactions(
    this.repository, {
    this.accountsRepository,
    this.categoriesRepository,
  });

  final TransactionRepository repository;
  final AccountsRepository? accountsRepository;
  final CategoriesRepository? categoriesRepository;

  Future<Either<Failure, TransactionListResult>> call([
    TransactionListRequest? request,
  ]) async {
    final resultEither = await repository.getTransactions(
      request ?? const TransactionListRequest(),
    );

    return resultEither.fold((failure) => Left(failure), (result) async {
      // Fetch accounts in a single batch to avoid N+1 requests
      final Map<String, Account> accountMap = {};
      if (accountsRepository != null) {
        try {
          final accountsEither = await accountsRepository!.getAccounts();
          accountsEither.forEach((accounts) {
            for (final acc in accounts) {
              accountMap[acc.id] = acc;
              for (final sub in acc.subAccounts) {
                accountMap[sub.id] = sub;
              }
            }
          });
        } catch (_) {
          // Fallback gracefully if account retrieval fails
        }
      }

      // Access in-memory stored categories map
      Map<String, CategoryItem> categoryMap = {};
      if (categoriesRepository != null) {
        try {
          categoryMap = await categoriesRepository!.getCategoriesMap();
        } catch (_) {
          // Fallback gracefully if categories retrieval fails
        }
      }

      // Hydrate each transaction with O(1) stored category and account lookups
      final hydratedItems = result.items.map((tx) {
        final category = categoryMap[tx.categoryId];
        final sourceAccount = accountMap[tx.sourceAccountId];
        final destinationAccount = tx.destinationAccountId != null
            ? accountMap[tx.destinationAccountId]
            : null;
        String? resolvedCategoryName;
        if (category != null) {
          if (category.parentId != null &&
              category.parentId != '0' &&
              categoryMap.containsKey(category.parentId)) {
            final parent = categoryMap[category.parentId]!;
            resolvedCategoryName = '${parent.name} > ${category.name}';
          } else {
            resolvedCategoryName = category.name;
          }
        }
        final effectiveCategoryName = resolvedCategoryName ?? tx.categoryName;

        return tx.copyWith(
          categoryName: effectiveCategoryName,
          category: category,
          sourceAccount: sourceAccount,
          destinationAccount: destinationAccount,
        );
      }).toList();

      return Right(
        TransactionListResult(
          items: hydratedItems,
          nextTimeSequenceId: result.nextTimeSequenceId,
        ),
      );
    });
  }
}
