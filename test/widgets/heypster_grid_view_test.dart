import 'package:flutter_test/flutter_test.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';

void main() {
  group('HeypsterGridView', () {
    test('constructor accepts all parameters', () {
      final widget = HeypsterGridView(
        content: HeypsterContentRequest.trendingGifs(),
        cellPadding: 4,
        renditionType: HeypsterRendition.original,
        theme: HeypsterTheme.dark(),
        spanCount: 3,
        orientation: HeypsterDirection.horizontal,
        onMediaSelect: (_) {},
        onContentUpdate: (_) {},
        onScroll: (_) {},
      );

      expect(widget.cellPadding, 4);
      expect(widget.renditionType, HeypsterRendition.original);
      expect(widget.spanCount, 3);
      expect(widget.orientation, HeypsterDirection.horizontal);
    });

    test('defaults match Giphy pattern', () {
      final widget = HeypsterGridView(
        content: HeypsterContentRequest.trendingGifs(),
      );

      expect(widget.cellPadding, 8);
      expect(widget.renditionType, HeypsterRendition.fixedWidth);
      expect(widget.spanCount, isNull);
      expect(widget.orientation, HeypsterDirection.vertical);
      expect(widget.onMediaSelect, isNull);
      expect(widget.onContentUpdate, isNull);
      expect(widget.onScroll, isNull);
    });

    test('supports all content request types', () {
      // GIPHY-compatible content types
      HeypsterGridView(
        content: HeypsterContentRequest.search(searchQuery: 'test'),
      );
      HeypsterGridView(content: HeypsterContentRequest.trendingGifs());
      HeypsterGridView(content: HeypsterContentRequest.emoji());

      // Native API content types
      HeypsterGridView(
        content: HeypsterContentRequest.byEmotion(HeypsterEmotion.happy),
      );
      HeypsterGridView(
        content: HeypsterContentRequest.byTag(
          const HeypsterTag(id: 1, tag: 'test'),
        ),
      );
      HeypsterGridView(
        content: HeypsterContentRequest.byBadge(
          const HeypsterBadge(id: 1, title: 'test', imagePath: ''),
        ),
      );
    });
  });
}
