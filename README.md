//
//  README.md
//  RecipeApp
//
//  Created by TTHQ23-PANGWENHUEI on 20/08/2025.
//

# Recipe App - iOS

A complete iOS Recipe Application built with Swift, demonstrating modern iOS development practices including MVVM architecture, RxSwift reactive programming, Core Data persistence, authentication, and dependency injection.

## 🚀 Features

### Core Features
- ✅ **Recipe Management**: Add, edit, delete, and view recipes
- ✅ **Recipe Types**: Filter recipes by category using local JSON data
- ✅ **Image Support**: Display recipe images with URL loading
- ✅ **Ingredients & Steps**: Detailed recipe instructions
- ✅ **Core Data Persistence**: Data persists across app restarts
- ✅ **Safe Area Support**: Works on all iPhone screen sizes and orientations

### Advanced Features
- ✅ **MVVM Architecture**: Clean separation of concerns
- ✅ **RxSwift Reactive Programming**: Reactive data binding and minimal delegates
- ✅ **Authentication System**: Login/logout with session persistence and encryption
- ✅ **Dependency Injection**: Modular architecture using Swinject
- ✅ **Programmatic UI**: No storyboards, full programmatic Auto Layout
- ✅ **Unit & UI Tests**: Comprehensive test coverage

## 🏗️ Architecture

### Design Patterns Used
- **MVVM (Model-View-ViewModel)**: Separates business logic from UI
- **Repository Pattern**: Data access layer abstraction
- **Dependency Injection**: Loose coupling with Swinject container
- **Observer Pattern**: RxSwift for reactive programming

### Project Structure
```
RecipeApp/
├── Models/           # Data models (Recipe, RecipeType)
├── Services/         # Business logic (RecipeService, RecipeTypeService, AuthService)
├── ViewModels/       # MVVM view models with RxSwift
├── Views/            # UI components (ViewControllers)
├── Helper/           # Persistence layer & Dependency injection setup
├── Resources/        # JSON files, assets
└── Tests/            # Unit and UI tests
```

## 📱 Modules & Flow

### Authentication Flow
1. **Login Screen**: Simple authentication (admin/password)
2. **Session Management**: Encrypted session persistence

### Recipe Management Flow
1. **Recipe List**: Filterable list with recipe types
2. **Add/Edit Recipe**: Form with image URL, ingredients, steps
3. **Recipe Detail**: Full recipe view with edit/delete options

## 🛠️ Technical Implementation

### Technologies & Libraries
- **Swift 5.0+**: Primary programming language
- **UIKit**: Programmatic UI framework
- **RxSwift/RxCocoa**: Reactive programming
- **Core Data**: Data persistence
- **Swinject**: Dependency injection
- **Kingfisher**: Image loading and caching
- **XCTest**: Unit and UI testing

### Key Components

#### Services Layer
```swift
protocol RecipeServiceProtocol {
    ...
}
```

#### MVVM with RxSwift
```swift
class RecipeListViewModel: RecipeListViewModelProtocol {
    // Reactive data binding
}
```

#### Dependency Injection
```swift
// Swinject container setup
container.register(RecipeServiceProtocol.self) { resolver in
    return RecipeService(context: resolver.resolve(NSManagedObjectContext.self)!)
}.inObjectScope(.container)
```

## 📊 Data Management

### Core Data Model
- **RecipeEntity**: Stores recipe data with relationships
- **Ingredients/Steps**: Stored as JSON arrays in Core Data

### Local JSON Data
- **recipetypes.json**: Recipe categories loaded from bundle
- **Sample Data**: Pre-populated recipes for testing

### Authentication
- **Encrypted Sessions**: Base64 encoding with session persistence
- **UserDefaults**: Secure session storage

## 🧪 Testing

### Unit Tests
- Service layer testing
- ViewModel business logic testing
- Authentication flow testing
- Core Data operations testing

### UI Tests
- Login flow validation
- Recipe CRUD operations
- Navigation testing
- Accessibility testing

## 🚀 Getting Started

### Prerequisites
- Xcode 13.0+
- iOS 14.0+
- CocoaPods

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/recipe-app-ios.git
cd recipe-app-ios
```

2. **Install dependencies**
```bash
pod install
```

3. **Open workspace**
```bash
open RecipeApp.xcworkspace
```

4. **Build and run**
- Select target device/simulator
- Press Cmd+R to build and run

### Default Credentials
- **Username**: admin
- **Password**: password

## 📝 App Usage Guide

### Adding a Recipe
1. Tap the "+" button in the navigation bar
2. Fill in recipe details:
   - Title (required)
   - Select recipe type from picker
   - Image URL (optional)
   - Ingredients (one per line)
   - Steps (one per line)
3. Tap "Save Recipe"

### Filtering Recipes
1. Use the picker view at the top of the recipe list
2. Select "All Types" to show all recipes
3. Select specific type to filter

### Editing/Deleting Recipes
1. Tap on a recipe to view details
2. Use "Edit Recipe" to modify
3. Use "Delete Recipe" to remove (with confirmation)

## 🔄 App Lifecycle

### Proper Lifecycle Management
- **viewDidLoad**: Initial setup and binding
- **viewWillAppear**: Data refresh on navigation
- **App Background/Foreground**: Core Data context saving
- **Memory Management**: Proper RxSwift disposal

### Orientation Support
- Auto Layout constraints adapt to all orientations
- Safe area constraints for all device sizes
- Dynamic Type support for accessibility

## 🏆 Requirements Fulfilled

### ✅ Core Requirements
- [x] Swift programming language
- [x] JSON file for recipe types with UIPickerView
- [x] Recipe listing with filtering
- [x] Pre-populated sample data
- [x] Add Recipe functionality
- [x] Recipe Detail with update/delete
- [x] iOS persistence (Core Data)
- [x] Apple HCI principles compliance
- [x] Safe area and screen size adaptation
- [x] Data persistence across restarts
- [x] Crash-free operation

### ✅ Bonus Features
- [x] **Reactive Programming**: Full RxSwift implementation
- [x] **MVVM Architecture**: Clean, maintainable code structure
- [x] **Authentication**: Login/logout with encryption and session persistence
- [x] **Dependency Injection**: Swinject for modularity and testability
- [x] **Unit & UI Tests**: Comprehensive test coverage
- [x] **Programmatic UI**: No storyboards, full Auto Layout

### ✅ Programming Best Practices
- [x] Object-Oriented Programming principles
- [x] Swift naming and format conventions
- [x] Proper app lifecycle method usage
- [x] 3rd party library integration with CocoaPods
- [x] Error handling and user feedback
- [x] Memory management and performance optimization

## 🔍 Code Quality

### Architecture Benefits
- **Testability**: Dependency injection enables easy unit testing
- **Maintainability**: MVVM separation keeps code organized
- **Scalability**: Modular services can be easily extended
- **Reusability**: Protocol-based design enables component reuse

### Performance Optimizations
- **Lazy loading**: ViewModels and services instantiated on demand
- **Memory management**: Proper RxSwift disposal bags
- **Image caching**: Kingfisher for efficient image loading
- **Core Data optimization**: Efficient fetch requests and context management

## 📚 Learning Outcomes

This project demonstrates:
- Modern iOS app architecture patterns
- Reactive programming with RxSwift
- Core Data integration and management
- Authentication and security best practices
- UI design with programmatic Auto Layout
- Test-driven development approach
- Dependency injection for clean code

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@pangwenhuei](https://github.com/pangwenhuei)
- LinkedIn: [My LinkedIn](https://linkedin.com/in/wen-huei-pang-b77258249/)

---
