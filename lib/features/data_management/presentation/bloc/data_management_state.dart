import 'package:equatable/equatable.dart';
import '../../domain/entities/data_management_statistics.dart';

/// Base class for all Data Management states.
sealed class DataManagementState extends Equatable {
  const DataManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any statistics have been loaded.
final class DataManagementInitial extends DataManagementState {
  const DataManagementInitial();
}

/// State emitted while data management statistics are loading.
final class DataManagementStatisticsLoading extends DataManagementState {
  const DataManagementStatisticsLoading();
}

/// State emitted when data management statistics are successfully loaded.
final class DataManagementStatisticsLoaded extends DataManagementState {
  final DataManagementStatistics statistics;

  const DataManagementStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// State emitted when fetching data management statistics fails.
final class DataManagementStatisticsError extends DataManagementState {
  final String message;

  const DataManagementStatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Convenience aliases
typedef DataManagementLoading = DataManagementStatisticsLoading;
typedef DataManagementLoaded = DataManagementStatisticsLoaded;
typedef DataManagementError = DataManagementStatisticsError;
