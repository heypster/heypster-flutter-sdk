import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../l10n/generated/heypster_localizations.dart';
import '../dto/heypster_content_request.dart';
import '../dto/heypster_media.dart';
import '../dto/heypster_rendition.dart';
import '../dto/heypster_theme.dart';
import '../dto/misc.dart';
import '../net/heypster_client.dart';
import 'dialog/heypster_gif_cell.dart';

/// A scrollable, paginated grid of heypster GIFs.
///
/// Driven by a [HeypsterContentRequest] that determines what
/// content to load (search, trending, by emotion, etc.).
///
/// ```dart
/// HeypsterGridView(
///   content: HeypsterContentRequest.trendingGifs(),
///   onMediaSelect: (media) => print('Selected: ${media.id}'),
/// )
/// ```
class HeypsterGridView extends StatefulWidget {
  /// What content to load.
  final HeypsterContentRequest content;

  /// Spacing between cells in logical pixels.
  final double cellPadding;

  /// Which rendition to use for each cell.
  final HeypsterRendition renditionType;

  /// Visual theme.
  final HeypsterTheme theme;

  /// Number of columns. If null, adapts based on available width.
  final int? spanCount;

  /// Scroll direction.
  final HeypsterDirection orientation;

  /// Called when a GIF is tapped.
  final void Function(HeypsterMedia media)? onMediaSelect;

  /// Called after each fetch with the total result count.
  final void Function(int resultCount)? onContentUpdate;

  /// Called on scroll with the current offset.
  final void Function(double offset)? onScroll;

  /// Optional external scroll controller.
  ///
  /// When provided (e.g., from a [DraggableScrollableSheet]),
  /// the grid uses this instead of its own internal controller.
  final ScrollController? scrollController;

  /// Creates a [HeypsterGridView].
  const HeypsterGridView({
    super.key,
    required this.content,
    this.cellPadding = 8,
    this.renditionType = HeypsterRendition.fixedWidth,
    this.theme = HeypsterTheme.automaticTheme,
    this.spanCount,
    this.orientation = HeypsterDirection.vertical,
    this.onMediaSelect,
    this.onContentUpdate,
    this.onScroll,
    this.scrollController,
  });

  @override
  State<HeypsterGridView> createState() => _HeypsterGridViewState();
}

class _HeypsterGridViewState extends State<HeypsterGridView> {
  final _items = <HeypsterMedia>[];
  ScrollController? _ownScrollController;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;

  // GIPHY-compatible API pagination
  int _offset = 0;

  // Native API pagination
  int _page = 1;

  ScrollController get _scrollController {
    if (widget.scrollController != null) return widget.scrollController!;
    return _ownScrollController ??= ScrollController();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNextPage();
  }

  @override
  void didUpdateWidget(HeypsterGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      (oldWidget.scrollController ?? _ownScrollController)?.removeListener(
        _onScroll,
      );
      _scrollController.addListener(_onScroll);
    }

    if (_contentChanged(oldWidget.content, widget.content)) {
      _reset();
      _fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _ownScrollController?.dispose();
    super.dispose();
  }

  bool _contentChanged(HeypsterContentRequest a, HeypsterContentRequest b) {
    return a.requestType != b.requestType ||
        a.searchQuery != b.searchQuery ||
        a.mediaType != b.mediaType ||
        a.rating != b.rating ||
        a.tag?.id != b.tag?.id ||
        a.emotion != b.emotion ||
        a.badge?.id != b.badge?.id;
  }

  void _reset() {
    _items.clear();
    _offset = 0;
    _page = 1;
    _hasMore = true;
  }

