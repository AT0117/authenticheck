# AuthentiCheck Project Overview

AuthentiCheck is a Flutter-based mobile application designed to help users assess whether an e-commerce product listing looks genuine or potentially counterfeit. The app accepts a product URL, fetches the page content, and analyzes it using a combination of web scraping and LLM-based reasoning to generate an authenticity score, verdict, and risk signals.

## Project Purpose

The core idea behind the project is simple: shoppers often rely on public product pages that may contain misleading pricing, suspicious seller patterns, inflated reviews, or copied product descriptions. AuthentiCheck gives users a quick confidence check before they purchase an item.

The app focuses on:

- analyzing product URLs from marketplaces such as Amazon and Flipkart
- extracting visible product information from the page
- checking for indicators like price anomalies and suspicious content
- returning an easy-to-read score and verdict
- supporting share-based URL intake from outside the app

## Main Features

- Product URL input and quick analysis
- Share integration from other apps or browsers
- Real-time loading states and terminal-style dashboard design
- Web scraping via ScraperAPI
- AI-powered assessment via Groq-based LLM
- Output with:
  - authenticity score (0-100)
  - verdict summary
  - price anomaly flag
  - list of risk factors

## How the App Works

The user flow is straightforward:

1. The user pastes a product URL or shares a link from another app.
2. The app captures the URL in the home screen.
3. The scraper fetches the product page content.
4. HTML is cleaned and reduced to visible text.
5. The cleaned data is sent to an LLM prompt.
6. The model returns structured JSON containing the score, verdict, and risk factors.
7. The UI renders the final results in a bold, terminal-inspired layout.

## Technology Stack

- Flutter
- Dart
- Material Design UI
- HTTP requests for scraping and AI access
- `flutter_dotenv` for environment variables
- `http` package for API calls
- `html` parser for sanitizing scraped page content
- Groq/OpenAI-compatible chat completion API

## Project Structure

The application is organized as follows:

- `lib/main.dart`  
  App entry point and app initialization.

- `lib/screens/home_screen.dart`  
  Main UI screen that handles input, loading states, result display, and share intent handling.

- `lib/services/scraper_service.dart`  
  Fetches product page data from ScraperAPI and strips non-visible HTML content before sending it to the LLM.

- `lib/services/llm_service.dart`  
  Sends the cleaned product content to the Groq API and parses the JSON response.

- `lib/models/authenticity_result.dart`  
  Model class representing the authenticity analysis response.

- `lib/theme/brutalist_theme.dart`  
  Custom visual styling for the app’s harsh, industrial dashboard look.

- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`  
  Platform-specific Flutter project files created for multi-platform support.

## Key Data Flow

```text
Product URL
   ↓
HomeScreen
   ↓
ScraperService
   ↓
HTML sanitization
   ↓
LLM analysis
   ↓
AuthenticityResult JSON
   ↓
Dashboard UI
```

## Environment Setup

This app expects a `.env` file in the project root with API keys configured. A typical `.env` file should include values similar to:

```env
SCRAPER_API_KEY=your_scraper_api_key
GROQ_API_KEY=your_groq_api_key
```

These keys are loaded at app startup via `flutter_dotenv`.

## Setup Instructions

1. Install Flutter dependencies:

```bash
flutter pub get
```

2. Create a `.env` file in the project root and add the required keys.

3. Run the app:

```bash
flutter run
```

## Notes and Limitations

- The app depends on external APIs, so internet access and valid credentials are required.
- The scraper and AI services are best-effort tools and may fail if a page is blocked or rate-limited.
- Results are heuristic and should be treated as guidance rather than guaranteed proof of authenticity.
- The project is a prototype and can be extended with more advanced checks such as seller reputation, review authenticity detection, and image analysis.

## Future Improvements

Possible next steps for the project include:

- adding seller history checks
- detecting suspicious review patterns
- comparing prices across multiple marketplaces
- adding a history of prior scan results
- storing analysis in a local database
- improving UI with richer charts and explanation layers

## Summary

AuthentiCheck is a practical Flutter app that blends scraping and AI analysis to provide a quick counterfeit-risk assessment for online products. It is a strong foundation for an e-commerce trust and safety tool, especially when expanded with more seller, pricing, and review-based validation logic.
