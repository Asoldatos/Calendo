# 📅 Calendo — Φωνητική Καταχώρηση Ραντεβού

<p align="center">
  <img src="Calendo/Assets.xcassets/AppIcon.appiconset/appicon.png" width="128" height="128" alt="Calendo Icon" />
</p>

**Calendo** είναι μια iOS εφαρμογή για Ελληνικά ιατρεία που σας επιτρέπει να καταχωρείτε ραντεβού ασθενών στο Google Calendar χρησιμοποιώντας τη φωνή σας.

## ✨ Χαρακτηριστικά

- 🎤 **Φωνητική εγγραφή** στα Ελληνικά (Apple Speech Framework)
- 🧠 **AI ανάλυση** με Google Gemini Flash (δωρεάν)
- 📅 **Αυτόματη καταχώρηση** στο Google Calendar
- 🏠 **Home Screen Shortcut** — ξεκινήστε εγγραφή αμέσως
- 💎 **Liquid Glass UI** (iOS 26+)
- 🇬🇷 **Πλήρως στα Ελληνικά**

## 📱 Πώς Λειτουργεί

1. **Συνδεθείτε** με τον Google λογαριασμό σας
2. **Πατήστε** "Νέο Ραντεβού" ή χρησιμοποιήστε το home screen shortcut
3. **Μιλήστε** — πείτε ημερομηνία, ώρα, και όνομα ασθενούς σε οποιαδήποτε σειρά
4. **Εισάγετε** τηλέφωνο (προαιρετικά)
5. **Ολοκληρώθηκε!** Το ραντεβού δημιουργείται αυτόματα

### Παραδείγματα Φωνητικών Εντολών

```
"Αύριο στις 3 ο Γιώργος Παπαδόπουλος για μισή ώρα"
"Τη Δευτέρα ο Νίκος Κωνσταντίνου από τέσσερις και μισή μέχρι πέντε"
"Στις 15 Οκτωβρίου εννέα το πρωί η Μαρία Αντωνίου"
```

### Μορφή Ημερολογίου

Τα events δημιουργούνται ως: `ΓΙΩΡΓΟΣ ΠΑΠΑΔΟΠΟΥΛΟΣ 6912345678`

## 🚀 Εγκατάσταση

### Βήμα 1: Ρύθμιση Google Cloud

1. Πηγαίνετε στο [Google Cloud Console](https://console.cloud.google.com)
2. Δημιουργήστε ένα project ή χρησιμοποιήστε υπάρχον
3. Ενεργοποιήστε το **Google Calendar API**
4. Δημιουργήστε **OAuth Client ID** (iOS type)
   - Bundle ID: `com.calendo.app`
5. Ρυθμίστε το **OAuth Consent Screen**

### Βήμα 2: Gemini API Key

1. Πηγαίνετε στο [Google AI Studio](https://aistudio.google.com/apikey)
2. Δημιουργήστε ένα **δωρεάν API key**
3. Αντικαταστήστε `YOUR_GEMINI_API_KEY` στο αρχείο `Calendo/Utilities/Constants.swift`

### Βήμα 3: Build & Install

#### Αυτόματο (GitHub Actions)

1. Κάντε push τον κώδικα σε ένα GitHub repository
2. Πηγαίνετε στο **Actions** tab
3. Κατεβάστε το **Calendo-IPA** artifact
4. Εγκαταστήστε με **AltStore** ή **Sideloadly**

#### Τοπικό Build (macOS)

```bash
# Εγκαταστήστε XcodeGen
brew install xcodegen

# Δημιουργήστε το Xcode project
xcodegen generate

# Ανοίξτε στο Xcode
open Calendo.xcodeproj
```

### Βήμα 4: Εγκατάσταση στο iPhone

**Με AltStore:**
1. Εγκαταστήστε το [AltStore](https://altstore.io) στον υπολογιστή σας
2. Συνδέστε το iPhone
3. Μεταφέρετε το `Calendo.ipa`
4. Η εφαρμογή ανανεώνεται κάθε 7 ημέρες

**Με Sideloadly:**
1. Κατεβάστε το [Sideloadly](https://sideloadly.io)
2. Συνδέστε το iPhone
3. Σύρετε το `Calendo.ipa` στο Sideloadly
4. Εισάγετε το Apple ID σας

## 🏗️ Δομή Έργου

```
Calendo/
├── CalendoApp.swift              # Entry point & Google Sign-In
├── ContentView.swift             # Navigation router
├── Info.plist                    # Permissions & URL schemes
├── Models/
│   └── AppointmentData.swift     # Appointment data model
├── Services/
│   ├── GoogleAuthService.swift   # Google Sign-In wrapper
│   ├── GoogleCalendarService.swift # Calendar API
│   ├── SpeechRecognitionService.swift # Greek speech recognition
│   └── GeminiService.swift       # Gemini AI parsing
├── Utilities/
│   ├── Constants.swift           # API keys & config
│   ├── Extensions.swift          # SwiftUI helpers
│   └── HapticManager.swift       # Haptic feedback
└── Views/
    ├── Onboarding/               # Welcome & sign-in
    ├── Home/                     # Dashboard
    ├── Recording/                # Voice recording
    ├── DurationInput/            # Duration chatbox
    ├── PhoneInput/               # Phone number entry
    ├── Processing/               # Event creation
    └── Components/               # Reusable UI
```

## ⚙️ Τεχνολογίες

| Τεχνολογία | Χρήση |
|------------|-------|
| SwiftUI | UI Framework |
| Liquid Glass | iOS 26 design |
| Apple Speech Framework | Greek voice recognition |
| Google Gemini Flash | AI text parsing |
| Google Sign-In | Authentication |
| Google Calendar API | Event creation |
| XcodeGen | Project generation |
| GitHub Actions | CI/CD |

## 📋 Απαιτήσεις

- iOS 26.0+
- iPhone
- Google Account
- Σύνδεση στο internet

## 📄 Άδεια

Ιδιωτική χρήση — Calendo
