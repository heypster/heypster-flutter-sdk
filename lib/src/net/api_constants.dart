/// Base URLs and defaults for the heypster API.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the GIPHY-compatible REST API.
  static const giphyBaseUrl = 'https://heypster-gif.com/giphy';

  /// Base URL for the native heypster SDK API.
  static const nativeBaseUrl = 'https://heypster-gif.com/sdk';

  /// Base URL for heypster content (GIFs, videos).
  static const contentBaseUrl = 'https://heypster-gif.com/';

  /// Default number of results per page (GIPHY-compatible API).
  static const defaultLimit = 25;

  /// Default number of results per page (native API).
  static const nativePerPage = 20;
}