  void _fetchMoreIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _isLoading) return;
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      if (pos.maxScrollExtent <= 0) {
        _fetchNextPage();
      }
    });
  }

  void _onScroll() {
    widget.onScroll?.call(_scrollController.offset);

    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  bool get _usesNativeApi {
    switch (widget.content.requestType) {
      case HeypsterContentRequestType.byTag:
      case HeypsterContentRequestType.byEmotion:
      case HeypsterContentRequestType.byBadge:
      case HeypsterContentRequestType.gifsOfTheDay:
        return true;
      case HeypsterContentRequestType.trending:
      case HeypsterContentRequestType.search:
      case HeypsterContentRequestType.emoji:
        return false;
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (_usesNativeApi) {
        await _fetchNative();
      } else {
        await _fetchGiphy();
      }
    } catch (e) {
      developer.log(
        'Failed to fetch content',
        name: 'heypster_flutter_sdk.grid',
        error: e,
      );
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGiphy() async {
    final client = HeypsterClient.instance;
    final content = widget.content;

    final result = switch (content.requestType) {
      HeypsterContentRequestType.search => await client.giphyApi.searchGifs(
        content.searchQuery ?? '',
        offset: _offset,
        rating: content.rating,
      ),
      HeypsterContentRequestType.trending => await client.giphyApi.trending(
        offset: _offset,
        rating: content.rating,
      ),
      HeypsterContentRequestType.emoji => await client.giphyApi.emoji(
        offset: _offset,
      ),
      _ => throw StateError('Unexpected request type for GIPHY API'),
    };

    if (mounted) {
      setState(() {
        _items.addAll(result.data);
        _offset += result.count;
        _hasMore = _offset < result.totalCount;
      });
      widget.onContentUpdate?.call(_items.length);
      _fetchMoreIfNeeded();
    }
  }

  Future<void> _fetchNative() async {
    final client = HeypsterClient.instance;
    final content = widget.content;

    final result = switch (content.requestType) {
      HeypsterContentRequestType.gifsOfTheDay =>
        await client.nativeApi.fetchGifsOfTheDay(page: _page),
      HeypsterContentRequestType.byTag => await client.nativeApi.fetchGifsByTag(
        content.tag!.id,
        page: _page,
      ),
      HeypsterContentRequestType.byEmotion =>
        await client.nativeApi.fetchGifsByEmotion(
          content.emotion!.id,
          page: _page,
        ),
      HeypsterContentRequestType.byBadge =>
        await client.nativeApi.fetchGifsByBadge(content.badge!.id, page: _page),
      _ => throw StateError('Unexpected request type for native API'),
    };

    final mediaItems = result.data.map((g) => g.toHeypsterMedia()).toList();

    if (mounted) {
      setState(() {
        _items.addAll(mediaItems);
        _page++;
        _hasMore = result.hasNextPage;
      });
      widget.onContentUpdate?.call(_items.length);
      _fetchMoreIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = HeypsterLocalizations.of(context);
    if (_items.isEmpty && _hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n?.failedToLoadGifs ?? 'Failed to load GIFs'),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _fetchNextPage,
              child: Text(l10n?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_items.isEmpty && !_hasMore && !_hasError) {
      return Center(child: Text(l10n?.noGifsFound ?? 'No GIFs found'));
    }

    final axis = widget.orientation == HeypsterDirection.horizontal
        ? Axis.horizontal
        : Axis.vertical;

    final columns = widget.spanCount ?? _defaultSpanCount(context);

    return GridView.builder(
      controller: _scrollController,
      scrollDirection: axis,
      addAutomaticKeepAlives: false,
      padding: EdgeInsets.all(widget.cellPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: widget.cellPadding,
        mainAxisSpacing: widget.cellPadding,
        childAspectRatio: 1.75,
      ),
      itemCount: _items.length + (_hasMore && !_hasError ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        final media = _items[index];
        return HeypsterGifCell(
          media: media,
          cornerRadius: widget.theme.cellCornerRadius ?? 10,
          renditionType: widget.renditionType,
          onTap: () => widget.onMediaSelect?.call(media),
        );
      },
    );
  }

  int _defaultSpanCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 500) return 2;
    return 1;
  }
}
