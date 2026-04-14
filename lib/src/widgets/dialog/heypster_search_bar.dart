import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../dto/heypster_tag.dart';
import '../../heypster_flutter_sdk_base.dart';
import '../../l10n/generated/heypster_localizations.dart';
import '../../net/heypster_client.dart';

/// A debounced search bar for the heypster dialog.
///
/// Searches tags via the native API with a 200ms debounce.
/// Filters out emoji-only input.
class HeypsterSearchBar extends StatefulWidget {
  /// Called when the user selects a tag from the results.
  final void Function(HeypsterTag tag) onTagSelected;

  /// Accent color for UI elements.
  final Color? accentColor;

  /// Called when the search field gains focus.
  final VoidCallback? onFocused;

  const HeypsterSearchBar({
    super.key,
    required this.onTagSelected,
    this.accentColor,
    this.onFocused,
  });

  @override
  State<HeypsterSearchBar> createState() => _HeypsterSearchBarState();
}

class _HeypsterSearchBarState extends State<HeypsterSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<HeypsterTag> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasError = false;
  String _lastSearch = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      widget.onFocused?.call();
    }
  }

  void _onChanged(String input) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(input.trim());
    });
  }

  Future<void> _search(String input) async {
    if (input.isEmpty) {
      setState(() {
        _results = [];
        _lastSearch = '';
        _hasSearched = false;
        _hasError = false;
      });
      return;
    }

    if (_isEmojiOnly(input)) {
      setState(() {
        _results = [];
        _hasSearched = true;
      });
      return;
    }

    if (input == _lastSearch) return;
    _lastSearch = input;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final lang = HeypsterFlutterSDK.config.language.code;
      final tags = await HeypsterClient.instance.nativeApi.searchTags(
        input,
        lang,
      );
      if (mounted && input == _lastSearch) {
        setState(() {
          _results = tags;
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      developer.log(
        'Tag search failed',
        name: 'heypster_flutter_sdk.search',
        error: e,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _hasSearched = true;
        });
      }
    }
  }

  void _selectTag(HeypsterTag tag) {
    _controller.clear();
    setState(() {
      _results = [];
      _lastSearch = '';
      _hasSearched = false;
      _hasError = false;
    });
    _focusNode.unfocus();
    widget.onTagSelected(tag);
  }

  void _onSubmitted(String value) {
    if (_results.length == 1) {
      _selectTag(_results.first);
    }
  }

  bool _isEmojiOnly(String text) {
    final withoutEmoji = text.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|'
        r'[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|'
        r'[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|'
        r'[\u{FE00}-\u{FE0F}]|[\u{1F900}-\u{1F9FF}]|'
        r'[\u{200D}]|[\u{20E3}]|[\u{FE0F}]|\s',
        unicode: true,
      ),
      '',
    );
    return withoutEmoji.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = HeypsterLocalizations.of(context);
    final hintColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: false,
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n?.searchGifs ?? 'Search GIFs...',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: ImageIcon(
                const AssetImage(
                  'assets/icons/search_glyph.png',
                  package: 'heypster_flutter_sdk',
                ),
                size: 20,
                color: hintColor,
              ),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n?.clearSearch ?? 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        _debounce?.cancel();
                        _search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (_results.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = _results[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ActionChip(
                    label: Text(tag.formatted, overflow: TextOverflow.ellipsis),
                    backgroundColor:
                        (widget.accentColor ?? theme.colorScheme.primary)
                            .withAlpha(38),
                    onPressed: () => _selectTag(tag),
                  ),
                );
              },
            ),
          ),
        if (_hasSearched && _results.isEmpty && !_isLoading && !_hasError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n?.noResultsFound ?? 'No results found',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (_hasError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n?.searchFailed ?? 'Search failed. Try again.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
