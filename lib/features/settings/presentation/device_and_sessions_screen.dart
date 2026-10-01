import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/tokens/domain/entities/token.dart';
import 'package:ezbookkeeping/features/tokens/domain/repositories/tokens_repository.dart';
import 'package:ezbookkeeping/features/tokens/domain/usecases/get_tokens_use_case.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_bloc.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_event.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_state.dart';
import 'package:ezbookkeeping/features/tokens/utils/user_agent_parser.dart';

class DeviceAndSessionsScreen extends StatefulWidget {
  final TokensBloc? bloc;
  final GetTokensUseCase? getTokensUseCase;
  final TokensRepository? repository;

  const DeviceAndSessionsScreen({
    super.key,
    this.bloc,
    this.getTokensUseCase,
    this.repository,
  });

  @override
  State<DeviceAndSessionsScreen> createState() =>
      _DeviceAndSessionsScreenState();
}

class _DeviceAndSessionsScreenState extends State<DeviceAndSessionsScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);
  static const Color _dangerRed = Color(0xFFEF4444);

  late final TokensBloc? _bloc;
  StreamSubscription<TokensState>? _blocSubscription;
  late final GetTokensUseCase? _useCase;
  late final TokensRepository? _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<Token> _tokens = [];

  @override
  void initState() {
    super.initState();

    _bloc = widget.bloc ??
        (getIt.isRegistered<TokensBloc>() ? getIt<TokensBloc>() : null);

    _useCase = widget.getTokensUseCase ??
        (getIt.isRegistered<GetTokensUseCase>()
            ? getIt<GetTokensUseCase>()
            : null);

    _repository = widget.repository ??
        (getIt.isRegistered<TokensRepository>()
            ? getIt<TokensRepository>()
            : null);

    final bloc = _bloc;
    if (bloc != null) {
      _blocSubscription = bloc.stream.listen((state) {
        if (!mounted) return;
        if (state is TokensLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is TokensLoaded) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _tokens = state.tokens;
          });
        } else if (state is TokensError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      });
      bloc.add(const LoadTokens());
    } else {
      _loadDirect(forceRefresh: false);
    }
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDirect({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = _useCase;
    if (useCase != null) {
      final result = await useCase(forceRefresh: forceRefresh);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (tokens) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _tokens = tokens;
          });
        },
      );
      return;
    }

    final repo = _repository;
    if (repo != null) {
      final result = await repo.getTokens(forceRefresh: forceRefresh);
      if (!mounted) return;
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (tokens) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
            _tokens = tokens;
          });
        },
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(const LoadTokens(forceRefresh: true));
    } else {
      await _loadDirect(forceRefresh: true);
    }
  }

  String _formatLastSeen(int timestampSeconds) {
    if (timestampSeconds <= 0) return 'Never';
    final date = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = months[date.month - 1];
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = date.minute.toString().padLeft(2, '0');
    final secondStr = date.second.toString().padLeft(2, '0');
    return '$monthName ${date.day}, ${date.year} $hour:$minuteStr:$secondStr $ampm';
  }

  void _confirmLogoutAll() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Logout All'),
          content: const Text(
            'Are you sure you want to log out of all other active sessions?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _tokens = _tokens.where((s) => s.isCurrent).toList();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out of all other devices'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Logout All'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogoutSession(Token token) {
    if (token.isCurrent) return;

    final clientDisplayName = UserAgentParser.parseClientName(token.userAgent);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Logout Device'),
          content: Text(
            'Are you sure you want to log out of this session ($clientDisplayName)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _tokens = _tokens.where((s) => s.tokenId != token.tokenId).toList();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session logged out'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F0F11) : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back Button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final router = GoRouter.maybeOf(context);
                              if (router != null && router.canPop()) {
                                router.pop();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Title "Device & Sessions"
                      Expanded(
                        child: Text(
                          'Device & Sessions',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Logout All Button
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(21),
                            onTap: _tokens.where((s) => !s.isCurrent).isNotEmpty
                                ? _confirmLogoutAll
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text(
                                'Logout All',
                                style: TextStyle(
                                  color: _tokens
                                          .where((s) => !s.isCurrent)
                                          .isNotEmpty
                                      ? textColor
                                      : subtextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content: Sessions List
            Expanded(
              child: RefreshIndicator(
                color: _copperAccent,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          // Error State Banner
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _dangerRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _dangerRed.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: _dangerRed,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: _dangerRed,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _onRefresh,
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: _copperAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Sessions Card
                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _isLoading && _tokens.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 48,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: _copperAccent,
                                      ),
                                    ),
                                  )
                                : _tokens.isEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(24),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'No active sessions found',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          for (int i = 0;
                                              i < _tokens.length;
                                              i++) ...[
                                            _buildTokenTile(
                                              token: _tokens[i],
                                              textColor: textColor,
                                              subtextColor: subtextColor,
                                            ),
                                            if (i < _tokens.length - 1)
                                              Divider(
                                                height: 1,
                                                thickness: 0.6,
                                                indent: 56,
                                                endIndent: 16,
                                                color: dividerColor,
                                              ),
                                          ],
                                        ],
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenTile({
    required Token token,
    required Color textColor,
    required Color subtextColor,
  }) {
    final title = token.isCurrent ? 'Current' : 'Other Device';
    final userAgentParsed =
        UserAgentParser.parseClientName(token.userAgent);
    final icon = UserAgentParser.getDeviceIcon(token.userAgent);
    final lastActiveFormatted = _formatLastSeen(token.lastSeen);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: token.isCurrent ? null : () => _confirmLogoutSession(token),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Device Icon
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 14),

              // Device & Session Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: token.isCurrent
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lastActiveFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userAgentParsed,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
