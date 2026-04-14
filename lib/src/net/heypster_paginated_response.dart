/// A paginated API response containing data and pagination info.
class HeypsterPaginatedResponse<T> {
  /// The items in this page.
  final List<T> data;

  /// Total number of items across all pages.
  final int totalCount;

  /// Number of items in this page.
  final int count;

  /// Offset of this page (GIPHY-compatible API).
  final int offset;

  const HeypsterPaginatedResponse({
    required this.data,
    required this.totalCount,
    required this.count,
    required this.offset,
  });
}

/// Pagination info from the native heypster API.
class HeypsterNativePagination {
  /// Number of items in this page.
  final int count;

  /// Items per page.
  final int perPage;

  /// Current page number (1-indexed).
  final int currentPage;

  /// URL for the next page, or null if this is the last page.
  final String? nextPageUrl;

  const HeypsterNativePagination({
    required this.count,
    required this.perPage,
    required this.currentPage,
    this.nextPageUrl,
  });

  /// Whether there are more pages available.
  bool get hasNextPage => nextPageUrl != null;

  /// Parses pagination from the native API response JSON.
  factory HeypsterNativePagination.fromJson(Map<String, dynamic> json) {
    return HeypsterNativePagination(
      count: json['count'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 20,
      currentPage: json['current_page'] as int? ?? 1,
      nextPageUrl: json['next_page_url'] as String?,
    );
  }
}

/// A paginated response from the native heypster API.
class HeypsterNativePaginatedResponse<T> {
  /// The items in this page.
  final List<T> data;

  /// Pagination info.
  final HeypsterNativePagination pagination;

  const HeypsterNativePaginatedResponse({
    required this.data,
    required this.pagination,
  });

  /// Whether there are more pages available.
  bool get hasNextPage => pagination.hasNextPage;
}
