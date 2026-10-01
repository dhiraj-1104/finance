import 'package:equatable/equatable.dart';
import '../../models/transaction_template.dart';

sealed class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

final class TemplatesInitial extends TemplatesState {
  const TemplatesInitial();
}

final class TemplatesLoading extends TemplatesState {
  const TemplatesLoading();
}

final class TemplatesLoaded extends TemplatesState {
  final List<TransactionTemplate> templates;

  const TemplatesLoaded({required this.templates});

  @override
  List<Object?> get props => [templates];
}

final class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class TransactionTemplateAddLoading extends TemplatesState {
  const TransactionTemplateAddLoading();
}

final class TransactionTemplateAddSuccess extends TemplatesState {
  final TransactionTemplate template;

  const TransactionTemplateAddSuccess({required this.template});

  @override
  List<Object?> get props => [template];
}

final class TransactionTemplateAddFailure extends TemplatesState {
  final String message;

  const TransactionTemplateAddFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

typedef TemplateAdding = TransactionTemplateAddLoading;
typedef TemplateAddSuccess = TransactionTemplateAddSuccess;
typedef TemplateAddFailure = TransactionTemplateAddFailure;
