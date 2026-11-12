<div align="center">

<img src="docs/banner.svg" alt="Chrono Vault - Premium watch storefront built with Flutter" width="100%"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-Material_3-63E5D7?style=for-the-badge&logo=flutter&logoColor=white&labelColor=0B1120)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-EE8A2E?style=for-the-badge&logo=dart&logoColor=white&labelColor=0B1120)](https://dart.dev)
[![Build APK](https://img.shields.io/github/actions/workflow/status/HammasT1/watchstore_flutter/build-apk.yml?style=for-the-badge&label=Build%20APK&logo=githubactions&logoColor=white&labelColor=0B1120)](https://github.com/HammasT1/watchstore_flutter/actions/workflows/build-apk.yml)
[![Release](https://img.shields.io/github/v/release/HammasT1/watchstore_flutter?style=for-the-badge&label=Release&logo=android&logoColor=white&labelColor=0B1120&color=91A4FF)](https://github.com/HammasT1/watchstore_flutter/releases/latest)

**Browse. Try on. Check out.**
A dark, animated watch storefront with a gesture-driven try-on studio and a glass-style checkout.

[Download APK](https://github.com/HammasT1/watchstore_flutter/releases/latest) &nbsp;·&nbsp; [Features](#-features) &nbsp;·&nbsp; [Screenshots](#-screenshots) &nbsp;·&nbsp; [Getting started](#-getting-started)

<img src="docs/divider.svg" alt="" width="100%"/>

</div>

> [!NOTE]
> **Status: prototype.** The catalog is hard-coded and the checkout is a UI preview. There is no backend, payment processing, or persistence yet.

## ✨ Features

| | |
| --- | --- |
| 🎠 **Animated carousel** | Swipe through 11 watches with scale, fade, and parallax effects. Tap a watch or a page indicator to jump to it. |
| 🎨 **Accent theming** | Every watch has its own accent color that drives the price, buttons, glow, and indicator. |
| ❤️ **Favorites and cart** | Toggle favorites, add to cart, and watch the header counter update live. |
| ⌚ **Try-On Studio** | Pinch to zoom, rotate with two fingers, and drag to place a watch over a wrist guide. |
| 🛒 **Cart collection** | Review selected watches with a running total. |
| 💳 **Smart Checkout preview** | A frosted-glass bottom sheet with an animated delivery ETA, payment selection, and an order confirmation dialog. |

## 📱 Screenshots

<div align="center">

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/01-home.png" width="200" alt="Home"/><br/><sub><b>Home</b></sub></td>
    <td align="center"><img src="docs/screenshots/02-catalog.png" width="200" alt="Catalog carousel"/><br/><sub><b>Catalog</b></sub></td>
    <td align="center"><img src="docs/screenshots/03-try-on.png" width="200" alt="Try-On Studio"/><br/><sub><b>Try-On Studio</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/04-cart.png" width="200" alt="Cart collection"/><br/><sub><b>Cart</b></sub></td>
    <td align="center"><img src="docs/screenshots/05-checkout.png" width="200" alt="Smart Checkout"/><br/><sub><b>Smart Checkout</b></sub></td>
    <td align="center"><img src="docs/screenshots/06-order-placed.png" width="200" alt="Order placed"/><br/><sub><b>Order placed</b></sub></td>
  </tr>
</table>

</div>

<sub>Screenshots are rendered from the app's actual widgets at 360×780 logical pixels (Roboto font, Material icons) using Flutter's test renderer. They are not captures from a physical device.</sub>

## 🎨 Design System

The UI uses a deep-navy dark theme with an orange primary and a teal secondary.

| Role | Color | Hex |
| --- | --- | --- |
| Primary | ![#EE8A2E](https://img.shields.io/badge/%20%20%20%20-EE8A2E-EE8A2E?style=flat-square) | `#EE8A2E` |
| Secondary | ![#63E5D7](https://img.shields.io/badge/%20%20%20%20-63E5D7-63E5D7?style=flat-square) | `#63E5D7` |
| Surface | ![#131B2C](https://img.shields.io/badge/%20%20%20%20-131B2C-131B2C?style=flat-square) | `#131B2C` |
| Background | ![#0B1120](https://img.shields.io/badge/%20%20%20%20-0B1120-0B1120?style=flat-square) | `#0B1120` |
| Checkout accent | ![#6AF5C6](https://img.shields.io/badge/%20%20%20%20-6AF5C6-6AF5C6?style=flat-square) | `#6AF5C6` |

## 🧰 Tech Stack

| Area | Details |
| --- | --- |
| Framework | Flutter, Material 3, dark theme |
| Language | Dart `^3.9.2` |
| State management | Built-in `setState` |
| Dependencies | `cupertino_icons` |
| Linting | `flutter_lints` |
| CI/CD | GitHub Actions, builds and releases the APK on version tags |

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.9.2 or later
- A configured target: Android, iOS, web, or desktop (Linux, macOS, Windows)

```bash
flutter doctor
```

### Install and run

```bash
git clone https://github.com/HammasT1/watchstore_flutter.git
cd watchstore_flutter
flutter pub get
flutter run                 # default connected device
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
flutter build apk --release   # Android
flutter build web             # Web
flutter build linux           # Desktop (or macos / windows)
```

## 📦 Releases and CI

[`build-apk.yml`](.github/workflows/build-apk.yml) analyzes, tests, and builds a release APK on every pull request to `main` and on every `v*` tag. Tag pushes also publish a GitHub Release with the APK attached.

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

> [!IMPORTANT]
> Release APKs are signed with the debug key, which is fine for testing and sideloading but not for Play Store distribution.

## 🗂 Project Structure

```
watchstore_flutter/
├── lib/
│   └── main.dart          # App entry point, screens, and widgets
├── assets/images/         # Product images and UI icons
├── docs/                  # README banner and screenshots
├── test/                  # Widget tests
├── .github/workflows/     # CI: APK build and release
└── android/ ios/ web/ linux/ macos/ windows/
```

Key components in [`lib/main.dart`](lib/main.dart):

| Component | Responsibility |
| --- | --- |
| `WatchStoreApp` | Root `MaterialApp` and theme |
| `WatchItem` | Immutable product model |
| `WatchStoreHome` | Carousel, product details, favorites, cart actions |
| `TryOnPage` | Gesture-driven try-on studio |
| `WristGuidePainter` | Custom painter for the wrist guide |
| `CartCollectionPage` | Cart summary and total |
| `SmartCheckoutSheet` | Checkout sheet with ETA and payment selection |

## 🗺 Roadmap

- [ ] Split `main.dart` into feature-based modules
- [ ] Load the catalog from a remote data source
- [ ] Persist cart and favorites
- [ ] Integrate a real payment provider
- [ ] Live camera try-on
- [ ] Native sharing
- [ ] Expand test coverage

## 🤝 Contributing

1. Fork the repository and create a feature branch.
2. Follow the lints in `analysis_options.yaml`.
3. Run `flutter analyze` and `flutter test` before submitting.
4. Open a pull request describing the change.

<div align="center">

<img src="docs/divider.svg" alt="" width="100%"/>

<sub>Built with Flutter by <a href="https://github.com/HammasT1">Muhammad Hammas Rasheed</a></sub>

</div>
