# HealthMate AI - Development To-Do List

This document outlines the development plan for **HealthMate AI**, broken down into phases and actionable steps based on the PRD, Design Document, and Tech Stack.

## Phase 1: Project Initialization & Core Setup

- [x] **Project Setup**
    - [x] Set up version control (Git).
    - [x] Configure `pubspec.yaml` with core dependencies:
        - `flutter_riverpod` (State Management)
        - `go_router` (Navigation)
        - `supabase_flutter` (Backend)
        - `google_fonts` (Typography)
        - `flutter_svg` (Icons)
        - `get_it` (Dependency Injection)
        - `dio` (Networking)
        - `json_serializable` / `json_annotation` (Dependencies added, conflict pending resolution)

- [x] **Design System Implementation**
    - [x] **Colors:** Define `AppColors` based on Design Doc:
        - Primary: Deep Blue `#034C81`
        - Secondary: Sky Blue `#2CA3FA`
        - Accent: Health Green `#04E474`
        - Supportive: Soft Purple `#8E7FFF`
        - Neutral/Dark: `#333333`, `#6B7480`
        - Background: White `#FFFFFF`, Surface `#F5F7FA`
    - [x] **Typography:** Configure `GoogleFonts.inter` text theme using defined scales (Title 28pt Bold, Header 22pt SemiBold, etc.).
    - [x] **Theme:** Create `AppTheme` with `ThemeData`:
        - make dark and light theme
        - Define Button styles (Rounded 12px).
        - Define Input Decoration (Underline/Outline).
        - Define Card Theme (Rounded 16px, Elevation 2).
    - [x] **Components:** Create reusable widgets:
        - `PrimaryButton`, `SecondaryButton`
        - `CustomTextField`
        - `InfoCard` (Placeholder/Context ready)

- [ ] **Backend Integration (Supabase)**
    - [ ] Create Supabase project.
    - [x] Initialize Supabase in `main.dart` (Partially - Key placeholder).
    - [x] **Authentication:**
        - [x] Enable Email/Password Auth.
        - [x] (Optional) Enable Google OAuth.
        - [x] Implement `AuthService` using `supabase_flutter`.
        - [x] Create UI: `SplashScreen`, `LoginScreen`, `SignupScreen` (Professional Design Implemented).
    - [x] **Navigation:** Set up `GoRouter` with routes for auth vs. authenticated structure.

## Phase 2: Database & Data Modules

- [x] **Database Schema (Supabase)**
    - [x] Create Tables:
        - `users` (id, email, profile_data)
        - `health_logs` (id, user_id, type [sleep/water/steps], value, timestamp)
        - `symptoms_logs` (id, user_id, symptoms [], urgency, timestamp)
        - `reminders` (id, user_id, title, time, is_active)
        - `recommendations` (id, user_id, text, type)
    - [x] Setup RLS (Row Level Security) policies to secure user data. (Added via `supabase_schema.sql` file)

- [x] **Habit Tracker Module**
    - [x] Create `HabitRepository` for CRUD operations on `health_logs`.
    - [x] Implement **UI Screens**:
        - `HabitTrackerScreen`: Tabbed/List view for Sleep, Water, Steps, Mood.
        - Input forms for logging daily data.
    - [x] Integrate State Management to reflect updates immediately.

- [x] **Symptom Checker Module (Basic)**
    - [x] Create `SymptomRepository`.
    - [x] Implement **UI Screens**:
        - `SymptomCheckerScreen`: Search/Select symptoms.
        - `SymptomResultScreen`: Display urgency and advice.
    - [x] Save symptom logs to Supabase.

## Phase 3: AI Modules & Logic

- [x] **Symptom Classification (AI)**
    - [x] Implement Logic:
        - [x] *Option A (MVP):* Rule-based engine mapping specific symptoms to urgency levels (Low/Medium/High).
        - [ ] *Option B (Advanced):* Integrate TFLite model or Call an Edge Function with an LLM API.
    - [x] Display Disclaimer: "Not a medical diagnosis."

- [x] **Personalized Insights Engine**
    - [x] Implement logic to analyze `health_logs` (e.g., Calculate weekly averages of sleep/water).
    - [x] Generate basic recommendations (e.g., "Your sleep average is low").
    - [x] Create `InsightsScreen` to display these text-based insights.

- [x] **AI Chat Assistant**
    - [x] Implement `ChatService`.
    - [x] Choose Provider:
        - *Offline:* Ollama/Local LLM (if feasible on device).
        - *Online:* Gemini API / OpenAI API via Supabase Edge Functions. (Simulated for Demo)
    - [x] Implement **UI Screens**:
        - `ChatScreen`: Chat bubble interface (Right: User, Left: AI - Soft Purple).
    - [x] Add "typing" indicators and error handling.
    - [x] Implement Prompt Engineering for safety/healthcare context.

## Phase 4: Visualization & Dashboards

- [ ] **Dashboard / Home Screen**
    - [ ] Create `HomeScreen` layout.
    - [ ] **Widgets**:
        - Greeting & User Name.
        - "Daily Health Score" Card (Progress Ring).
        - Quick Access Grid (Symptom Checker, Habits, Chat).
    - [ ] Fetch and display summary data from Supabase.

- [ ] **Charts & Analytics**
    - [ ] Add `fl_chart` dependency.
    - [ ] Implement Charts:
        - Sleep history (Bar Chart).
        - Water intake (Line Chart).
        - Activity levels.
    - [ ] Create `AnalysisScreen` or embed in `HabitTrackerScreen`.

- [ ] **Community Trends (Anonymized)**
    - [ ] Create `community_trends` table or view in Supabase (aggregated data).
    - [ ] Implement `CommunityScreen` showing heatmaps or general stats (e.g., "Flu season trends").

## Phase 5: Notifications, Polish & Settings

- [ ] **Notification System**
    - [ ] Add `flutter_local_notifications`.
    - [ ] Implement `ReminderService`.
    - [ ] **UI:** `ReminderSettingsScreen` to set daily reminders (Meds, Water, Sleep).
    - [ ] Schedule local notifications based on user input.

- [ ] **Profile & Settings**
    - [ ] Implement `ProfileScreen` (Edit Name, Avatar).
    - [ ] Image Upload: Use Supabase Storage for profile pictures.
    - [ ] Settings: Dark/Light theme toggle, Logout.

- [ ] **Testing & Quality Assurance**
    - [ ] **Unit Tests:** Test Repositories and Logic classes.
    - [ ] **Widget Tests:** Test critical UI components.
    - [ ] **Accessibility:** Check contrast ratios, font scaling, and screen reader labels.
    - [ ] **Performance:** Optimization check (Image caching, List lazy loading).

- [ ] **Final Deployment Prep**
    - [ ] Run `flutter build` for Android/iOS.
    - [ ] Verify Supabase production keys and RLS.
    - [ ] Cleanup code and format (`dart format .`).
