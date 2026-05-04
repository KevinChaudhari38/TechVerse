# 📚 TechVerse – Cross-Platform Educational Mobile App

**TechVerse** is a Flutter-based educational platform designed to provide a **centralized learning ecosystem** for students, teachers, and administrators.

It supports **PDF learning, premium video content, query-based interaction, and role-based dashboards**, powered by **Firebase and Razorpay integration**.

---

## 🚀 Key Features

### 👤 Multi-Role System

* **Student**

  * Browse courses
  * Access free PDFs
  * Unlock premium videos
  * Ask queries to teachers

* **Teacher**

  * Upload PDFs & videos
  * Manage courses
  * Answer student queries
  * Track earnings & transactions

* **Admin**

  * Manage users (students/teachers)
  * Manage courses
  * Monitor payments
  * System-level control

---

## 📱 Core Functionalities

### 📚 Course Management

* Add and manage courses
* Structured content delivery
* Course listing and details

### 📄 PDF Learning System

* Free access to study materials
* External viewing using URL launcher

### 🎥 Premium Video Learning

* Video playback using Chewie player
* Premium access via payment system

### 💬 Query System

* Students can ask questions
* Teachers respond through dashboard
* Query tracking system

### 💳 Payment Integration

* Razorpay integration (Test Mode ₹1)
* Premium upgrade system
* Transaction tracking

---

## 🧠 System Architecture

* Role-based navigation after authentication
* Real-time updates using Firebase Streams
* Stateful UI with dynamic rendering

---

## 🏗️ Project Structure

```bash id="7rq62w"
TECHVERSE/
│
├── lib/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── student_dashboard.dart
│   │   ├── teacher_dashboard.dart
│   │   ├── admin_dashboard.dart
│   │   ├── course_list_page.dart
│   │   ├── course_content_page.dart
│   │   ├── add_video.dart
│   │   ├── add_pdf.dart
│   │   ├── payment_page.dart
│   │   ├── ask_query_page.dart
│   │   ├── teacher_queries_page.dart
│   │   └── video_player_page.dart
│
├── android/ ios/ web/     # Platform-specific code
├── firebase.json
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Tech Stack

### 🔹 Frontend

* Flutter (3.x)
* Dart
* Material UI

### 🔹 Backend & Database

* Firebase Authentication
* Cloud Firestore (NoSQL DB)

### 🔹 Storage

* Cloudinary (for PDFs & videos)

### 🔹 Payments

* Razorpay Flutter SDK

### 🔹 Media & Utilities

* Chewie (Video Player)
* Image Picker
* File Picker
* URL Launcher
* HTTP
* UUID

---

## 🔐 Security

* Firebase Authentication (Login/Register)
* Role-based access control
* Secure data storage in Firestore

---

## ⚙️ Setup Instructions

### 1️⃣ Clone Repository

```bash id="98dj6o"
git clone https://github.com/YOUR_USERNAME/TechVerse.git
cd TechVerse
```

---

### 2️⃣ Install Dependencies

```bash id="b9q2mr"
flutter pub get
```

---

### 3️⃣ Configure Firebase

* Add your `google-services.json` (Android)
* Add `GoogleService-Info.plist` (iOS)
* Update Firebase config files:

  * `firebase_options.dart`

---

### 4️⃣ Run Application

```bash id="1az9qf"
flutter run
```

---

## 🌐 Application Flow

1. User registers (select role: Student/Teacher)
2. Login via Firebase Authentication
3. Role-based dashboard is loaded
4. Students browse courses → view PDFs → unlock videos
5. Teachers upload content & respond to queries
6. Admin manages entire platform

---

## 📊 Key Highlights

* Cross-platform (Android, iOS, Web)
* Real-time data synchronization (Firestore)
* Role-based architecture
* Integrated payment system
* Scalable cloud-based backend

---

## 👨‍💻 Author

**Kevin A. Chaudhari**


⭐ If you like this project, consider giving it a star!
