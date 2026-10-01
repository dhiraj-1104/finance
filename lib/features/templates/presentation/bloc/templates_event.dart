import 'package:equatable/equatable.dart';
import '../../data/models/add_transaction_template_request_model.dart';

sealed class TemplatesEvent extends Equatable {
  const TemplatesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTemplatesRequested extends TemplatesEvent {
  final int? templateType;
  final bool forceRefresh;

  const LoadTemplatesRequested({
    this.templateType,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [templateType, forceRefresh];
}

final class AddTransactionTemplateRequested extends TemplatesEvent {
  final AddTransactionTemplateRequestModel request;

  const AddTransactionTemplateRequested(this.request);

  factory AddTransactionTemplateRequested.fromRequest(
    AddTransactionTemplateRequestModel request,
  ) =>
      AddTransactionTemplateRequested(request);

  @override
  List<Object?> get props => [request];
}

typedef GetTemplatesRequested = LoadTemplatesRequested;
