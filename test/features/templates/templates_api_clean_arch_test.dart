import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/templates/data/datasources/templates_remote_data_source.dart';
import 'package:ezbookkeeping/features/templates/data/models/add_transaction_template_request_model.dart';
import 'package:ezbookkeeping/features/templates/data/models/template_list_response_model.dart';
import 'package:ezbookkeeping/features/templates/data/models/transaction_template_model.dart';
import 'package:ezbookkeeping/features/templates/data/repositories/templates_repository_impl.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/add_transaction_template_use_case.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/get_transaction_templates_use_case.dart';
import 'package:ezbookkeeping/features/templates/presentation/add_transaction_template_screen.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_bloc.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_event.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_state.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';

void main() {
  group('AddTransactionTemplateRequestModel Tests', () {
    test('serializes to exact JSON structure requested by API', () {
      final model = AddTransactionTemplateRequestModel(
        templateType: 1,
        name: 'gdywg',
        type: 3,
        categoryId: '3845555742035673099',
        clientSessionId: '4c978cdd-fd30-8155-ba07-31870f64c3bc',
        comment: '',
        destinationAccountId: '0',
        destinationAmount: 0,
        hideAmount: false,
        sourceAccountId: '3845555741767237633',
        sourceAmount: 30000,
        tagIds: const [],
      );

      final json = model.toJson();

      expect(json['templateType'], 1);
      expect(json['name'], 'gdywg');
      expect(json['type'], 3);
      expect(json['categoryId'], '3845555742035673099');
      expect(json['clientSessionId'], '4c978cdd-fd30-8155-ba07-31870f64c3bc');
      expect(json['comment'], '');
      expect(json['destinationAccountId'], '0');
      expect(json['destinationAmount'], 0);
      expect(json['hideAmount'], false);
      expect(json['sourceAccountId'], '3845555741767237633');
      expect(json['sourceAmount'], 30000);
      expect(json['tagIds'], isEmpty);
    });
  });

  group('TransactionTemplateModel & Entity Tests', () {
    test('parses API response JSON into Model and converts to Domain Entity', () {
      final json = {
        'id': '3845557444390424576',
        'templateType': 1,
        'name': 'gdywg',
        'type': 3,
        'categoryId': '3845555742035673099',
        'sourceAccountId': '3845555741767237633',
        'destinationAccountId': '0',
        'sourceAmount': 30000,
        'destinationAmount': 0,
        'hideAmount': false,
        'tagIds': <dynamic>[],
        'comment': '',
        'displayOrder': 1,
        'hidden': false,
      };

      final model = TransactionTemplateModel.fromJson(json);
      expect(model.id, '3845557444390424576');
      expect(model.templateType, 1);
      expect(model.name, 'gdywg');
      expect(model.type, 3);
      expect(model.categoryId, '3845555742035673099');
      expect(model.sourceAccountId, '3845555741767237633');
      expect(model.destinationAccountId, '0');
      expect(model.sourceAmount, 30000);
      expect(model.destinationAmount, 0);
      expect(model.hideAmount, false);
      expect(model.tagIds, isEmpty);
      expect(model.comment, '');
      expect(model.displayOrder, 1);
      expect(model.hidden, false);

      final entity = model.toEntity();
      expect(entity.id, '3845557444390424576');
      expect(entity.name, 'gdywg');
      expect(entity.amount, 300.0);
    });

    test('TemplateListResponseModel parses list of templates correctly', () {
      final json = {
        'success': true,
        'result': [
          {
            'id': '101',
            'templateType': 1,
            'name': 'Groceries',
            'type': 3,
            'categoryId': '201',
            'sourceAccountId': '301',
            'destinationAccountId': '0',
            'sourceAmount': 5000,
            'destinationAmount': 0,
            'hideAmount': false,
            'tagIds': ['tag1'],
            'comment': 'Weekly grocery',
            'displayOrder': 1,
            'hidden': false,
          }
        ]
      };

      final listResponse = TemplateListResponseModel.fromJson(json);
      expect(listResponse.success, isTrue);
      expect(listResponse.templates.length, 1);
      expect(listResponse.templates.first.name, 'Groceries');
    });
  });

  group('TemplatesRepositoryImpl & Use Cases Tests', () {
    test('addTransactionTemplate calls remote data source and returns Right(entity)', () async {
      final mockDataSource = _FakeRemoteDataSource();
      final repository = TemplatesRepositoryImpl(remoteDataSource: mockDataSource);
      final useCase = AddTransactionTemplateUseCase(repository);

      final request = AddTransactionTemplateRequestModel(
        clientSessionId: 'mock-session-id',
        name: 'New Template',
        type: 3,
        categoryId: 'cat_1',
        sourceAccountId: 'acc_1',
        sourceAmount: 1500,
        tagIds: const [],
      );

      final result = await useCase(request);

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Should not return failure'),
        (r) {
          expect(r.name, 'New Template');
          expect(r.id, 'mock_id_123');
        },
      );
    });

    test('addTransactionTemplate returns Left(Failure) when remote data source throws exception', () async {
      final mockDataSource = _ErrorRemoteDataSource();
      final repository = TemplatesRepositoryImpl(remoteDataSource: mockDataSource);
      final useCase = AddTransactionTemplateUseCase(repository);

      final request = AddTransactionTemplateRequestModel(
        clientSessionId: 'mock-session-id',
        name: 'Error Template',
        type: 3,
        categoryId: 'cat_1',
        sourceAccountId: 'acc_1',
        sourceAmount: 1500,
        tagIds: const [],
      );

      final result = await useCase(request);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('API Server Error'));
        },
        (r) => fail('Should not return success'),
      );
    });
  });

  group('TemplatesBloc Tests', () {
    test('emits [TransactionTemplateAddLoading, TransactionTemplateAddSuccess, LoadTemplatesRequested] on AddTransactionTemplateRequested', () async {
      final mockDataSource = _FakeRemoteDataSource();
      final repository = TemplatesRepositoryImpl(remoteDataSource: mockDataSource);
      final addUseCase = AddTransactionTemplateUseCase(repository);
      final getUseCase = GetTransactionTemplatesUseCase(repository);

      final bloc = TemplatesBloc(
        addTemplate: addUseCase,
        getTemplates: getUseCase,
      );

      final states = <TemplatesState>[];
      final subscription = bloc.stream.listen(states.add);

      final request = AddTransactionTemplateRequestModel(
        clientSessionId: 'mock-session-id',
        name: 'Bloc Template',
        type: 3,
        categoryId: 'cat_1',
        sourceAccountId: 'acc_1',
        sourceAmount: 2500,
        tagIds: const [],
      );

      bloc.add(AddTransactionTemplateRequested(request));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const TransactionTemplateAddLoading(),
        isA<TransactionTemplateAddSuccess>(),
        const TemplatesLoading(),
        isA<TemplatesLoaded>(),
      ]);

      await subscription.cancel();
      await bloc.close();
    });
  });

  group('AddTransactionTemplateScreen Widget Tests', () {
    testWidgets('renders screen and allows input', (tester) async {
      final mockDataSource = _FakeRemoteDataSource();
      final repository = TemplatesRepositoryImpl(remoteDataSource: mockDataSource);
      final addUseCase = AddTransactionTemplateUseCase(repository);

      await tester.pumpWidget(
        MaterialApp(
          home: AddTransactionTemplateScreen(
            initialType: TransactionType.expense,
            addTransactionTemplateUseCase: addUseCase,
            templatesRepository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Transaction Template'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });
  });
}

class _FakeRemoteDataSource implements TemplatesRemoteDataSource {
  @override
  Future<TemplateListResponseModel> getTransactionTemplates() async {
    return const TemplateListResponseModel(
      success: true,
      result: [
        TransactionTemplateModel(
          id: 'mock_id_123',
          templateType: 1,
          name: 'Mock Template',
          type: 3,
          categoryId: 'cat_1',
          sourceAccountId: 'acc_1',
          destinationAccountId: '0',
          sourceAmount: 1000,
          destinationAmount: 0,
          hideAmount: false,
          tagIds: [],
          comment: '',
          displayOrder: 1,
          hidden: false,
        )
      ],
    );
  }

  @override
  Future<TransactionTemplateModel> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  ) async {
    return TransactionTemplateModel(
      id: 'mock_id_123',
      templateType: request.templateType,
      name: request.name,
      type: request.type,
      categoryId: request.categoryId,
      sourceAccountId: request.sourceAccountId,
      destinationAccountId: request.destinationAccountId,
      sourceAmount: request.sourceAmount,
      destinationAmount: request.destinationAmount,
      hideAmount: request.hideAmount,
      tagIds: request.tagIds,
      comment: request.comment,
      displayOrder: 1,
      hidden: false,
    );
  }
}

class _ErrorRemoteDataSource implements TemplatesRemoteDataSource {
  @override
  Future<TemplateListResponseModel> getTransactionTemplates() async {
    throw const ServerException('API Server Error', 500);
  }

  @override
  Future<TransactionTemplateModel> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  ) async {
    throw const ServerException('API Server Error', 500);
  }
}
