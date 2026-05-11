# ShopKeeper - Mobile Shop Management System

A production-quality Flutter mobile application for managing small retail businesses in Cameroon. Built with Clean Architecture, Provider state management, and functional programming patterns.

## 📱 Features

### Owner Dashboard (9 Screens)
- **Dashboard**: Real-time sales metrics, low stock alerts, debt overview
- **Products**: Inventory management with search, add/edit products, stock tracking
- **Sales**: Transaction history, sales details, credit sales tracking
- **Debts**: Customer debt management, payment recording, risk assessment
- **Notifications**: System alerts for low stock, large sales, debt payments
- **AI Chat**: Business insights and analytics via conversational AI
- **Authentication**: Secure login for owners and staff

### Staff Interface (5 Screens)
- **Home**: Quick access to sales and price lists
- **Price List**: View current pricing for all products
- **New Sale**: Record sales transactions
- **Payment**: Process payments (cash/credit)
- **Sale Confirmation**: Confirm and finalize sales

## 🏗️ Architecture

### Clean Architecture with Three Layers

```
Presentation Layer (Blue)
├── Screens (StatelessWidget)
├── Providers (ChangeNotifier)
└── Widgets (Reusable UI components)

Domain Layer (Pink)
├── Entities (Pure Dart, immutable)
├── Repository Interfaces (Abstract)
└── Use Cases (Business logic)

Data Layer (Green)
├── Models (JSON serialization)
├── DataSources (Remote/Local)
└── Repository Implementations
```

### Key Technologies
- **State Management**: Provider 6.1+
- **Dependency Injection**: get_it 8+ with injectable 2.4+
- **Functional Programming**: fpdart 1.1+ (TaskEither, Option)
- **Routing**: go_router 14+ with ShellRoute
- **Design**: Material Design 3, Google Fonts
- **Animation**: flutter_animate 4.5+

## 🚀 Getting Started

### Prerequisites
- Flutter 3.24.0+
- Dart 3.5+
- Android SDK 26+ or iOS 14+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd shopkeeper_flutter

# Get dependencies
flutter pub get

# Generate DI wiring
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d android
# or
flutter run -d ios
```

### Linting
```bash
flutter analyze
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── constants/              # Colors, text styles, strings
│   ├── theme/                  # Theme configuration
│   ├── router/                 # Navigation setup
│   ├── utils/                  # Formatters, validators
│   ├── enums/                  # App enums
│   ├── errors/                 # Failure classes
│   ├── network/                # API client stub
│   └── widgets/                # Reusable widgets
├── di/
│   ├── injection.dart          # GetIt setup
│   └── injection.config.dart   # Auto-generated
├── mock_data/
│   └── mock_data.dart          # Static mock data
└── features/
    ├── auth/                   # Authentication
    ├── dashboard/              # Owner dashboard
    ├── products/               # Product management
    ├── sales/                  # Sales transactions
    ├── debts/                  # Debt management
    ├── notifications/          # Notifications
    ├── ai_chat/                # AI chat interface
    └── staff/                  # Staff screens
```

## 🎨 Design System

### Colors
- **Owner Primary**: #1B5E20 (Green)
- **Staff Primary**: #0D3B2E (Dark Green)
- **Accent**: #F57F17 (Amber)
- **Danger**: #C62828 (Red)

### Typography
- **Display**: Playfair Display (36, 28, 22, 18)
- **Heading**: DM Sans (20, 16, 14)
- **Body**: DM Sans (16, 14, 12)
- **Label**: DM Sans (13, 11, 10)

### Components
- **Buttons**: Primary, Outlined, Danger, Accent variants
- **Text Fields**: Validation, focus states, error handling
- **Badges**: Stock status, risk category, sync state
- **Cards**: Consistent spacing, shadows, rounded corners

## 🔄 Data Flow

```
Widget
  ↓
Provider (ChangeNotifier)
  ↓
Use Case
  ↓
Repository Interface
  ↓
Repository Implementation
  ↓
Remote/Local DataSource
  ↓
Models ↔ Entities
```

## 🔌 Backend Integration

Currently uses mock datasources. To connect to Golang backend:

1. Replace `MockProductRemoteDataSource` with `RealProductRemoteDataSource`
2. Implement HTTP calls to `/api/v1/products`
3. Update all other datasources similarly
4. No changes needed to providers, use cases, or screens

Example:
```dart
@LazySingleton(as: IProductRemoteDataSource)
class RealProductRemoteDataSource implements IProductRemoteDataSource {
  final ApiClient _client;
  
  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _client.get('/api/v1/products');
    return (response as List).map((e) => ProductModel.fromJson(e)).toList();
  }
}
```

## 📊 Mock Data

All mock data is in `lib/mock_data/mock_data.dart`:
- 10 Products (various categories)
- 5 Customers (different risk levels)
- 12 Sales transactions
- 8 Notifications
- 4 Chat messages
- Debt records

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📝 Screens Checklist

### Owner Screens
- [x] Splash Screen
- [x] Login Screen
- [x] Dashboard
- [x] Products List
- [x] Add/Edit Product
- [x] Sales History
- [x] Sale Details
- [x] Customer Debts
- [x] Customer Detail
- [x] Notifications
- [x] AI Chat

### Staff Screens
- [x] Staff Home
- [x] Price List
- [x] New Sale
- [x] Payment
- [x] Sale Confirmation

## 🔐 Security Notes

- JWT tokens stored securely (use flutter_secure_storage in production)
- Password validation enforced
- Role-based access control (Owner/Staff)
- API key management via environment variables

## 📦 Dependencies

See `pubspec.yaml` for complete list. Key packages:
- `provider: ^6.1.2` - State management
- `go_router: ^14.2.0` - Navigation
- `fpdart: ^1.1.0` - Functional programming
- `get_it: ^8.0.0` - Service locator
- `injectable: ^2.4.2` - DI code generation
- `google_fonts: ^6.2.1` - Typography
- `intl: ^0.19.0` - Internationalization
- `flutter_animate: ^4.5.0` - Animations

## 🚢 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📄 License

Proprietary - University of Bamenda, NAHPI

## 👨‍💻 Author

Fouotsa Mafo Willson (UBa22E0289)

## 🤝 Contributing

This is a university project. Contributions should follow the Clean Architecture patterns and coding standards outlined in the specification.

## 📞 Support

For issues or questions, contact the development team.

---

**Built with ❤️ using Flutter 3.24+ and Clean Architecture**
