# Module 01 - Navigation & Structure

## Overview

Build a multi-screen application with proper navigation patterns. This module focuses on creating a weather application with tab-based navigation, search functionality, and geolocation features.

## Project Structure

**Directory:** `mobileModule01`
**Project Name:** `weather_app`

Note: This project continues in Module 02. Complete all exercises thoroughly.

## Exercises

### Exercise 00 - Bottom Navigation

Implement the main navigation structure with tab-based interface.

**Objectives:**
- Create BottomNavigationBar with 3 tabs
- Implement TabBar and TabBarView widgets
- Add icon and label to each tab
- Support both click and swipe navigation
- Make application responsive across device sizes

**Tabs:**
- Currently (default)
- Today
- Weekly

### Exercise 01 - Top Navigation & Search

Implement search and geolocation features in the AppBar.

**Objectives:**
- Add search TextField to AppBar
- Add geolocation button to AppBar
- Implement search functionality across all tabs
- Implement geolocation button functionality
- Manage state across tab navigation

**Functionality:**
- Search displays format: `[Tab Name] [Search Term]`
- Geolocation displays format: `[Tab Name] Geolocation`
- State persists across all tabs

## Technical Requirements

### Responsive Design
- Support multiple device sizes (phones, tablets)
- Adaptive layouts for different screen dimensions
- Proper spacing and padding

### Navigation
- Smooth tab transitions
- Gesture-based swipe navigation
- Consistent state across screens
- Proper widget hierarchy

### Code Quality
- Clean project structure
- Reusable components
- Proper state management
- Meaningful variable and function names

## Getting Started

```bash
cd mobileModule01
flutter pub get
flutter run
```
AppBar: [Search TextField] [Geolocation Button]
BottomBar: [Currently⚡] [Today📅] [Weekly📊]
Content: "Currently" (on Currently tab)
After Search:

text
Search: "London"
Content in all tabs: "Currently London", "Today London", "Weekly London"
After Geolocation:

text
Geolocation button pressed
Content in all tabs: "Currently Geolocation", "Today Geolocation", "Weekly Geolocation"
Submission Guidelines
Repository Structure
text
mobileModule01/
└── weather_app/
    ├── lib/
    ├── pubspec.yaml
    └── all necessary Flutter files
Evaluation Criteria
Functionality: All specified features work correctly

Navigation: Smooth tab switching with both clicks and swipes

Responsive Design: Works on various screen sizes

Code Quality: Clean, well-organized Flutter code

UI/UX: Proper implementation of Material Design guidelines

Important Notes
This is a cumulative project that continues in Module 02

Test thoroughly on different device sizes

Ensure both search and geolocation functionalities work independently

Maintain consistent state across all tabs

Follow Flutter best practices for widget composition

Getting Started
Create a new Flutter project named weather_app

Implement the BottomBar navigation structure (Exercise 00)

Add TopBar functionality with search and geolocation (Exercise 01)

Test responsiveness on different screen sizes

Ensure all navigation methods work correctly

Remember: This foundation will be built upon in future modules, so focus on creating a solid, maintainable code structure!
