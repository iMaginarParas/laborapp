# Laborgro Mobile App 📱

Laborgro is a high-fidelity, hyperlocal service marketplace mobile application built with Flutter. It connects users with skilled professionals (plumbers, painters, cleaners, etc.) in their immediate vicinity.

## ✨ Features

- **Hyperlocal Discovery**: Find workers near you using Google Maps and precise geolocation.
- **Glassmorphic UI**: Premium, modern design with smooth transitions and vibrant aesthetics.
- **Secure Booking**: Seamless flow from discovery to scheduling and booking confirmation.
- **Auth System**: Integrated JWT-based authentication.
- **Real-time Price Calculation**: Automatic calculation of rates, platform fees, and discounts.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Maps & Location**: `google_maps_flutter`, `geolocator`
- **Design**: Material 3 with Custom Themes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- A Google Maps API Key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/iMaginarParas/laborapp.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure API Key:
   Open `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your key.

4. Run the app:
   ```bash
   flutter run
   ```

## 🌐 API Connectivity

The app is pre-configured to communicate with the Laborgro Backend API. You can update the backend URL in:
`lib/core/constants/api_constants.dart`

---
Built with ❤️ by Laborgro Team
