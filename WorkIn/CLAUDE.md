# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# GymBros - iOS SwiftUI Workout Tracking App

## Project Overview

GymBros is an iOS SwiftUI workout tracking application that provides comprehensive fitness and nutrition tracking capabilities. The app features a clean, modern interface built entirely with SwiftUI and follows Apple's design guidelines.

## High-Level Architecture

### App Structure
- **Entry Point**: `GymBrosApp.swift` - Standard SwiftUI app entry point
- **Main Interface**: `ContentView.swift` - Tab-based navigation with 4 main sections
- **Navigation**: TabView with 4 tabs: Workouts, Nutrition, Progress, Profile

### Core Features
1. **Workout Tracking** - Real-time workout logging with exercise selection and set tracking
2. **Nutrition Tracking** - Fo

4. **User Profile** - Personal settings and preferences

## Data Models & Architecture

### Core Data Models (`/GymBros/Models/`)

**WorkoutModels.swift**:
- `Workout`: Contains workout metadata (name, date, duration, exercises)
- `Exercise`: Individual exercise with sets, muscle groups, equipment
- `ExerciseSet`: Single set data (reps, weight, rest time, completion status)

**NutritionModels.swift**:
- `FoodEntry`: Individual food item with macronutrients
- `DailyNutrition`: Aggregates food entries by date with computed totals

**ExerciseDatabase.swift**:
- `ExerciseTemplate`: Pre-defined exercises organized by category
- `ExerciseCategory`: Enum for Push/Pull/Legs/Core/Cardio classification
- Comprehensive exercise database with muscle group mappings

### State Management
- **ObservableObject Classes**: Each major feature has its own data manager
  - `WorkoutData`: Manages workout history and active workouts
  - `NutritionData`: Handles food entries and daily nutrition
  - `ProgressData`: Tracks analytics and progress metrics
- **@StateObject/@Published**: SwiftUI reactive state management
- **No Persistence**: Currently uses in-memory storage (comments indicate planned UserDefaults/CoreData integration)

## Views Architecture (`/GymBros/Views/`)

### Main Views
1. **WorkoutView.swift**:
   - Dual-mode interface: workout history vs active workout
   - Real-time timer during workouts
   - Integration with exercise selection and set logging

2. **NutritionView.swift**:
   - Daily nutrition summary with visual indicators
   - Food entry list with delete functionality
   - Integration with food selection component

3. **ProgressView.swift**:
   - Statistics overview with grid layout
   - Volume charts for visual progress tracking
   - Recent workout summaries

4. **ProfileView.swift**:
   - User preferences and settings

### Reusable Components (`/GymBros/Components/`)

**ActiveExerciseView.swift**:
- Collapsible exercise cards for active workouts
- Inline set logging with rep/weight input
- Real-time set completion tracking

**ExerciseSelectionView.swift**:
- Categorized exercise browser
- Search functionality
- Multi-select capability for workout creation

**SetLoggingView.swift**:
- Dedicated set entry interface
- Rest timer functionality
- Set progression tracking

**FoodSelectionView.swift**:
- Food database browsing
- Nutritional information display
- Portion size calculation

**VolumeChartView.swift**:
- Custom chart implementation for progress visualization
- Weekly volume tracking

## Key Design Patterns

### SwiftUI Patterns
- **Compositional Views**: Heavy use of computed properties for view composition
- **State Binding**: Parent-child data flow using callbacks and bindings
- **Sheet Presentations**: Modal workflows for data entry
- **List Management**: Dynamic lists with delete operations

### Data Flow
- **Unidirectional Data Flow**: Parent views own state, children receive bindings
- **Callback Pattern**: Child components use closures to communicate changes up
- **Reactive Updates**: @Published properties trigger UI updates automatically

## Build & Development

### Xcode Project Structure
- **Target**: GymBros (single iOS target)
- **Configurations**: Debug, Release
- **Scheme**: GymBros
- **Minimum iOS Version**: Determined by SwiftUI requirements

### Build Commands
```bash
# Build the project
xcodebuild -project "GymBros.xcodeproj" -scheme GymBros -configuration Debug build

# Build for device
xcodebuild -project "GymBros.xcodeproj" -scheme GymBros -configuration Release -destination 'generic/platform=iOS' build

# Run tests (if tests exist)
xcodebuild -project "GymBros.xcodeproj" -scheme GymBros test -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Development Workflow
- Standard Xcode development workflow
- SwiftUI previews for rapid iteration
- No external dependencies (pure SwiftUI/Foundation)

## Configuration Files

### Claude Code Configuration
- **`.claude/settings.local.json`**: Allows xcodebuild permissions for Claude Code operations

### Assets
- Standard iOS app bundle structure
- App icons and accent color defined in Assets.xcassets

## Current Limitations & TODOs

### Data Persistence
- **Current**: In-memory storage only
- **Planned**: UserDefaults for simple data, CoreData for complex relationships
- Comments in ProgressView.swift indicate planned persistence implementation

### Testing
- No test files currently present
- Opportunity to add unit tests for data models and view models

### Features
- Basic functionality implemented across all major features
- Room for enhancement in analytics and social features

## Directory Structure Overview

```
GymBros/
├── GymBros/                    # Main app source (duplicate structure exists at root)
│   ├── Models/                 # Data models and business logic
│   │   ├── WorkoutModels.swift
│   │   ├── NutritionModels.swift
│   │   ├── ExerciseDatabase.swift
│   │   ├── WorkoutTemplates.swift
│   │   └── FoodDatabase.swift
│   ├── Views/                  # Main screen views
│   │   ├── WorkoutView.swift
│   │   ├── NutritionView.swift
│   │   ├── ProgressView.swift
│   │   └── ProfileView.swift
│   ├── Components/             # Reusable UI components
│   │   ├── ActiveExerciseView.swift
│   │   ├── ExerciseSelectionView.swift
│   │   ├── SetLoggingView.swift
│   │   ├── FoodSelectionView.swift
│   │   └── VolumeChartView.swift
│   ├── Assets.xcassets/        # App icons and colors
│   ├── Preview Content/        # SwiftUI preview assets
│   ├── ContentView.swift       # Main tab view
│   └── GymBrosApp.swift       # App entry point
├── GymBros.xcodeproj/         # Xcode project files
└── .claude/                   # Claude Code configuration
```

## Getting Started for Future Development

1. **Open Project**: Open `GymBros.xcodeproj` in Xcode
2. **Run App**: Select iOS Simulator and run the scheme
3. **Key Entry Points**:
   - Start with `ContentView.swift` to understand navigation
   - Examine `WorkoutView.swift` for the most complex feature implementation
   - Review data models to understand the data structure
4. **Add Features**: Follow the established patterns for new views and components
5. **Data Persistence**: Implement UserDefaults or CoreData based on the TODO comments

This codebase demonstrates solid SwiftUI architecture with clear separation of concerns, making it straightforward to extend and maintain.