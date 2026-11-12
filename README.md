# Chrono Vault

A Flutter storefront for browsing and purchasing premium watches, featuring an animated product carousel, an interactive try-on studio, and a checkout preview flow.

> **Status:** Prototype. The catalog is hard-coded and the checkout flow is a UI preview only. No backend, payment processing, or persistence is implemented.

## Features

- **Animated product carousel** – Swipe through the catalog with scale, fade, and parallax effects. Tap a watch or a page indicator to jump to it.
- **Product details** – Name, description, price, and a per-product accent color that themes the active view.
- **Favorites and cart** – Toggle favorites and add items to a cart, with a live item counter in the header.
- **Try-On Studio** – Position a watch over a wrist guide using pinch-to-zoom, two-finger rotation, and drag gestures.
- **Cart collection** – Review selected watches with a running total.
- **Smart Checkout preview** – A frosted-glass bottom sheet with an animated delivery ETA, payment method selection, and an order confirmation dialog.

## Tech Stack

| Area | Details |
| --- | --- |
| Framework | Flutter (Material 3, dark theme) |
| Language | Dart `^3.9.2` |
| State management | Built-in `setState` |
| Dependencies | `cupertino_icons` |
| Linting | `flutter_lints` |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.9.2 or later
- A configured target: Android, iOS, web, or desktop (Linux, macOS, Windows)

Verify your setup with:

```bash
flutter doctor
```

### Installation

```bash
git clone <repository-url>
cd watchstore_flutter
flutter pub get
```

### Run

```bash
flutter run                 # runs on the default connected device
flutter run -d chrome       # web
flutter run -d linux        # desktop (or macos / windows)
```

### Test and analyze

```bash
flutter analyze
flutter test
```

### Build

```bash
flutter build apk           # Android
flutter build web           # Web
flutter build linux         # Desktop (or macos / windows)
```

## Project Structure

```
watchstore_flutter/
├── lib/
│   └── main.dart        # App entry point, screens, and widgets
├── assets/
│   └── images/          # Product images and UI icons
├── test/                # Widget tests
├── android/ ios/ web/   # Platform runners
└── linux/ macos/ windows/
```

Key components in [lib/main.dart](lib/main.dart):

| Component | Responsibility |
| --- | --- |
| `WatchStoreApp` | Root `MaterialApp` and theme configuration |
| `WatchItem` | Immutable product model |
| `WatchStoreHome` | Carousel, product details, favorites, and cart actions |
| `TryOnPage` | Gesture-driven try-on studio |
| `WristGuidePainter` | Custom painter for the wrist guide |
| `CartCollectionPage` | Cart summary and total |
| `SmartCheckoutSheet` | Checkout bottom sheet with ETA and payment selection |

## Roadmap

- Split `main.dart` into feature-based modules (models, screens, widgets)
- Move the catalog to a remote data source
- Add persistent cart and favorites
- Integrate a real payment provider
- Use the device camera for live try-on
- Add native sharing
- Expand test coverage

## Contributing

1. Fork the repository and create a feature branch.
2. Make your changes, following the lints configured in `analysis_options.yaml`.
3. Run `flutter analyze` and `flutter test` before submitting.
4. Open a pull request describing the change.
