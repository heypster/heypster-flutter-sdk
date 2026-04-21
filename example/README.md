# heypster_example

Example app demonstrating the [heypster Flutter SDK](../README.md).

## Running the example

1. Copy `.env.example` to `.env` and fill in your heypster API key:

   ```
   HEYPSTER_API_KEY=your-key-here
   ```

2. Install dependencies:

   ```sh
   flutter pub get
   ```

3. Run the app:

   ```sh
   # macOS / iOS / Android / Windows / Linux
   flutter run

   # Web (requires disabling CORS — see the project CLAUDE.md)
   flutter run -d chrome --web-browser-flag "--disable-web-security"
   ```

The `.env` file is git-ignored; `.env.example` is committed as a template.
