# Freelexity

Freelexity is an open-source answer engine built with Flutter. It leverages the power of Brave Search API and Groq API to provide users with comprehensive answers to their queries.

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [API Keys](#api-keys)
5. [How It Works](#how-it-works)
6. [File Structure](#file-structure)
7. [Workflow](#workflow)
8. [License](#license)
9. [Contributing](#contributing)
10. [Contact](#contact)

## Features

- Dark-themed UI for comfortable viewing
- Voice search capability
- Web scraping for comprehensive answers
- AI-powered summarization of search results
- Related questions suggestion
- Search history with local storage
- Image search results

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Flutter SDK (version 3.5.3 or later)
- Dart SDK (version 3.5.3 or later)
- Android Studio / VS Code with Flutter extensions
- An active internet connection

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/TheGuyDangerous/Freelexity.git
   ```

2. Navigate to the project directory:

    ```bash
    cd Freelexity
    ```

3. Install dependencies:
  
   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## API Keys

To use Freelexity, you need to obtain API keys for both Brave Search and Groq. Here's how:

### Brave Search API Key

1. Visit [https://api.search.brave.com/app/keys](https://api.search.brave.com/app/keys)
2. Sign up or log in to your Brave account
3. Create a new API key for the Brave Search API
4. Copy the API key

### Groq API Key

1. Go to [https://console.groq.com/keys](https://console.groq.com/keys)
2. Sign up or log in to your Groq account
3. Generate a new API key
4. Copy the API key

Once you have both API keys, enter them in the app's Settings screen.

## How It Works

Freelexity combines web search, content scraping, and AI-powered summarization to provide comprehensive answers to user queries. Here's a brief overview of the process:

1. User inputs a query through text or voice
2. The app sends the query to the Brave Search API
3. Top search results are retrieved
4. The app scrapes content from the top results
5. Scraped content is sent to the Groq API for summarization
6. The summary and search results are displayed to the user
7. Related questions are generated based on the query and summary
8. The search query and results are saved in the user's local history

## File Structure

```
lib/
├── main.dart
├── custom_page_route.dart
├── screens/
│ ├── search_screen.dart
│ ├── library_screen.dart
│ ├── settings_screen.dart
│ ├── thread_screen.dart
│ ├── thread_loading_screen.dart
│ └── license_screen.dart
└── services/
├── search_service.dart
├── web_scraper_service.dart
├── groq_api_service.dart
└── grok_api_service.dart
```

## Workflow

1. **Search Screen**: The main interface where users input their queries.
2. **Thread Loading Screen**: Displays a loading animation while processing the search.
3. **Thread Screen**: Shows the search results, summary, and related questions.
4. **Library Screen**: Displays the user's search history.
5. **Settings Screen**: Allows users to input API keys and view app information.

## License

This project is licensed under a custom license. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions to Freelexity are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and suggest improvements.

## Contact

For commercial licensing options or any queries, please contact:
<sannidhyadubey@gmail.com>

---

Created with ❣️ by Sannidhya Dubey
