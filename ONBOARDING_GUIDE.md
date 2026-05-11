# ShopKeeper Onboarding Feature Guide

## Overview

The ShopKeeper app now includes a comprehensive 5-screen onboarding flow that introduces new users to the app's key features. The onboarding appears only on first app launch and can be skipped at any time.

## Onboarding Screens

### Screen 1: Welcome to ShopKeeper
- **Icon**: Storefront
- **Title**: Welcome to ShopKeeper
- **Description**: Manage your shop inventory with ease and grow your business efficiently
- **Purpose**: App introduction and branding

### Screen 2: Manage Your Inventory
- **Icon**: Inventory
- **Title**: Manage Your Inventory
- **Features Highlighted**:
  - Real-time Stock Tracking - Monitor inventory levels instantly
  - Smart Alerts - Get notified when stock is low
- **Purpose**: Introduces inventory management capabilities

### Screen 3: Record Sales Easily
- **Icon**: Receipt
- **Title**: Record Sales Easily
- **Features Highlighted**:
  - Quick Sales Entry - Record transactions in seconds
  - Sales History - View all transactions with filters
- **Purpose**: Explains sales transaction features

### Screen 4: Track Customer Debts
- **Icon**: Wallet
- **Title**: Track Customer Debts
- **Features Highlighted**:
  - Customer Management - Track all customer debts
  - Risk Assessment - Categorize debt by risk level
- **Purpose**: Showcases debt management functionality

### Screen 5: AI-Powered Insights
- **Icon**: Auto Awesome
- **Title**: AI-Powered Insights
- **Features Highlighted**:
  - Smart Analytics - Get actionable business insights
  - Smart Notifications - Stay updated with important alerts
- **Purpose**: Introduces AI features and analytics

## User Interaction Flow

### Navigation Controls

**Skip Button** (Top Left)
- Available on all screens
- Skips the entire onboarding flow
- Redirects to login screen
- Marks onboarding as seen

**Screen Counter** (Top Center)
- Displays current screen number (e.g., "1/5")
- Shows progress through onboarding

**Next Button** (Top Right)
- Available on screens 1-4
- Disabled on screen 5
- Advances to next screen with smooth animation

**Get Started Button** (Bottom, Screen 5 only)
- Appears only on the final screen
- Completes onboarding
- Redirects to login screen
- Marks onboarding as seen

**Skip to Login Button** (Bottom, Screens 1-4)
- Alternative way to skip onboarding
- Redirects to login screen

## Technical Implementation

### File Structure

```
lib/features/onboarding/
├── presentation/
│   ├── providers/
│   │   └── onboarding_provider.dart
│   └── screens/
│       ├── onboarding_screen_1.dart
│       ├── onboarding_screen_2.dart
│       ├── onboarding_screen_3.dart
│       ├── onboarding_screen_4.dart
│       ├── onboarding_screen_5.dart
│       └── onboarding_page_view.dart
```

### OnboardingProvider

The `OnboardingProvider` manages the onboarding state:

```dart
class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  bool _hasSeenOnboarding = false;

  int get currentPage => _currentPage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  void nextPage() { /* ... */ }
  void previousPage() { /* ... */ }
  void skipOnboarding() { /* ... */ }
  void completeOnboarding() { /* ... */ }
  void resetOnboarding() { /* ... */ }
}
```

### OnboardingPageView

The main container widget that manages the PageView and navigation buttons.

### Individual Screens

Each screen (1-5) is a separate stateless widget that displays:
- Branded icon in a colored container
- Title and description
- Feature list with icons (screens 2-4)
- Dot indicators showing progress

## Design System Integration

### Colors Used

