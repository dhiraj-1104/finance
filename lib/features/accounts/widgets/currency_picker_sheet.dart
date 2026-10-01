import 'package:flutter/material.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final String selectedCurrencyCode;
  final ValueChanged<Map<String, String>> onCurrencySelected;

  const CurrencyPickerSheet({
    super.key,
    required this.selectedCurrencyCode,
    required this.onCurrencySelected,
  });

  static void show(
    BuildContext context, {
    required String selectedCurrencyCode,
    required ValueChanged<Map<String, String>> onCurrencySelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CurrencyPickerSheet(
        selectedCurrencyCode: selectedCurrencyCode,
        onCurrencySelected: onCurrencySelected,
      ),
    );
  }

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  static const List<Map<String, String>> _allCurrencies = [
    {'name': 'United States Dollar', 'code': 'USD', 'symbol': r'$'},
    {'name': 'Euro', 'code': 'EUR', 'symbol': '€'},
    {'name': 'British Pound', 'code': 'GBP', 'symbol': '£'},
    {'name': 'Japanese Yen', 'code': 'JPY', 'symbol': '¥'},
    {'name': 'Chinese Yuan', 'code': 'CNY', 'symbol': '¥'},
    {'name': 'Indian Rupee', 'code': 'INR', 'symbol': '₹'},
    {'name': 'Australian Dollar', 'code': 'AUD', 'symbol': r'A$'},
    {'name': 'Canadian Dollar', 'code': 'CAD', 'symbol': r'C$'},
    {'name': 'Swiss Franc', 'code': 'CHF', 'symbol': 'CHF'},
    {'name': 'Trinidad and Tobago Dollar', 'code': 'TTD', 'symbol': r'TT$'},
    {'name': 'Tunisian Dinar', 'code': 'TND', 'symbol': 'DT'},
    {'name': 'Turkish Lira', 'code': 'TRY', 'symbol': '₺'},
    {'name': 'Turkmenistani Manat', 'code': 'TMT', 'symbol': 'm'},
    {'name': 'Ugandan Shilling', 'code': 'UGX', 'symbol': 'USh'},
    {'name': 'Ukrainian Hryvnia', 'code': 'UAH', 'symbol': '₴'},
    {'name': 'United Arab Emirates Dirham', 'code': 'AED', 'symbol': 'د.إ'},
    {'name': 'Uruguayan Peso', 'code': 'UYU', 'symbol': r'$U'},
    {'name': 'Uzbekistani Sum', 'code': 'UZS', 'symbol': 'soʻm'},
    {'name': 'Vanuatu Vatu', 'code': 'VUV', 'symbol': 'VT'},
    {'name': 'Venezuelan Bolívar Digital', 'code': 'VED', 'symbol': 'Bs.'},
    {'name': 'Venezuelan Bolívar Soberano', 'code': 'VES', 'symbol': 'Bs.S'},
    {'name': 'Vietnamese Dong', 'code': 'VND', 'symbol': '₫'},
  ];

  List<Map<String, String>> get _filteredCurrencies {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allCurrencies;
    return _allCurrencies.where((c) {
      return c['name']!.toLowerCase().contains(query) ||
          c['code']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF8E8E93);
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final checkColor = const Color(0xFFC86D3B);

    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Top Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Close button (✕)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: shadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Title or Search Bar
                Expanded(
                  child: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: TextStyle(color: textColor, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search currency...',
                              hintStyle: TextStyle(
                                color: subtextColor,
                                fontSize: 15,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        )
                      : Text(
                          'Currency Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                ),

                // Search Toggle Button (🔍)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: shadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) _searchController.clear();
                        });
                      },
                      child: Center(
                        child: Icon(
                          _isSearching
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Currency List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final curr = _filteredCurrencies[index];
                final isSelected = curr['code'] == widget.selectedCurrencyCode;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onCurrencySelected(curr);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // Left checkmark column
                          SizedBox(
                            width: 24,
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: checkColor,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),

                          // Currency Name
                          Expanded(
                            child: Text(
                              curr['name']!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),

                          // Currency Code on right (e.g. USD)
                          Text(
                            curr['code']!,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
