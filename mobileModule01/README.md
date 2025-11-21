Piscine Mobile - Module 01: Structure and Logic
Overview
This module focuses on building the foundational structure and navigation for a weather application using Flutter. You'll create a responsive app with proper tab navigation and search functionality.

Project Structure
Turn-in directory: mobileModule01
Project name: weather_app
Important Note: This project continues in the next module, so thorough completion is essential.

Exercise Breakdown
Exercise 00: BottomBar
Objective: Create the main navigation structure with bottom tabs

Requirements:

AppBar with search TextField and geolocation button

BottomBar with 3 tabs:

"Currently" (default selected tab)

"Today"

"Weekly"

Responsive design for all devices

BottomBar Specifications:

Each tab must have both a name and an icon

Support both click navigation and swipe gestures between tabs

Tab content should display the tab name as text (placeholder for now)

First tab ("Currently") selected by default on app startup

Flutter Widgets to Use:

TabBar for TopBar with tabs

TabBarView for different views

BottomAppBar for BottomBar

Exercise 01: TopBar
Objective: Implement search and geolocation functionality

Requirements:

Search TextField in AppBar

Geolocation button in AppBar

Both components must be fully functional

Functionality Specifications:

Search TextField:

When text is entered, display format: [Tab Name] + [Entered Text]

Example: In "Currently" tab with search "Paris" → displays "Currently Paris"

Geolocation Button:

When clicked, display format: [Tab Name] + "Geolocation"

Example: In "Today" tab → displays "Today Geolocation"

Display Behavior:

The selected display format (search text or geolocation) should apply to ALL tabs

Content updates dynamically based on user interaction

Technical Requirements
Responsive Design
Application must work properly on all device sizes (phones, tablets)

Layout should adapt to different screen dimensions

Navigation
Smooth transitions between tabs

Both tab clicks and swipe gestures must work

Consistent state management across tabs

Code Structure
Clean, organized Flutter project structure

Proper use of Flutter widgets and state management

Reusable components where appropriate

Expected UI Flow
Initial State:

text
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
