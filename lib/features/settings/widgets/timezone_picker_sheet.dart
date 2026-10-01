import 'package:flutter/material.dart';

class TimezonePickerSheet extends StatefulWidget {
  final String currentTimezone;
  final ValueChanged<String>? onTimezoneSelected;

  const TimezonePickerSheet({
    super.key,
    required this.currentTimezone,
    this.onTimezoneSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentTimezone,
    ValueChanged<String>? onTimezoneSelected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimezonePickerSheet(
        currentTimezone: currentTimezone,
        onTimezoneSelected: onTimezoneSelected,
      ),
    );
  }

  static const List<String> defaultTimezones = [
    '(UTC-12:00) International Date Line West',
    '(UTC-11:00) Midway Island, Samoa',
    '(UTC-10:00) Hawaii',
    '(UTC-09:30) Marquesas Islands',
    '(UTC-09:00) Alaska',
    '(UTC-08:00) Pacific Time (US & Canada)',
    '(UTC-07:00) Mountain Time (US & Canada)',
    '(UTC-07:00) Arizona',
    '(UTC-06:00) Central Time (US & Canada)',
    '(UTC-06:00) Guadalajara, Mexico City, Monterrey',
    '(UTC-06:00) Saskatchewan',
    '(UTC-05:00) Eastern Time (US & Canada)',
    '(UTC-05:00) Bogota, Lima, Quito, Rio Branco',
    '(UTC-05:00) Indiana (East)',
    '(UTC-04:30) Caracas',
    '(UTC-04:00) Atlantic Time (Canada)',
    '(UTC-04:00) Manaus',
    '(UTC-04:00) Santiago',
    '(UTC-03:30) Newfoundland',
    '(UTC-03:00) Brasilia',
    '(UTC-03:00) Buenos Aires, Georgetown',
    '(UTC-03:00) Greenland',
    '(UTC-03:00) Montevideo',
    '(UTC-02:00) Mid-Atlantic',
    '(UTC-01:00) Cape Verde Is.',
    '(UTC-01:00) Azores',
    '(UTC+00:00) UTC',
    '(UTC+00:00) Casablanca, Monrovia, Reykjavik',
    '(UTC+00:00) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London',
    '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna',
    '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague',
    '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris',
    '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb',
    '(UTC+01:00) West Central Africa',
    '(UTC+02:00) Amman',
    '(UTC+02:00) Athens, Bucharest, Istanbul',
    '(UTC+02:00) Beirut',
    '(UTC+02:00) Cairo',
    '(UTC+02:00) Harare, Pretoria',
    '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius',
    '(UTC+02:00) Jerusalem',
    '(UTC+02:00) Minsk',
    '(UTC+02:00) Windhoek',
    '(UTC+03:00) Kuwait, Riyadh, Baghdad',
    '(UTC+03:00) Moscow, St. Petersburg, Volgograd',
    '(UTC+03:00) Nairobi',
    '(UTC+03:00) Tbilisi',
    '(UTC+03:30) Tehran',
    '(UTC+04:00) Abu Dhabi, Muscat',
    '(UTC+04:00) Baku',
    '(UTC+04:00) Yerevan',
    '(UTC+04:30) Kabul',
    '(UTC+05:00) Ashgabat, Tashkent',
    '(UTC+05:00) Astana',
    '(UTC+05:00) Ekaterinburg',
    '(UTC+05:00) Islamabad, Karachi',
    '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi',
    '(UTC+05:30) Sri Jayawardenepura',
    '(UTC+05:30) System Default',
    '(UTC+05:45) Kathmandu',
    '(UTC+06:00) Almaty, Novosibirsk',
    '(UTC+06:00) Bishkek',
    '(UTC+06:00) Dhaka',
    '(UTC+06:00) Omsk',
    '(UTC+06:30) Yangon (Rangoon)',
    '(UTC+07:00) Bangkok, Hanoi, Jakarta',
    '(UTC+07:00) Krasnoyarsk',
    '(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi',
    '(UTC+08:00) Kuala Lumpur, Singapore',
    '(UTC+08:00) Irkutsk, Ulaanbaatar',
    '(UTC+08:00) Perth',
    '(UTC+08:00) Taipei',
    '(UTC+08:45) Eucla',
    '(UTC+09:00) Osaka, Sapporo, Tokyo',
    '(UTC+09:00) Seoul',
    '(UTC+09:00) Yakutsk',
    '(UTC+09:30) Adelaide',
    '(UTC+09:30) Darwin',
    '(UTC+10:00) Brisbane',
    '(UTC+10:00) Canberra, Melbourne, Sydney',
    '(UTC+10:00) Guam, Port Moresby',
    '(UTC+10:00) Hobart',
    '(UTC+10:00) Vladivostok',
    '(UTC+10:30) Lord Howe Island',
    '(UTC+11:00) Magadan, Solomon Is., New Caledonia',
    '(UTC+11:30) Norfolk Island',
    '(UTC+12:00) Auckland, Wellington',
    '(UTC+12:00) Fiji, Kamchatka, Marshall Is.',
    '(UTC+12:45) Chatham Islands',
    '(UTC+13:00) Nuku\'alofa',
    '(UTC+13:00) Samoa',
    '(UTC+14:00) Kiritimati',
  ];

  @override
  State<TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<TimezonePickerSheet> {
  static const Color _copperColor = Color(0xFFC86D3B);

  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentSelection();
    });
  }

  void _scrollToCurrentSelection() {
    if (!_scrollController.hasClients) return;
    final index = TimezonePickerSheet.defaultTimezones.indexOf(
      widget.currentTimezone,
    );
    if (index != -1) {
      const itemHeight = 44.0;
      final target = (index * itemHeight) - 150.0;
      final clamped = target.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(clamped);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredTimezones {
    if (_searchQuery.isEmpty) {
      return TimezonePickerSheet.defaultTimezones;
    }
    final query = _searchQuery.toLowerCase();
    return TimezonePickerSheet.defaultTimezones.where((tz) {
      return tz.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF8E8E93);

    final circleShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final sheetHeight = MediaQuery.of(context).size.height * 0.88;
    final timezones = _filteredTimezones;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Header Bar matching media_1789112935240.png
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Circular Close Button (✕)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: circleBtnBg,
                      shape: BoxShape.circle,
                      boxShadow: circleShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          if (_isSearching) {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center: Title or Search Field
                  Expanded(
                    child: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search timezone...',
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _searchController.clear(),
                                      )
                                    : null,
                              ),
                            ),
                          )
                        : Text(
                            'Timezone',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),

                  // Circular Search Button (🔍)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: circleBtnBg,
                      shape: BoxShape.circle,
                      boxShadow: circleShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                            }
                          });
                        },
                        child: Center(
                          child: Icon(
                            _isSearching
                                ? Icons.search_off_rounded
                                : Icons.search_rounded,
                            color: _isSearching ? _copperColor : iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timezone List with Scrollbar
            Expanded(
              child: timezones.isEmpty
                  ? Center(
                      child: Text(
                        'No matching timezone',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: timezones.length,
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        itemBuilder: (context, index) {
                          final tz = timezones[index];
                          final isSelected = tz == widget.currentTimezone;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                widget.onTimezoneSelected?.call(tz);
                                Navigator.pop(context, tz);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Left Checkmark indicator slot matching media_1789112935240.png
                                    SizedBox(
                                      width: 24,
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 19,
                                              color: _copperColor,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    const SizedBox(width: 8),

                                    // Timezone text
                                    Expanded(
                                      child: Text(
                                        tz,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          letterSpacing: -0.1,
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
