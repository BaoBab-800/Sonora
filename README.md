# Sonora

> A local music player for people who want to own their music.

Sonora is a Flutter-based local music player focused on simplicity, personal music libraries, and full control over playback.

No streaming service. No recommendations. No subscription.
Just your music.

## Features

* Play music stored on your device
* Browse your local music library
* Mark tracks as favorites
* Create and manage playlists
* Shuffle and repeat playback
* Seek through tracks and control volume
* Independent player instances

## Screenshots

<!-- TODO: Add screenshots -->

|       Library       |        Player       |       Playlist      |
| :-----------------: | :-----------------: | :-----------------: |
| <!-- screenshot --> | <!-- screenshot --> | <!-- screenshot --> |

## Tech Stack

Sonora is built with Flutter and uses a small set of focused packages:

* **Flutter / Dart** – application framework and language
* **Riverpod** – state management
* **media_kit** – audio playback
* **Hive** – local persistence
* **go_router** – navigation
* **on_audio_query** – access to music stored on the device

## Architecture

The project follows a feature-oriented architecture with a separation between UI, application state, repositories, and the playback layer.

One of the more important parts of Sonora is its player architecture.

Instead of having one global audio player, Sonora uses a `PlayerManager` capable of managing multiple independent player instances. Each player has its own state, queue, playback position, repeat mode, shuffle state, and current track.

```text
UI
 │
 ▼
Riverpod Providers
 │
 ▼
Player Controller
 │
 ▼
Player Manager
 │
 ├── Player 1
 ├── Player 2
 ├── Player 3
 └── ...
      │
      ▼
   media_kit
```

This keeps the playback engine independent from the UI and makes the system capable of handling an arbitrary number of players.

## Getting Started

### Requirements

* Flutter
* Dart
* Android SDK

Check your Flutter installation:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone https://github.com/BaoBab-800/Sonora.git
cd Sonora
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

## Why Sonora?

Modern music applications are increasingly built around streaming catalogs, recommendations, subscriptions, and online accounts.

Sonora takes a different approach.

Your music is yours. The application should simply provide a convenient way to listen to it.

## License

Sonora is licensed under the MIT License.

See the [LICENSE](LICENSE) file for the full license text.