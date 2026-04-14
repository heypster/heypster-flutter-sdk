# Heypster Flutter SDK

See `../CLAUDE.md` for project-wide context: API documentation, feature mapping, naming conventions, and reference codebases.

## Package Info

- **Name:** `heypster_flutter_sdk`
- **Platform:** All Flutter platforms (iOS, Android, Web, macOS, Windows, Linux)
- **Architecture:** Pure Dart/Flutter — no platform channels, no native bridging
- **Dart SDK:** ^3.11.4
- **Lints:** `flutter_lints` (see `analysis_options.yaml`)

## Key Difference from Giphy Flutter SDK

Giphy's Flutter SDK uses `MethodChannel` to bridge to native iOS/Android SDKs. This SDK rewrites everything from scratch in pure Dart/Flutter. There are no platform interfaces, no method channels, no native plugins. All networking is done via Dart HTTP, all UI is Flutter widgets.

## Build & Development

```bash
flutter pub get          # Install dependencies
flutter test             # Run all tests
flutter analyze          # Static analysis
dart format lib/ test/   # Format code
```

### Running the Example App

```bash
cd example/

# Web (requires --disable-web-security due to missing CORS headers on API)
flutter run -d chrome --web-browser-flag "--disable-web-security"

# macOS / iOS / Android / etc.
flutter run
```

**Web CORS note:** The heypster API does not currently send
`Access-Control-Allow-Origin` headers. Web browsers block these
requests unless Chrome is launched with `--disable-web-security`.
Non-web platforms (iOS, Android, macOS, Windows, Linux) work without
any workaround. The proper long-term fix is adding CORS headers
server-side.

When MCP Dart tools are available, prefer them over shell commands:
- `mcp__dart__analyze_files` — run analyzer
- `mcp__dart__dart_format` — format code
- `mcp__dart__dart_fix` — auto-fix lint issues
- `mcp__dart__run_tests` — run tests
- `mcp__dart__pub` — manage dependencies
- `mcp__dart__pub_dev_search` — search pub.dev packages

## Dependencies

Keep dependencies minimal — this is an SDK other developers embed. Every
dependency becomes a transitive dependency for consumers. Core needs:
- `flutter` SDK
- `http` or similar lightweight networking package
- `flutter_test` (dev)
- `flutter_lints` (dev)

Do not add heavy frameworks, state management packages, or code generation
dependencies unless explicitly discussed. Consumers of this package manage
their own state, routing, and architecture.

## Proposed File Structure

```
lib/
  heypster_flutter_sdk.dart           # Public API barrel file
  heypster_dialog.dart                # Pre-built dialog/picker widget
  heypster_media_view.dart            # Single GIF display widget
  heypster_grid_view.dart             # Scrollable GIF grid widget
  dto/                                # Data transfer objects
    heypster_media.dart               # GIF metadata model
    heypster_images.dart              # Image renditions container
    heypster_image.dart               # Single rendition
    heypster_settings.dart            # Dialog/grid configuration
    heypster_theme.dart               # Visual theming
    heypster_content_request.dart     # API request descriptor
    heypster_rendition.dart           # Rendition type enum
    heypster_rating.dart              # Content rating enum
    heypster_media_type.dart          # Media type enum
    heypster_content_type.dart        # Content type enum (gif, emoji)
    heypster_emotion.dart             # Emotion enum (heypster-specific)
    misc.dart                         # Small enums (direction, resize mode)
  net/                                # Networking layer
    heypster_client.dart              # HTTP client for API calls
```

## Architecture Patterns

