import '../../models/transaction_template.dart';
import '../repositories/templates_repository.dart';

class GetTransactionTemplatesUseCase {
  final TemplatesRepository repository;

  const GetTransactionTemplatesUseCase(this.repository);

  Future<List<TransactionTemplate>> call({
    int? templateType,
    bool forceRefresh = false,
  }) async {
    return await repository.getTransactionTemplates(
      templateType: templateType,
      forceRefresh: forceRefresh,
    );
  }
}

typedef GetTransactionTemplates = GetTransactionTemplatesUseCase;

