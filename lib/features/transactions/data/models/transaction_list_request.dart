/// Request parameter model for filtering and retrieving transaction lists.
class TransactionListRequest {
  const TransactionListRequest({
    this.maxTime = 0,
    this.minTime = 0,
    this.type = 0,
    this.categoryIds = '',
    this.accountIds = '',
    this.tagFilter = '',
    this.amountFilter = '',
    this.keyword = '',
    this.matchMode = 0,
    this.mustHavePictures = false,
    this.count = 50,
    this.page = 1,
    this.withCount = false,
    this.withPictures = false,
    this.trimAccount = true,
    this.trimCategory = true,
    this.trimTag = true,
  });

  final int maxTime;
  final int minTime;
  final int type;
  final String categoryIds;
  final String accountIds;
  final String tagFilter;
  final String amountFilter;
  final String keyword;
  final int matchMode;
  final bool mustHavePictures;
  final int count;
  final int page;
  final bool withCount;
  final bool withPictures;
  final bool trimAccount;
  final bool trimCategory;
  final bool trimTag;

  /// Serializes the request parameters to a map for Dio query parameters.
  Map<String, dynamic> toQueryParameters() {
    return {
      'max_time': maxTime,
      'min_time': minTime,
      'type': type,
      'category_ids': categoryIds,
      'account_ids': accountIds,
      'tag_filter': tagFilter,
      'amount_filter': amountFilter,
      'keyword': keyword,
      'match_mode': matchMode,
      'must_have_pictures': mustHavePictures,
      'count': count,
      'page': page,
      'with_count': withCount,
      'with_pictures': withPictures,
      'trim_account': trimAccount,
      'trim_category': trimCategory,
      'trim_tag': trimTag,
    };
  }

  TransactionListRequest copyWith({
    int? maxTime,
    int? minTime,
    int? type,
    String? categoryIds,
    String? accountIds,
    String? tagFilter,
    String? amountFilter,
    String? keyword,
    int? matchMode,
    bool? mustHavePictures,
    int? count,
    int? page,
    bool? withCount,
    bool? withPictures,
    bool? trimAccount,
    bool? trimCategory,
    bool? trimTag,
  }) {
    return TransactionListRequest(
      maxTime: maxTime ?? this.maxTime,
      minTime: minTime ?? this.minTime,
      type: type ?? this.type,
      categoryIds: categoryIds ?? this.categoryIds,
      accountIds: accountIds ?? this.accountIds,
      tagFilter: tagFilter ?? this.tagFilter,
      amountFilter: amountFilter ?? this.amountFilter,
      keyword: keyword ?? this.keyword,
      matchMode: matchMode ?? this.matchMode,
      mustHavePictures: mustHavePictures ?? this.mustHavePictures,
      count: count ?? this.count,
      page: page ?? this.page,
      withCount: withCount ?? this.withCount,
      withPictures: withPictures ?? this.withPictures,
      trimAccount: trimAccount ?? this.trimAccount,
      trimCategory: trimCategory ?? this.trimCategory,
      trimTag: trimTag ?? this.trimTag,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionListRequest &&
        other.maxTime == maxTime &&
        other.minTime == minTime &&
        other.type == type &&
        other.categoryIds == categoryIds &&
        other.accountIds == accountIds &&
        other.tagFilter == tagFilter &&
        other.amountFilter == amountFilter &&
        other.keyword == keyword &&
        other.matchMode == matchMode &&
        other.mustHavePictures == mustHavePictures &&
        other.count == count &&
        other.page == page &&
        other.withCount == withCount &&
        other.withPictures == withPictures &&
        other.trimAccount == trimAccount &&
        other.trimCategory == trimCategory &&
        other.trimTag == trimTag;
  }

  @override
  int get hashCode => Object.hashAll([
    maxTime,
    minTime,
    type,
    categoryIds,
    accountIds,
    tagFilter,
    amountFilter,
    keyword,
    matchMode,
    mustHavePictures,
    count,
    page,
    withCount,
    withPictures,
    trimAccount,
    trimCategory,
    trimTag,
  ]);
}
