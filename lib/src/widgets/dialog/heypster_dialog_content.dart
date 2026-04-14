import 'package:flutter/material.dart';

import '../../dto/heypster_content_request.dart';
import '../../dto/heypster_emotion.dart';
import '../../dto/heypster_media.dart';
import '../../dto/heypster_settings.dart';
import '../../dto/heypster_tag.dart';
import '../../l10n/generated/heypster_localizations.dart';
import '../heypster_grid_view.dart';
import 'heypster_emotion_grid.dart';
import 'heypster_search_bar.dart';

/// The root content widget inside the heypster picker bottom sheet.
///
/// Implements the full navigation flow: GIFs of the day -> search ->
/// tag results -> emotion grid -> emotion results.
class HeypsterDialogContent extends StatefulWidget {
  /// Settings for the dialog.
  final HeypsterSettings settings;

  /// Called when a GIF is selected.
  final void Function(HeypsterMedia media) onMediaSelect;

  /// Called when the dialog should be dismissed.
  final VoidCallback onDismiss;

  /// Optional scroll controller from [DraggableScrollableSheet].
  final ScrollController? scrollController;

  /// Controller for the [DraggableScrollableSheet] to expand/collapse.
  final DraggableScrollableController? sheetController;

  /// Whether a handle bar (drag indicator) should be displayed on top of the dialog.
  final bool showHandleBar;

  const HeypsterDialogContent({
    super.key,
    required this.settings,
    required this.onMediaSelect,
    required this.onDismiss,
    this.scrollController,
    this.sheetController,
    this.showHandleBar = true,
  });

  @override
  State<HeypsterDialogContent> createState() => _HeypsterDialogContentState();
}

enum _DialogPage { home, emotions, tagResults, emotionResults }

class _HeypsterDialogContentState extends State<HeypsterDialogContent> {
  _DialogPage _currentPage = _DialogPage.home;
  HeypsterTag? _selectedTag;
  HeypsterEmotion? _selectedEmotion;

  void _expandSheet() {
    final controller = widget.sheetController;
    if (controller != null && controller.isAttached) {
      controller.animateTo(
        widget.settings.maxSheetSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTagSelected(HeypsterTag tag) {
    setState(() {
      _selectedTag = tag;
      _currentPage = _DialogPage.tagResults;
    });
  }

  void _onEmotionSelected(HeypsterEmotion emotion) {
    setState(() {
      _selectedEmotion = emotion;
      _currentPage = _DialogPage.emotionResults;
    });
  }

  void _goBack() {
    setState(() {
      _currentPage = _DialogPage.home;
      _selectedTag = null;
      _selectedEmotion = null;
    });
  }

  String _title(HeypsterLocalizations l10n) {
    return switch (_currentPage) {
      _DialogPage.home => 'heypster',
      _DialogPage.emotions => l10n.emotions,
      _DialogPage.tagResults => _selectedTag?.formatted ?? l10n.results,
      _DialogPage.emotionResults => _selectedEmotion?.name ?? l10n.results,
    };
  }

  HeypsterContentRequest get _contentRequest {
    return switch (_currentPage) {
      _DialogPage.home => HeypsterContentRequest.gifsOfTheDay(),
      _DialogPage.tagResults => HeypsterContentRequest.byTag(_selectedTag!),
      _DialogPage.emotionResults => HeypsterContentRequest.byEmotion(
        _selectedEmotion!,
      ),
      _DialogPage.emotions => HeypsterContentRequest.gifsOfTheDay(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.settings.theme;
    final accentColor = theme.accentColor;
    final l10n = HeypsterLocalizations.of(context);

    return FocusTraversalGroup(
      child: Column(
        children: [
          // Handle bar (decorative)
          if (widget.showHandleBar)
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        theme.handleBarColor ??
                        Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                if (_currentPage != _DialogPage.home)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: l10n?.goBack,
                    onPressed: _goBack,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n != null ? _title(l10n) : 'heypster',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_currentPage == _DialogPage.home &&
                    widget.settings.showEmotions)
                  IconButton(
                    icon: const ImageIcon(
                      AssetImage(
                        'assets/icons/emotion_glyph.png',
                        package: 'heypster_flutter_sdk',
                      ),
                      size: 24,
                    ),
                    tooltip: l10n?.browseByEmotion,
                    onPressed: () =>
                        setState(() => _currentPage = _DialogPage.emotions),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n?.close,
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // Search bar (home page only)
          if (_currentPage == _DialogPage.home)
            HeypsterSearchBar(
              onTagSelected: _onTagSelected,
              accentColor: accentColor,
              onFocused: _expandSheet,
            ),

          // Content with animated transitions
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _currentPage == _DialogPage.emotions
                  ? HeypsterEmotionGrid(
                      key: const ValueKey('emotions'),
                      onEmotionSelected: _onEmotionSelected,
                      accentColor: accentColor,
                    )
                  : HeypsterGridView(
                      key: ValueKey(
                        _contentRequest.requestType.name +
                            (_selectedTag?.id.toString() ?? '') +
                            (_selectedEmotion?.id.toString() ?? ''),
                      ),
                      content: _contentRequest,
                      theme: theme,
                      scrollController: widget.scrollController,
                      onMediaSelect: widget.onMediaSelect,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
