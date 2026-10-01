import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Clean Architecture Use Case for adding a transaction tag in ezBookkeeping.
class AddTransactionTagUseCase {
  const AddTransactionTagUseCase(this.repository);

  final TagsRepository repository;

  Future<Either<Failure, TagItem>> call(
    AddTransactionTagRequestModel request,
  ) async {
    return repository.addTag(request);
  }
}

/// Convenience alias
typedef AddTransactionTag = AddTransactionTagUseCase;
