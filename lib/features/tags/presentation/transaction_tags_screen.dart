import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/add_transaction_tag_use_case.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/get_transaction_tags_use_case.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:ezbookkeeping/l10n/generated/app_localizations.dart';

class TransactionTagsScreen extends StatefulWidget {
  final TagsBloc? bloc;
  final AddTransactionTagUseCase? addTransactionTagUseCase;
  final GetTransactionTagsUseCase? getTransactionTagsUseCase;
  final TagsRepository? tagsRepository;

  const TransactionTagsScreen({
    super.key,
    this.bloc,
    this.addTransactionTagUseCase,
    this.getTransactionTagsUseCase,
    this.tagsRepository,
  });

  @override
  State<TransactionTagsScreen> createState() => _TransactionTagsScreenState();
}

class _TransactionTagsScreenState extends State<TransactionTagsScreen> {
  late List<TagItem> _tags;

  bool _isAddingTag = false;
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool _showHiddenTags = false;
  final TextEditingController _newTagController = TextEditingController();
  final FocusNode _newTagFocusNode = FocusNode();

  static const Color _copperAccent = Color(0xFFC86D3B);

  @override
  void initState() {
    super.initState();
    _tags = const [];
    _loadTags();
  }

  void _loadTags() {
    final repo =
        widget.tagsRepository ??
        (getIt.isRegistered<TagsRepository>() ? getIt<TagsRepository>() : null);
    if (repo != null) {
      setState(() => _isLoading = true);
      repo
          .getTags()
          .then((loadedTags) {
            if (!mounted) return;
            setState(() {
              _tags = List.from(loadedTags);
              _isLoading = false;
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          });
    }
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _newTagFocusNode.dispose();
    super.dispose();
  }

  List<TagItem> get _visibleTags {
    return _tags.where((tag) {
      if (!_showHiddenTags && tag.isHidden) return false;
      return true;
    }).toList();
  }

  Future<void> _saveNewTag() async {
    if (_isSubmitting) return;

    final name = _newTagController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag title cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    const groupId = '0';
    final request = AddTransactionTagRequestModel(name: name, groupId: groupId);

    final useCase =
        widget.addTransactionTagUseCase ??
        (getIt.isRegistered<AddTransactionTagUseCase>()
            ? getIt<AddTransactionTagUseCase>()
            : null);

    if (useCase != null) {
      final result = await useCase(request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: const Color(0xFFE75A4C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (newTag) {
          setState(() {
            _tags.add(newTag);
            _newTagController.clear();
            _isAddingTag = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tag "$name" added'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } else {
      setState(() => _isSubmitting = false);
      final fallbackTag = TagItem(
        id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        groupId: groupId,
      );

      setState(() {
        _tags.add(fallbackTag);
        _newTagController.clear();
        _isAddingTag = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "$name" added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelNewTag() {
    setState(() {
      _newTagController.clear();
      _isAddingTag = false;
    });
  }

  void _sortTags(bool ascending) {
    setState(() {
      _tags.sort((a, b) {
        final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return ascending ? cmp : -cmp;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ascending ? 'Sorted by Name (A to Z)' : 'Sorted by Name (Z to A)',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.95);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Block 1: Sort & Filter Options
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            // Sort Header
                            const Text(
                              'Sort',
                              style: TextStyle(
                                color: _copperAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sort by Name (A to Z)
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _sortTags(true);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sort by Name (A to Z)',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sort by Name (Z to A)
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _sortTags(false);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sort by Name (Z to A)',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Show Hidden Transaction Tags
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _showHiddenTags = !_showHiddenTags;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _showHiddenTags
                                          ? 'Showing hidden tags'
                                          : 'Hiding hidden tags',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _showHiddenTags
                                      ? 'Hide Hidden Transaction Tags'
                                      : 'Show Hidden Transaction Tags',
                                  style: const TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Block 2: Cancel
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => Navigator.pop(ctx),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _copperAccent,
                                  fontSize: 16,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9E9EA7);

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

    final visibleTags = _visibleTags;

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

                      // Center Title: "Transaction Tags"
                      Expanded(
                        child: Text(
                          'Transaction Tags',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Right Pill Button with '...' and '+'
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(21),
                                ),
                                onTap: _showMoreOptions,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(21),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isAddingTag = true;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _newTagFocusNode.requestFocus();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: textColor,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Card
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (visibleTags.isEmpty && !_isAddingTag)
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)?.noTransactionTagsAvailable ??
                        'No transaction tags available',
                    style: TextStyle(
                      color: hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: cardShadow,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Render visible tags
                            for (int i = 0; i < visibleTags.length; i++) ...[
                              Row(
                                children: [
                                  Text(
                                    '#',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      visibleTags[i].name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (i < visibleTags.length - 1 || _isAddingTag)
                                const SizedBox(height: 20),
                            ],

                            // Inline Add Tag Row
                            if (_isAddingTag)
                              Row(
                                children: [
                                  Text(
                                    '#',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextField(
                                      controller: _newTagController,
                                      focusNode: _newTagFocusNode,
                                      enabled: !_isSubmitting,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Tag Title',
                                        hintStyle: TextStyle(
                                          color: hintColor,
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onSubmitted: (_) => _saveNewTag(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Blue Save Checkmark Button
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5AADEA),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap:
                                            _isSubmitting ? null : _saveNewTag,
                                        child: Center(
                                          child: _isSubmitting
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Slate Cancel Close Button
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E8E93),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap:
                                            _isSubmitting
                                                ? null
                                                : _cancelNewTag,
                                        child: const Center(
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
}
