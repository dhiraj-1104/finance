import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_data_management_statistics_use_case.dart';
import 'data_management_event.dart';
import 'data_management_state.dart';

/// Flutter BLoC managing Data Management statistics state.
class DataManagementBloc
    extends Bloc<DataManagementEvent, DataManagementState> {
  final GetDataManagementStatisticsUseCase getStatistics;

  DataManagementBloc({required this.getStatistics})
      : super(const DataManagementInitial()) {
    on<LoadDataManagementStatistics>(_onLoadDataManagementStatistics);
  }

  Future<void> _onLoadDataManagementStatistics(
    LoadDataManagementStatistics event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(const DataManagementStatisticsLoading());
    final result = await getStatistics(forceRefresh: event.forceRefresh);
    result.fold(
      (failure) => emit(DataManagementStatisticsError(message: failure.message)),
      (statistics) =>
          emit(DataManagementStatisticsLoaded(statistics: statistics)),
    );
  }
}
