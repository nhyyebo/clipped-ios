# 🎨 Clipped - Beautiful iOS Clipboard Manager

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**A sleek, dark, and beautiful clipboard manager for iOS built with Flutter**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Building](#-building) • [Contributing](#-contributing)

</div>

## ✨ Features

### 📋 **Core Clipboard Management**
- **Auto-monitoring** - Automatically detects and saves copied content
- **One-tap copying** - Instantly copy any saved item to clipboard
- **Smart content detection** - Automatically categorizes URLs, emails, phone numbers
- **Persistent storage** - All items saved locally using Hive database

### 🎨 **Beautiful Dark UI**
- **iOS-inspired design** - Follows iOS design patterns and aesthetics
- **Dark theme** - Easy on the eyes with proper contrast ratios
- **Smooth animations** - 60fps animations with haptic feedback
- **Glass morphism effects** - Modern card designs with gradients

### 🔧 **Advanced Features**
- **Smart search** - Find clipboard items quickly with real-time filtering
- **Favorites system** - Star important items for easy access
- **Categories & tags** - Organize content with custom categories
- **Type filtering** - Filter by content type (text, URL, email, phone)
- **Manual item creation** - Create custom clipboard cards

### 🎯 **User Experience**
- **Haptic feedback** - Tactile responses for all interactions
- **iOS typography** - Proper font hierarchy using Inter font
- **Background monitoring** - Continuously watches clipboard (configurable)
- **Empty states** - Helpful guidance when no items exist

## 📱 Screenshots

*Coming soon - Screenshots of the beautiful dark interface*

## 🚀 Installation

### Method 1: Pre-built IPA (Recommended)
1. Download the latest IPA from [Releases](https://github.com/nhyyebo/clipped-ios/releases)
2. Install using:
   - **AltStore** (recommended for non-jailbroken devices)
   - **Xcode** (for development)
   - **Cydia Impactor** (deprecated but may work)

### Method 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/nhyyebo/clipped-ios.git
cd clipped-ios

# Install dependencies
flutter pub get

# Generate code (Hive adapters)
flutter packages pub run build_runner build

# Run on iOS simulator
flutter run

# Build for device (requires Apple Developer account)
flutter build ios --release
```

## 🏗️ Building

### Prerequisites
- **Flutter SDK** (3.24.5 or later)
- **Xcode** (latest stable)
- **iOS Developer Account** (for device installation)

### GitHub Actions
This repository includes automated CI/CD that:
- ✅ Builds the app on every tag push
- ✅ Runs tests and code generation
- ✅ Creates IPA files automatically
- ✅ Publishes releases with download links
- ✅ Uploads to App Store Connect (when configured)

### Local Development
```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build

# Run tests
flutter test

# Start development server
flutter run
```

## 🛠️ Tech Stack

- **Flutter 3.24.5** - Cross-platform framework
- **Provider** - State management
- **Hive** - Local database for persistence
- **Google Fonts** - Typography (Inter font)
- **UUID** - Unique identifiers
- **Intl** - Internationalization

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── clipboard_item.dart   # Data models with Hive annotations
├── services/
│   ├── clipboard_service.dart # Clipboard operations
│   └── storage_service.dart   # Local persistence
├── providers/
│   └── clipboard_provider.dart # State management
├── screens/
│   └── home_screen.dart      # Main UI screen
├── widgets/
│   └── clipboard_card.dart   # Reusable components
├── utils/
│   ├── colors.dart          # Color palette
│   └── text_styles.dart     # Typography
└── theme/
    └── app_theme.dart       # App theme configuration
```

## 🎨 Design System

### Color Palette
- **Primary Background**: `#000000`
- **Secondary Background**: `#1C1C1E`
- **Card Background**: `#2C2C2E`
- **Accent Color**: `#007AFF` (iOS Blue)
- **Text Primary**: `#FFFFFF`
- **Text Secondary**: `#8E8E93`

### Typography
- **Font Family**: Inter (Google Fonts)
- **iOS-style hierarchy** with proper letter spacing
- **Accessibility compliant** contrast ratios

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit with conventional commits: `git commit -m "feat: add amazing feature"`
5. Push to your fork: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Issues**: [GitHub Issues](https://github.com/nhyyebo/clipped-ios/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nhyyebo/clipped-ios/discussions)
- **Email**: [clipsfootball899@gmail.com](mailto:clipsfootball899@gmail.com)

## 📈 Roadmap

- [ ] **iPad Support** - Optimize for larger screens
- [ ] **Sync** - iCloud synchronization between devices
- [ ] **Shortcuts** - iOS Shortcuts app integration
- [ ] **Widgets** - iOS home screen widgets
- [ ] **Export** - Share clipboard history
- [ ] **Themes** - Additional color themes
- [ ] **Backup** - Import/export functionality

---

<div align="center">

**Built with ❤️ using Flutter**

[⭐ Star this repo](https://github.com/nhyyebo/clipped-ios) if you find it useful!

</div>