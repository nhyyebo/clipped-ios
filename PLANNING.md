# Clipped - Flutter Clipboard Manager

## 🎯 Project Goals
Build a beautiful, dark, sleek Flutter iOS clipboard manager app that allows users to:
- View clipboard history
- Create custom clipboard cards
- Instantly copy items with one tap
- Organize clipboard items efficiently
- Beautiful dark iOS-style UI

## 🏗️ Architecture & Structure

### Core Principles
- **Modular Design**: Separate concerns into distinct modules
- **State Management**: Use Provider/Riverpod for state management
- **Clean Architecture**: Models, Services, UI separation
- **iOS Design System**: Follow iOS design patterns and aesthetics

### File Structure
```
lib/
├── main.dart
├── models/
│   └── clipboard_item.dart
├── services/
│   ├── clipboard_service.dart
│   └── storage_service.dart
├── providers/
│   └── clipboard_provider.dart
├── screens/
│   ├── home_screen.dart
│   └── item_detail_screen.dart
├── widgets/
│   ├── clipboard_card.dart
│   ├── custom_app_bar.dart
│   └── floating_action_button.dart
├── utils/
│   ├── colors.dart
│   ├── text_styles.dart
│   └── constants.dart
└── theme/
    └── app_theme.dart
```

## 🎨 Design System

### Color Palette (Dark Theme)
- **Background**: #000000, #1C1C1E
- **Cards**: #2C2C2E, #3A3A3C
- **Accent**: #007AFF (iOS Blue)
- **Text**: #FFFFFF, #8E8E93
- **Borders**: #38383A

### Typography
- **San Francisco** font family (iOS native)
- Clear hierarchy with proper font weights
- Accessibility considerations

### Components
- **Cards**: Rounded corners, subtle shadows, glass morphism
- **Buttons**: iOS-style buttons with haptic feedback
- **Navigation**: iOS-style navigation patterns

## 🧱 Technical Constraints
- **File Size Limit**: Maximum 500 lines per file
- **Modular Components**: Each widget/service in separate files
- **Performance**: Smooth 60fps animations
- **Memory**: Efficient clipboard history management

## 📱 Features
1. **Clipboard History**: Auto-save copied items
2. **Manual Cards**: Create custom clipboard items
3. **Quick Copy**: One-tap copying
4. **Search**: Find clipboard items quickly
5. **Categories**: Organize items by type
6. **Persistence**: Save items across app restarts 