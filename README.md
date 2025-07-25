# Gorby - Whistler Weather App

A beautiful iOS app for tracking weather conditions at Whistler Blackcomb mountain.

## Features

- **Real-time Weather Data**: Live temperature readings from multiple mountain locations
- **Lift Status**: Current status of all mountain lifts
- **Webcams**: Live mountain webcam feeds
- **Weather Forecast**: Detailed weather predictions
- **Snow Alerts**: Notifications for fresh powder
- **Snow Stake**: Current snow depth measurements

## Theme System

Gorby features a beautiful three-theme system:

### 🌞 Light Theme
- Clean, bright interface perfect for daytime use
- High contrast for excellent readability
- Vibrant colors for all mountain data

### 🌙 Dark Theme  
- Easy on the eyes for night use
- Reduces eye strain in low-light conditions
- Maintains vibrant accent colors

### ⚫ Greyscale Theme
- Minimalist black and white design
- Perfect for users who prefer monochrome interfaces
- All colors converted to elegant grays

## How to Change Themes

1. **Quick Toggle**: Tap the theme button in the top-right corner of the Home screen
2. **Settings Menu**: Go to Settings tab → Theme → Change
3. **Theme Selector**: Choose from Light, Dark, or Greyscale with beautiful previews

## Mountain Locations

The app tracks weather data from key Whistler locations:
- **7TH HEAVEN** - High alpine terrain
- **PEAK** - Whistler Peak
- **ROUNDHOUSE** - Mid-mountain lodge
- **VILLAGE** - Whistler Village base
- **GLACIER** - Glacier Bowl area
- **BASE** - Base area conditions

## Technical Details

- **Framework**: SwiftUI
- **Weather Data**: Apple WeatherKit integration
- **Location Services**: Core Location
- **Theme System**: Custom ThemeManager with UserDefaults persistence

## Development

The app uses a modular architecture with:
- **Features**: Organized by functionality (Home, Forecast, Lifts, etc.)
- **Services**: API clients and data services
- **Models**: Data structures for weather and mountain information
- **Core**: Navigation and theme management

## WeatherKit Integration

The app integrates with Apple's WeatherKit service to provide:
- Real-time temperature data
- Wind speed measurements
- Weather forecasts
- Location-based weather information

*Note: WeatherKit requires proper provisioning profile setup with WeatherKit entitlements.*

## Getting Started

1. Clone the repository
2. Open `Gorby.xcodeproj` in Xcode
3. Configure your Apple Developer account
4. Set up WeatherKit capabilities
5. Build and run on your device

## Support

For support or feature requests, please contact the development team.

---

*Built with ❄️ for the Whistler community* 