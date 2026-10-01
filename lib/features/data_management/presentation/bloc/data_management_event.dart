import 'package:equatable/equatable.dart';

/// Base class for all Data Management events.
sealed class DataManagementEvent extends Equatable {
  const DataManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading or refreshing of data management statistics.
final class LoadDataManagementStatistics extends DataManagementEvent {
  final bool forceRefresh;

  const LoadDataManagementStatistics({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Convenience aliases
typedef LoadStatisticsRequested = LoadDataManagementStatistics;
typedef GetDataManagementStatisticsRequested = LoadDataManagementStatistics;
