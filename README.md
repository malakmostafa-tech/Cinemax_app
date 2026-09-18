# Cinemax App — Movie Discovery & Gemini AI Assistant

A modern, responsive Flutter application for movie discovery, TMDB watchlists, and an integrated **Gemini AI Movie Assistant**.

---

## 🌟 Key Features

- **Movie Discovery & Recommendations**: Now playing, popular movies, genre filtering, search, and details powered by TMDB.
- **Gemini AI Assistant**: Real-time streaming AI chat powered by official Google Gemini 2.5 Flash API.
- **TMDB Context Enrichment**: Automatically enriches AI prompts with live movie details, ratings, cast, and summaries.
- **RTL & Arabic Text Support**: Dynamic RTL text directionality with Cairo font for seamless Arabic & English responses.
- **Markdown & Code Blocks**: Rich Markdown output rendering with code syntax formatting and copy snippet buttons.
- **Resilient AI Architecture**: Exponential backoff retry for HTTP 429/5xx, timeouts, safety filter detection, and friendly error banners.

---

## 🚀 Setup & Running Instructions

### 1. Prerequisites
Ensure you have Flutter SDK installed (SDK version `^3.11.5`).

```bash
flutter --version
```

### 2. Environment Configuration
Copy `.env.example` to `.env` and set your API keys:

```bash
cp .env.example .env
```

Open `.env` and set `GEMINI_API_KEY`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
TMDB_API_KEY=3c6a284e154df432b7539c529d171b03
TMDB_SESSION_ID=dd9cd7a9336f6926c70ed835dd51752a0ca540e5
TMDB_ACCOUNT_ID=23708564
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Analysis & Tests
```bash
flutter analyze
flutter test
```

### 5. Run Application
Run on Chrome / Web:
```bash
flutter run -d chrome
```

Run on Android / iOS / Desktop:
```bash
flutter run
```

---

## 🛠 Project Structure

```
lib/
├── ai/                         # Gemini AI Feature
│   ├── data/
│   │   ├── api/                # Gemini REST Streaming API client (Gemini 2.5 Flash)
│   │   ├── repositories/       # Gemini Repository implementation with history trimming
│   │   └── services/           # TMDB Movie Context Enricher
│   ├── domain/
│   │   ├── constants/          # Cinemax AI System Instructions
│   │   ├── entities/           # ChatMessage & Role definitions
│   │   └── repositories/       # Gemini Repository Interface
│   └── presentation/
│       ├── cubit/              # GeminiChatCubit & GeminiChatState
│       ├── views/              # GeminiChatScreen
│       └── widgets/            # ChatMessageBubble & ChatInputBar
├── core/                       # Cinemax Design System, Colors, Typography
├── features/                   # Movie Discovery, Search, Wishlist & Profile
├── services/                   # TMDB API Service
└── main.dart                   # Application Entry Point
```
