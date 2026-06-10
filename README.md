# GeoSurvey PBB (Property Tax Survey System)

A comprehensive mobile application and backend system designed for collecting and managing Property Tax (PBB - Pajak Bumi dan Bangunan) survey data efficiently in the field.

## Features

- **Mobile Application**: Cross-platform Flutter mobile application designed for field surveyors.
- **Integrated Native Camera**: Custom viewfinder-based camera interface supporting 1:1 aspect ratios for capturing property photos.
- **GPS Tracking & Mapping**: Non-intrusive reference map view for real-time GPS monitoring and location tracking during surveys.
- **Backend API**: Secure RESTful API built with Node.js and Express.js.
- **Database**: MySQL database configured for structured storage of PBB survey records.
- **Containerized Environment**: Easy local development setup using Docker and Docker Compose.

## Repository Structure

```text
Testing-GeoSurvey-PBB/
├── backend/                  # Node.js Express Backend API
│   ├── config/               # Database and environment configurations
│   ├── controllers/          # API endpoint logic
│   ├── middleware/           # Custom middleware (e.g., Auth)
│   ├── routes/               # API route definitions
│   ├── init.sql              # Database initialization schema
│   ├── package.json          # Backend dependencies
│   └── server.js             # Main application entry point
├── mobile/                   # Flutter Mobile Application
│   ├── lib/                  # Main Dart source code
│   │   ├── config/           # App configuration and constants
│   │   ├── models/           # Data models
│   │   ├── screens/          # UI screens and views
│   │   ├── services/         # API and business logic services
│   │   ├── utils/            # Helper functions
│   │   ├── widgets/          # Reusable UI components
│   │   └── main.dart         # Flutter app entry point
│   ├── pubspec.yaml          # Flutter dependencies
│   └── android/              # Native Android configuration
├── docker-compose.yml        # Docker composition for backend and database
└── README.md                 # Project documentation
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.11.5)
- [Docker & Docker Compose](https://www.docker.com/products/docker-desktop/)

### 1. Starting the Backend

The backend and database can be easily started using Docker.

```bash
# Start the MySQL database and Node.js backend containers
docker-compose up -d --build
```

### 2. Running the Mobile Application

With the backend running, you can launch the Flutter application:

```bash
# Get Flutter dependencies
flutter pub get

# Run the app on an emulator or connected device
cd mobile
flutter run
```

## Documentation
For more detailed information regarding the system's architecture, API endpoints, and database schema, please refer to the project's technical documentation.
