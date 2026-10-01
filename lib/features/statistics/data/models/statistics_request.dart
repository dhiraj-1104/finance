/// Request parameters for statistics querying.
class StatisticsRequest {
  final int? startTime;
  final int? endTime;
  final int
  chartDataType; // 1: expense by primary, 2: expense by secondary, 3: income by primary, 4: income by secondary, 5: total expense, 6: total income, 7: net income
  final bool useTransactionTimezone;

  const StatisticsRequest({
    this.startTime,
    this.endTime,
    this.chartDataType = 1,
    this.useTransactionTimezone = false,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'chart_data_type': chartDataType,
      'chartDataType': chartDataType,
      'use_transaction_timezone': useTransactionTimezone,
    };
    if (startTime != null) {
      params['start_time'] = startTime;
      params['startTime'] = startTime;
      params['min_time'] = startTime;
    }
    if (endTime != null) {
      params['end_time'] = endTime;
      params['endTime'] = endTime;
      params['max_time'] = endTime;
    }
    return params;
  }
}
