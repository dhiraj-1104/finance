import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case that fetches complete details for a single transaction by ID
/// and hydrates it with resolved Category and Account entities from in-memory cache.
class GetTransactionDetails {
  const GetTransactionDetails(
    this.repository, {
    this.accountsRepository,
    this.categoriesRepository,
  });

  final TransactionRepository repository;
  final AccountsRepository? accountsRepository;
  final CategoriesRepository? categoriesRepository;

  Future<Either<Failure, Transaction>> call(String transactionId) async {
    final txEither = await repository.getTransactionById(transactionId);

    return txEither.fold((failure) => Left(failure), (tx) async {
      // Fetch accounts to resolve source & destination accounts
      Account? sourceAccount;
      Account? destinationAccount;
      if (accountsRepository != null) {
        try {
          final accountsEither = await accountsRepository!.getAccounts();
          accountsEither.forEach((accounts) {
            for (final acc in accounts) {
              if (acc.id == tx.sourceAccountId) sourceAccount = acc;
              if (acc.id == tx.destinationAccountId) destinationAccount = acc;
              for (final sub in acc.subAccounts) {
                if (sub.id == tx.sourceAccountId) sourceAccount = sub;
                if (sub.id == tx.destinationAccountId) destinationAccount = sub;
              }
            }
          });
        } catch (_) {
          // Fallback gracefully
        }
      }

      // Access in-memory stored categories map
      Map<String, CategoryItem> categoryMap = {};
      if (categoriesRepository != null) {
        try {
          categoryMap = await categoriesRepository!.getCategoriesMap();
        } catch (_) {
          // Fallback gracefully
        }
      }

      final category = categoryMap[tx.categoryId];
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

      final effectiveCategoryName = resolvedCategoryName?.isNotEmpty == true
          ? resolvedCategoryName
          : (tx.categoryName?.isNotEmpty == true
                ? tx.categoryName
                : (tx.displayTitle.isNotEmpty &&
                          tx.displayTitle != 'Expense' &&
                          tx.displayTitle != 'Income' &&
                          tx.displayTitle != 'Transfer'
                      ? tx.displayTitle
                      : null));

      return Right(
        tx.copyWith(
          categoryName: effectiveCategoryName,
          category: category,
          sourceAccount: sourceAccount,
          destinationAccount: destinationAccount,
        ),
      );
    });
  }
}
