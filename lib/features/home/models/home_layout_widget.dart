import 'dart:convert';

/// Represents a widget configured on the Home Page layout.
class HomeLayoutWidget {
  final String id;
  final String type;
  final Map<String, dynamic> settings;

  const HomeLayoutWidget({
    required this.id,
    required this.type,
    this.settings = const {},
  });

  factory HomeLayoutWidget.fromJson(Map<String, dynamic> json) {
    return HomeLayoutWidget(
      id:
          json['id'] as String? ??
          'widget_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type'] as String? ?? 'current-month-overview',
      settings: json['settings'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['settings'] as Map)
          : (json['settings'] is Map
                ? (json['settings'] as Map).map(
                    (k, v) => MapEntry(k.toString(), v),
                  )
                : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type, 'settings': settings};
  }

  HomeLayoutWidget copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? settings,
  }) {
    return HomeLayoutWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      settings: settings ?? this.settings,
    );
  }

  String get displayName {
    switch (type) {
      case 'net-assets':
        return 'Net Assets';
      case 'current-month-overview':
        return 'Current Month Overview';
      case 'period-income-expense':
        return 'Period Income & Expense';
      case 'account-balance':
        return 'Account Balance';
      case 'month-expense':
        return 'Month Expense';
      case 'period-net-income-savings-rate':
        return 'Period Net Income and Savings Rate';
      case 'expense-category-ranking':
        return 'Expense Category Ranking';
      case 'recent-transactions':
        return 'Recent Transactions';
      case 'transaction-calendar':
        return 'Transaction Calendar';
      case 'add-transaction-button':
        return 'Add Transaction Button';
      default:
        return type;
    }
  }
}

const String defaultHomeLayoutJson = '''{
  "widgets": [
    {
      "id": "default-current-month-overview",
      "type": "current-month-overview",
      "settings": {
        "height": 3,
        "lightBackgroundColor": "edddcd",
        "darkBackgroundColor": "7f5e4b"
      }
    },
    {
      "id": "default-period-income-expense",
      "type": "period-income-expense",
      "settings": {}
    }
  ]
}''';

List<HomeLayoutWidget> get defaultHomeLayoutWidgets {
  try {
    final decoded = jsonDecode(defaultHomeLayoutJson);
    if (decoded is Map<String, dynamic> && decoded['widgets'] is List) {
      return (decoded['widgets'] as List)
          .map(
            (item) => HomeLayoutWidget.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
  } catch (_) {}
  return const [];
}

/// Represents a single day item in the Transaction Calendar widget.
class CalendarDayData {
  final int? day;
  final String? income;
  final String? expense;
  final bool isSelected;

  const CalendarDayData({
    this.day,
    this.income,
    this.expense,
    this.isSelected = false,
  });
}
