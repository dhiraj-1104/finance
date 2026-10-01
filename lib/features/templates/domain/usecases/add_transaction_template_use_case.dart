import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../../data/models/add_transaction_template_request_model.dart';
import '../../models/transaction_template.dart';
import '../repositories/templates_repository.dart';

class AddTransactionTemplateUseCase {
  final TemplatesRepository repository;

  const AddTransactionTemplateUseCase(this.repository);

  Future<Either<Failure, TransactionTemplate>> call(
    AddTransactionTemplateRequestModel request,
  ) async {
    return await repository.addTransactionTemplate(request);
  }
}

typedef AddTransactionTemplate = AddTransactionTemplateUseCase;
