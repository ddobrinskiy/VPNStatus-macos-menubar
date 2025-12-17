# VPN Status Menu Bar App - Implementation Notes

## Overview

A native macOS menu bar application that detects VPN connection status and displays a corresponding icon with country flag. Built with Swift and SwiftUI, targeting macOS 14+.

**Repository:** https://github.com/ddobrinskiy/VPNStatus-macos-menubar

## Current State

The app is fully functional with these features:
- Real-time VPN detection via network interface monitoring
- Country flag display in menu bar (using ip-api.com geolocation)
- Shield icon indicator (checkmark when connected, X when disconnected)
- Dropdown menu showing country, city, IP address, and VPN interfaces

## Architecture

```
VPNStatus/
├── VPNStatusApp.swift      # SwiftUI App with MenuBarExtra
├── VPNMonitor.swift        # VPN detection + network monitoring + IP geolocation
├── Info.plist              # LSUIElement=true, ATS exception for ip-api.com
├── VPNStatus.entitlements  # App sandbox disabled
└── Assets.xcassets/        # App icons (custom shield icon)
```

## Key Files

### VPNMonitor.swift
- `checkVPNStatus()` - Detects VPN by checking network interfaces for IPv4-enabled utun/ppp/ipsec/tap/tun
- `fetchIPLocation()` - Calls ip-api.com to get country, city, IP
- `NWPathMonitor` - Watches for network changes and triggers refresh

### VPNStatusApp.swift
- `MenuBarExtra` with dynamic label showing shield icon + country flag
- `countryCodeToFlag()` - Converts "US" to 🇺🇸 emoji
- Dropdown menu with location details and refresh/quit buttons

## Build & Run

```bash
# Build release
xcodebuild -project VPNStatus.xcodeproj -scheme VPNStatus -configuration Release build

# Install to Applications
cp -R ~/Library/Developer/Xcode/DerivedData/VPNStatus-*/Build/Products/Release/VPNStatus.app /Applications/

# Create release zip
cd ~/Library/Developer/Xcode/DerivedData/VPNStatus-*/Build/Products/Release
zip -r VPNStatus.zip VPNStatus.app

# Create GitHub release
gh release create v1.x.x VPNStatus.zip --title "VPN Status v1.x.x" --notes "Release notes here"
```

## Known Issues & Pending Fixes

_No pending fixes at this time._

### ✅ COMPLETED: Fix stale flag on VPN status change

**Problem:** When VPN connects/disconnects, the old country flag persisted in the menu bar for ~0.5 seconds while the new IP location was being fetched.

**Solution implemented:**
1. `VPNMonitor.swift`: Modified `checkVPNStatus()` to clear location data immediately before fetching new location
2. `VPNStatusApp.swift`: Updated menu bar label to show an ellipsis loading indicator when `countryCode` is nil but `isLoadingLocation` is true

## Technical Details

### VPN Detection
- Uses `getifaddrs()` Darwin API to enumerate network interfaces
- Filters for interfaces with VPN-related prefixes (utun, ppp, ipsec, tap, tun)
- Only counts interfaces with IPv4 addresses (filters out system utun for iCloud Private Relay)

### IP Geolocation
- Uses http://ip-api.com/json/ (free, no API key)
- Requires ATS exception in Info.plist (HTTP not HTTPS)
- Returns country, countryCode, city, and IP address

### App Configuration
- `LSUIElement = true` - Menu bar only, no dock icon
- App sandbox disabled - Required for `getifaddrs()` access
- Network client entitlement for API calls

## Commits History
1. Initial working VPN detection with shield icon
2. Added IP geolocation with country flag
3. Fixed menu layout with Label components  
4. Added custom app icon
5. Show shield + flag in menu bar for both states
6. Created README and GitHub release v1.0.0
7. Renamed repo to VPNStatus-macos-menubar
