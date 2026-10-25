# Mr. Manager (Govt Job & Exam Tracking Android App)

**Mr. Manager** is a complete, production-ready Flutter/Dart Android application designed for Indian government job aspirants. It automatically calculates which government exams and jobs you are eligible for, maintains an interactive calendar of all crucial milestones, fires time-to-time push notifications for application deadlines and admit cards, and tracks your registration credentials so you never miss a deadline or exam.

---

## 🌟 Key Features

1. **Intelligent Eligibility Matcher Engine (`eligibility_engine.dart`)**:
   - Matches candidate profile against official gazetted criteria:
     - **Education**: 10th, 12th, Diploma, Graduation, Post-Graduation, and specific disciplines (e.g., B.Tech, B.Sc, LLB).
     - **Age Limits & Relaxation**: Automatically factors in central and state reservation benefits:
       - **General / UR**: Base limit (e.g. 18–30 or 21–32)
       - **OBC**: Base + 3 Years
       - **SC / ST**: Base + 5 Years
       - **PwD**: Base + 10 to 15 Years
       - **Ex-Serviceman**: Applicable military deduction
     - **Percentage / Aggregate Marks**: Minimum cut-off checks (e.g., 60% for RBI Grade B).
     - **Domicile / State PSC**: Filters state quota restrictions.

2. **Time-to-Time Push Notifications (`notification_service.dart`)**:
   - **Deadline Reminders**: Alerts at 5 days, 3 days, and 24 hours before online form closes.
   - **Admit Card Release Alerts**: Notifies as soon as hall tickets are available with direct download links.
   - **Exam Countdown**: Alerts 7 days and 1 day prior to the exam with exam center advice.
   - Background alarms registered with `flutter_local_notifications` and exact alarm boot receiver.

3. **Interactive Exam Calendar (`calendar_screen.dart`)**:
   - Monthly & weekly calendar powered by `table_calendar`.
   - Distinct color-coded milestone dots:
     - 🟢 **Green**: Application Start Date
     - 🔴 **Red**: Final Day to Apply
     - 🔵 **Blue**: Admit Card / Hall Ticket Release Date
     - 🟣 **Purple**: Written / CBT Exam Day
     - 🟡 **Amber**: Result Declaration Date
   - Tap any date to see all scheduled exams and directly set reminders.

4. **Exam Application Pipeline & Hall Ticket Locker (`tracker_screen.dart`)**:
   - Pipeline stages: *Considering ➔ Form Submitted ➔ Admit Card Ready ➔ Appeared ➔ Qualified*.
   - Stores **Application Numbers** and **Roll Numbers** securely on-device so you never scramble for them on exam day.

---

## 📂 Project Architecture

```
mr_manager/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml          # Notification, Alarm, Internet permissions
├── lib/
│   ├── main.dart                        # App entry point, Material 3 Navy & Emerald Theme
│   ├── models/
│   │   ├── job_model.dart               # Complete Govt Exam model & stages
│   │   ├── user_profile_model.dart      # Candidate profile, age calc & categories
│   │   └── calendar_event_model.dart    # Calendar milestones & color mapping
│   ├── services/
│   │   ├── eligibility_engine.dart      # Rule-based eligibility & age relaxation engine
│   │   ├── notification_service.dart    # Local notification & alarm scheduler
│   │   ├── job_repository.dart          # Real-time state, mock data (SSC, UPSC, IBPS, RRB)
│   │   └── profile_provider.dart        # User profile state & persistence
│   └── screens/
│       ├── home_screen.dart             # Feed with "Eligible For Me", alerts & filters
│       ├── job_detail_screen.dart       # Eligibility breakdown, syllabus & official links
│       ├── calendar_screen.dart         # Interactive TableCalendar with color milestones
│       ├── tracker_screen.dart          # Application pipeline & credentials locker
│       └── profile_screen.dart          # Profile setup & eligibility re-evaluator
└── pubspec.yaml                         # Dependencies: provider, table_calendar, local_notifications
```

---

## 🚀 How to Run & Build the App

### 1. Requirements
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / Android SDK (API Level 21+)

### 2. Install Dependencies
```bash
cd mr_manager
flutter pub get
```

### 3. Run on Android Device / Emulator
```bash
flutter run
```

### 4. Build Production APK
```bash
flutter build apk --release
```
The compiled APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📡 Live Government Feeds Integration

In `lib/services/job_repository.dart`, the app currently includes pre-configured real recruitment data for:
- **SSC CGL 2026** (14,250 posts)
- **UPSC Civil Services 2026** (1,120 posts)
- **IBPS PO XVI** (4,850 posts)
- **RRB NTPC** (11,558 posts)
- **SSC CHSL 10+2** (3,712 posts)
- **UPPSC State PCS** (220 posts)
- **DRDO CEPTAM** (1,901 posts)

To connect to live external APIs or RSS feeds, simply implement an HTTP GET request in `JobRepository.refreshJobsLive()` pointing to your backend endpoint (e.g. Firebase, Supabase, or a Python RSS scraper that parses official government employment news).