- **Singleton** for SDK configuration (`HeypsterFlutterSDK.configure()`)
- **Callback/listener** for dialog events (mirror Giphy's `GiphyMediaSelectionListener`)
- **Controller** for widget state (mirror Giphy's `GiphyMediaViewController`)
- **Immutable DTOs** for API responses
- **Factory constructors** for content requests (`HeypsterContentRequest.search()`, `.trending()`)

---

# AI Rules for Flutter (Package Development)

You are an expert in Flutter and Dart development. This project is a **Flutter
package** (not an app). Your goal is to build a performant, well-documented,
and maintainable SDK following modern best practices. The package must work on
all Flutter platforms (iOS, Android, Web, macOS, Windows, Linux).

## Package-Specific Guidelines

* **This is a package, not an app.** There is no `lib/main.dart` entry point.
  The public API is exported through `lib/heypster_flutter_sdk.dart`.
* **No app-level concerns.** Routing, top-level state management, app theming,
  and navigation are the consumer's responsibility — not ours.
* **Minimal dependencies.** Every dependency we add becomes a transitive
  dependency for every consumer. Prefer Dart/Flutter built-ins.
* **Public API surface matters.** Every public class, method, and enum is a
  contract. Think carefully before exposing something — it's hard to remove
  later.
* **Barrel file.** Export all public API through the single barrel file
  `lib/heypster_flutter_sdk.dart`. Consumers should only need one import.

## Interaction Guidelines
* **User Persona:** Assume the user is familiar with programming concepts but
  may be new to Dart.
* **Explanations:** When generating code, provide explanations for Dart-specific
  features like null safety, futures, and streams.
* **Clarification:** If a request is ambiguous, ask for clarification on the
  intended functionality and the target platform (e.g., command-line, web,
  server).
* **Dependencies:** When suggesting new dependencies from `pub.dev`, explain
  their benefits and weigh them against the cost of adding a transitive
  dependency to every consumer.
* **Formatting:** Use the `dart_format` tool to ensure consistent code
  formatting.
* **Fixes:** Use the `dart_fix` tool to automatically fix many common errors,
  and to help code conform to configured analysis options.
* **Linting:** Use the Dart linter with a recommended set of rules to catch
  common issues. Use the `analyze_files` tool to run the linter.

## Flutter Style Guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code.
  Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex
  widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially
  `StatelessWidget`) should be immutable.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose
  complex UIs from smaller, reusable widgets.

## Package Management
* **Pub Tool:** To manage packages, use the `pub` tool, if available.
* **External Packages:** If a new feature requires an external package, use the
  `pub_dev_search` tool, if it is available. Otherwise, identify the most
  suitable and stable package from pub.dev.
* **Adding Dependencies:** To add a regular dependency, use the `pub` tool, if
  it is available. Otherwise, run `flutter pub add <package_name>`.
* **Adding Dev Dependencies:** To add a development dependency, use the `pub`
  tool, if it is available, with `dev:<package name>`. Otherwise, run `flutter
  pub add dev:<package_name>`.
* **Dependency Overrides:** To add a dependency override, use the `pub` tool, if
  it is available, with `override:<package name>:1.0.0`. Otherwise, run `flutter
  pub add override:<package_name>:1.0.0`.
* **Removing Dependencies:** To remove a dependency, use the `pub` tool, if it
  is available. Otherwise, run `dart pub remove <package_name>`.

## Code Quality
* **Code structure:** Adhere to maintainable code structure and separation of
  concerns (e.g., UI logic separate from business logic).
* **Naming conventions:** Avoid abbreviations and use meaningful, consistent,
  descriptive names for variables, functions, and classes.
* **Conciseness:** Write code that is as short as it can be while remaining
  clear.
* **Simplicity:** Write straightforward code. Code that is clever or
  obscure is difficult to maintain.
* **Error Handling:** Anticipate and handle potential errors. Don't let your
  code fail silently.
* **Styling:**
    * Line length: Lines should be 80 characters or fewer.
    * Use `PascalCase` for classes, `camelCase` for
      members/variables/functions/enums, and `snake_case` for files.
* **Functions:**
    * Keep functions short and with a single purpose.
      Strive for less than 20 lines.
* **Testing:** Write code with testing in mind. Use the `file`, `process`, and
  `platform` packages, if appropriate, so you can inject in-memory and fake
  versions of the objects.
* **Logging:** Use the `logging` package instead of `print`.

## Dart Best Practices
* **Effective Dart:** Follow the official Effective Dart guidelines
  (https://dart.dev/effective-dart)
* **Class Organization:** Define related classes within the same library file.
  For large libraries, export smaller, private libraries from a single top-level
  library.
* **Library Organization:** Group related libraries in the same folder.
* **API Documentation:** Add documentation comments to all public APIs,
  including classes, constructors, methods, and top-level functions.
* **Comments:** Write clear comments for complex or non-obvious code. Avoid
  over-commenting.
* **Trailing Comments:** Don't add trailing comments.
* **Async/Await:** Ensure proper use of `async`/`await` for asynchronous
  operations with robust error handling.
    * Use `Future`s, `async`, and `await` for asynchronous operations.
    * Use `Stream`s for sequences of asynchronous events.
* **Null Safety:** Write code that is soundly null-safe. Leverage Dart's null
  safety features. Avoid `!` unless the value is guaranteed to be non-null.
* **Pattern Matching:** Use pattern matching features where they simplify the
  code.
* **Records:** Use records to return multiple types in situations where defining
  an entire class is cumbersome.
* **Switch Statements:** Prefer using exhaustive `switch` statements or
  expressions, which don't require `break` statements.
* **Exception Handling:** Use `try-catch` blocks for handling exceptions, and
  use exceptions appropriate for the type of exception. Use custom exceptions
  for situations specific to your code.
* **Arrow Functions:** Use arrow syntax for simple one-line functions.

## Flutter Best Practices
* **Immutability:** Widgets (especially `StatelessWidget`) are immutable; when
  the UI needs to change, Flutter rebuilds the widget tree.
* **Composition:** Prefer composing smaller widgets over extending existing
  ones. Use this to avoid deep widget nesting.
* **Private Widgets:** Use small, private `Widget` classes instead of private
  helper methods that return a `Widget`.
* **Build Methods:** Break down large `build()` methods into smaller, reusable
  private Widget classes.
* **List Performance:** Use `ListView.builder` or `SliverList` for long lists to
  create lazy-loaded lists for performance.
* **Isolates:** Use `compute()` to run expensive calculations in a separate
  isolate to avoid blocking the UI thread, such as JSON parsing.
* **Const Constructors:** Use `const` constructors for widgets and in `build()`
  methods whenever possible to reduce rebuilds.
* **Build Method Performance:** Avoid performing expensive operations, like
  network calls or complex computations, directly within `build()` methods.

## API Design Principles
This is an SDK — API design is paramount.

* **Consider the User:** Design APIs from the perspective of the developer who
  will be integrating this SDK. The API should be intuitive, hard to misuse,
  and familiar to anyone who has used Giphy's SDK.
* **Documentation is Essential:** Good documentation is a part of good API
  design. It should be clear, concise, and provide examples.
* **Consistency:** Keep naming, parameter order, and patterns consistent across
  the entire public API.
* **Discoverability:** Developers should be able to discover features through
  IDE autocomplete. Use clear, descriptive names.

## Architecture
* **Separation of Concerns:** Separate networking, data models, and UI widgets
  into distinct layers.
* **Logical Layers:**
    * Presentation (widgets: dialog, grid view, media view)
    * Data (DTOs: media, images, settings, content requests)
    * Networking (HTTP client, request/response handling)

## Lint Rules

Include the package in the `analysis_options.yaml` file:

```yaml
include: package:flutter_lints/flutter.yaml
```

### State Management (Internal)
Since this is a package, state management is internal and should be lightweight:

* **Built-in Solutions:** Use Flutter's built-in state management only.
  Do not pull in third-party state management packages.
* **Streams:** Use `Streams` and `StreamBuilder` for handling a sequence of
  asynchronous events.
* **Futures:** Use `Futures` and `FutureBuilder` for handling a single
  asynchronous operation that will complete in the future.
* **ValueNotifier:** Use `ValueNotifier` with `ValueListenableBuilder` for
  simple, local state that involves a single value.

  ```dart
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  ValueListenableBuilder<int>(
    valueListenable: _counter,
    builder: (context, value, child) {
      return Text('Count: $value');
    },
  );
  ```

* **ChangeNotifier:** For state that is more complex or shared across multiple
  widgets, use `ChangeNotifier`.
* **ListenableBuilder:** Use `ListenableBuilder` to listen to changes from a
  `ChangeNotifier` or other `Listenable`.

### Data Handling & Serialization
* **JSON Deserialization:** Write manual `fromJson` factory constructors rather
  than relying on code generation (`json_serializable`/`build_runner`). This
  avoids adding code generation dependencies to the package, keeping it simple
  for consumers.
* **Field Naming:** The heypster API uses `snake_case` keys. Convert to
  Dart's `camelCase` in `fromJson` constructors.

  ```dart
  class HeypsterMedia {
    final String id;
    final String title;
    final HeypsterImages images;

    const HeypsterMedia({
      required this.id,
      required this.title,
      required this.images,
    });

    factory HeypsterMedia.fromJson(Map<String, dynamic> json) {
      return HeypsterMedia(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        images: HeypsterImages.fromJson(
          json['images'] as Map<String, dynamic>,
        ),
      );
    }
  }
  ```

### Logging
* **Structured Logging:** Use the `log` function from `dart:developer` for
  structured logging that integrates with Dart DevTools.

  ```dart
  import 'dart:developer' as developer;

  developer.log('User logged in successfully.');

  try {
    // ... code that might fail
  } catch (e, s) {
    developer.log(
      'Failed to fetch data',
      name: 'heypster_flutter_sdk.network',
      level: 1000, // SEVERE
      error: e,
      stackTrace: s,
    );
  }
  ```

## Testing
* **Running Tests:** To run tests, use the `run_tests` tool if it is available,
  otherwise use `flutter test`.
* **Unit Tests:** Use `package:test` for unit tests.
* **Widget Tests:** Use `package:flutter_test` for widget tests.
* **Assertions:** Prefer using `package:checks` for more expressive and readable
  assertions over the default `matchers`.

### Testing Best Practices
* **Convention:** Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
* **Unit Tests:** Write unit tests for DTOs (serialization), networking layer
  (mock HTTP), and business logic.
* **Widget Tests:** Write widget tests for all public widgets (HeypsterDialog,
  HeypsterMediaView, HeypsterGridView).
* **Mocks:** Prefer fakes or stubs over mocks. If mocks are absolutely
  necessary, use `mockito` or `mocktail` to create mocks for dependencies.
* **Coverage:** Aim for high test coverage, especially on the public API.

## Widget Theming
The SDK provides its own theming system (`HeypsterTheme` / `HeypsterSettings`)
that consumers configure. Internally, widgets should:

* **Respect the provided theme.** Use `HeypsterTheme` properties for colors,
  sizes, and styling rather than hardcoded values.
* **Fall back to sensible defaults.** If no theme is provided, widgets should
  look good out of the box.
* **Support light and dark modes.** Use `MediaQuery.platformBrightnessOf` or
  `Theme.of(context).brightness` to adapt when the consumer hasn't provided
  explicit theme overrides.
* **Use `const` constructors** for all theme/settings classes.
* **Provide `copyWith()`** on theme and settings classes for easy customization.

### Assets and Images
* **Network Images:** GIFs are loaded from the network. Always include
  `loadingBuilder` and `errorBuilder` for a better user experience.

  ```dart
  Image.network(
    gifUrl,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return const Center(child: CircularProgressIndicator());
    },
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.error);
    },
  )
  ```

## Layout Best Practices

### Building Flexible and Overflow-Safe Layouts

#### For Rows and Columns

* **`Expanded`:** Use to make a child widget fill the remaining available space
  along the main axis.
* **`Flexible`:** Use when you want a widget to shrink to fit, but not
  necessarily grow. Don't combine `Flexible` and `Expanded` in the same `Row` or
  `Column`.
* **`Wrap`:** Use when you have a series of widgets that would overflow a `Row`
  or `Column`, and you want them to move to the next line.

#### For General Content

* **`SingleChildScrollView`:** Use when your content is intrinsically larger
  than the viewport, but is a fixed size.
* **`ListView` / `GridView`:** For long lists or grids of content, always use a
  builder constructor (`.builder`).
* **`FittedBox`:** Use to scale or fit a single child widget within its parent.
* **`LayoutBuilder`:** Use for complex, responsive layouts to make decisions
  based on the available space.

### Layering Widgets with Stack

* **`Positioned`:** Use to precisely place a child within a `Stack` by
  anchoring it to the edges.
* **`Align`:** Use to position a child within a `Stack` using alignments like
  `Alignment.center`.

## Color & Contrast
* **WCAG Guidelines:** Aim to meet WCAG 2.1 standards.
* **Minimum Contrast:**
    * **Normal Text:** A contrast ratio of at least **4.5:1**.
    * **Large Text:** (18pt or 14pt bold) A contrast ratio of at least **3:1**.

## Documentation

* **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation Philosophy

* **Comment wisely:** Use comments to explain why the code is written a certain
  way, not what the code does. The code itself should be self-explanatory.
* **Document for the user:** Write documentation with the SDK consumer in mind.
  If you had a question and found the answer, add it to the documentation where
  you first looked.
* **No useless documentation:** If the documentation only restates the obvious
  from the code's name, it's not helpful. Good documentation provides context
  and explains what isn't immediately apparent.
* **Consistency is key:** Use consistent terminology throughout your
  documentation.

### Commenting Style

* **Use `///` for doc comments:** This allows documentation generation tools to
  pick them up.
* **Start with a single-sentence summary:** The first sentence should be a
  concise, user-centric summary ending with a period.
* **Separate the summary:** Add a blank line after the first sentence to create
  a separate paragraph.
* **Avoid redundancy:** Don't repeat information that's obvious from the code's
  context, like the class name or signature.
* **Include code samples:** Where appropriate, add code samples to illustrate
  usage — SDK consumers especially benefit from examples.

### What to Document

* **Public APIs are mandatory:** Always document public APIs. This is an SDK —
  our public API documentation *is* the product.
* **Consider private APIs:** Document private APIs that have non-obvious
  behavior.
* **Library-level comments are helpful:** Add a doc comment at the library level
  to provide a general overview.
* **Explain parameters, return values, and exceptions:** Use prose to describe
  what a function expects, what it returns, and what errors it might throw.
* **Place doc comments before annotations:** Documentation should come before
  any metadata annotations.

## Accessibility (A11Y)
* **Color Contrast:** Ensure text has a contrast ratio of at least **4.5:1**
  against its background.
* **Dynamic Text Scaling:** Test widgets to ensure they remain usable when users
  increase the system font size.
* **Semantic Labels:** Use the `Semantics` widget to provide clear, descriptive
  labels for UI elements, especially on GIF images and interactive controls.
* **Screen Reader Testing:** Regularly test with TalkBack (Android) and
  VoiceOver (iOS).
