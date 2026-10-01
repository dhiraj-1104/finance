import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../../data/models/add_transaction_template_request_model.dart';
import '../../models/transaction_template.dart';

abstract class TemplatesRepository {
  Future<List<TransactionTemplate>> getTransactionTemplates({
    int? templateType,
    bool forceRefresh = false,
  });

  Future<List<TransactionTemplate>> getTemplates({
    int? templateType,
    bool forceRefresh = false,
  });

  Future<Either<Failure, TransactionTemplate>> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  );

  void clearCache();

  bool get isCacheValid;
}