- **Owner Primary** (#1B5E20): Main text and accent elements
- **Accent** (#F57F17): Icons and highlights
- **Success** (#2E7D32): Positive features
- **Warning** (#F57C00): Alert features
- **Neutral Grays**: Background and secondary text

### Typography

- **Display Medium** (Playfair Display, 28sp): Screen titles
- **Body Medium** (DM Sans, 14sp): Descriptions and feature text
- **Body Small** (DM Sans, 12sp): Secondary information

### Spacing

- 40px top margin for icon
- 24px horizontal padding
- 16px vertical spacing between elements
- 32px bottom navigation area

## Routing Integration

### App Router Updates

The onboarding route has been added to the app router:

```dart
GoRoute(
  path: '/onboarding',
  builder: (context, state) => const OnboardingPageView(),
),
```

### Redirect Logic

The app router now includes redirect logic to show onboarding on first launch:

```dart
if (!hasSeenOnboarding && !isGoingToOnboarding && !isLoggedIn) {
  return '/onboarding';
}
```

## First Launch Detection

The onboarding is shown only on first app launch through the `hasSeenOnboarding` flag in `OnboardingProvider`. This flag is set to `true` when:

1. User completes all 5 screens and taps "Get Started"
2. User skips onboarding at any point
3. User taps "Skip to Login" button

## Customization

### Modifying Screen Content

To change the content of a screen, edit the corresponding screen file:

```dart
// Example: Changing Screen 2 title
Text(
  'Manage Your Inventory', // Change this
  style: AppTextStyles.displayM.copyWith(
    color: AppColors.ownerPrimary,
  ),
  textAlign: TextAlign.center,
),
```

### Adding More Screens

To add a 6th screen:

1. Create `onboarding_screen_6.dart`
2. Update the PageView children in `onboarding_page_view.dart`
3. Update the dot indicators to show 6 instead of 5
4. Update the "Get Started" button logic to check for screen 5 instead of 4

### Changing Colors

Update the icon container colors in each screen:

```dart
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    color: AppColors.yourColor.withOpacity(0.1), // Change color
    borderRadius: BorderRadius.circular(30),
  ),
  child: const Icon(
    Icons.yourIcon,
    size: 60,
    color: AppColors.yourColor, // Change color
  ),
),
```

## Testing the Onboarding

### First Launch Experience

1. Clear app data/reinstall the app
2. App should show Splash Screen briefly
3. Automatically redirect to Onboarding Screen 1
4. Navigate through all 5 screens using Next button
5. Tap "Get Started" on final screen
6. Should redirect to Login Screen

### Skip Functionality

1. On any onboarding screen, tap "Skip" button
2. Should immediately go to Login Screen
3. Onboarding should not appear again on next app launch

### Navigation

1. Use "Next" button to move forward
2. Dot indicators should update to show current page
3. Page counter should increment
4. On screen 5, "Next" button should be disabled

## Future Enhancements

Potential improvements to the onboarding feature:

1. **Persistent Storage**: Save onboarding state to local storage (SharedPreferences)
2. **Animation Transitions**: Add page transition animations
3. **Video Content**: Include short video demonstrations
4. **Interactive Elements**: Add interactive elements to showcase features
5. **Localization**: Translate onboarding content to multiple languages
6. **Analytics**: Track which screens users view and skip
7. **Customizable Frequency**: Allow users to view onboarding again from settings
8. **Role-Based Onboarding**: Different onboarding for Owner vs Staff roles

## Troubleshooting

### Onboarding Not Showing

- Check that `OnboardingProvider` is registered in `MultiProvider` in `app.dart`
- Verify that `hasSeenOnboarding` is initialized to `false`
- Check app router redirect logic

### Navigation Issues

- Ensure `PageController` is properly initialized and disposed
- Check that `go_router` routes are correctly configured
- Verify provider state updates are triggering UI rebuilds

### Design Issues

- Ensure all colors are defined in `app_colors.dart`
- Check that typography styles are defined in `app_text_styles.dart`
- Verify responsive layout works on different screen sizes

## Architecture Notes

The onboarding feature follows the same architectural patterns as the rest of the app:

- **Provider Pattern**: Uses ChangeNotifier for state management
- **Separation of Concerns**: Provider handles state, screens handle UI
- **Reusable Widgets**: Uses existing app widgets and design system
- **Clean Navigation**: Integrates seamlessly with go_router
- **Dependency Injection**: OnboardingProvider is injectable

---

**The onboarding flow is now fully integrated and ready for production use!**
