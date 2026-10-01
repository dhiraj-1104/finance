import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_transaction_template_use_case.dart';
import '../../domain/usecases/get_transaction_templates_use_case.dart';
import 'templates_event.dart';
import 'templates_state.dart';

class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  final AddTransactionTemplateUseCase addTemplate;
  final GetTransactionTemplatesUseCase getTemplates;

  TemplatesBloc({
    required this.addTemplate,
    required this.getTemplates,
  }) : super(const TemplatesInitial()) {
    on<LoadTemplatesRequested>(_onLoadTemplatesRequested);
    on<AddTransactionTemplateRequested>(_onAddTransactionTemplateRequested);
  }

  Future<void> _onLoadTemplatesRequested(
    LoadTemplatesRequested event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());
    try {
      final templates = await getTemplates(
        templateType: event.templateType,
      );
      emit(TemplatesLoaded(templates: templates));
    } catch (e) {
      emit(TemplatesError(message: e.toString()));
    }
  }

  Future<void> _onAddTransactionTemplateRequested(
    AddTransactionTemplateRequested event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TransactionTemplateAddLoading());
    final resultEither = await addTemplate(event.request);
    resultEither.fold(
      (failure) => emit(TransactionTemplateAddFailure(message: failure.message)),
      (template) {
        emit(TransactionTemplateAddSuccess(template: template));
        add(LoadTemplatesRequested(
          templateType: event.request.templateType,
          forceRefresh: false,
        ));
      },
    );
  }
}

typedef TransactionTemplatesBloc = TemplatesBloc;
