# VPN Status

A lightweight macOS menu bar app that shows your VPN connection status and current IP location with country flag.

![Menu Bar Screenshot](screenshots/menubar.png)

## Features

- **Real-time VPN detection** - Automatically detects when you connect/disconnect from VPN
- **Country flag display** - Shows your current IP location as a flag emoji in the menu bar
- **IP geolocation** - Displays country, city, and IP address in the dropdown menu
- **Shield indicator** - Shows checkmark shield (✓🛡️) when VPN is connected, X shield (⊗🛡️) when disconnected
- **No dock icon** - Runs quietly in your menu bar without cluttering your dock

## Download

### Latest Release: v1.0.0

[**Download VPNStatus.zip**](https://github.com/ddobrinskiy/VPNStatus-macos-menubar/releases/download/v1.0.0/VPNStatus.zip)

## Installation

1. Download `VPNStatus.zip` from the latest release
2. Unzip the file
3. Move `VPNStatus.app` to your Applications folder
4. Double-click to run

### First Launch

On first launch, macOS may show a security warning since the app isn't signed with an Apple Developer certificate:

1. Right-click (or Control-click) on `VPNStatus.app`
2. Select "Open" from the context menu
3. Click "Open" in the dialog that appears

The app will now run and appear in your menu bar.

## Usage

- **Menu bar icon** shows:
  - `✓🛡️ + 🇪🇪` - VPN connected (with VPN exit country flag)
  - `⊗🛡️ + 🇷🇺` - VPN disconnected (with your real country flag)

- **Click the icon** to see:
  - Connection status
  - Current country, city, and IP address
  - Active VPN interfaces

- **Keyboard shortcuts**:
  - `⌘R` - Refresh status
  - `⌘Q` - Quit

## How It Works

The app detects VPN connections by monitoring network interfaces for VPN tunnels (utun, ppp, ipsec, tap, tun). It specifically looks for interfaces with IPv4 addresses to distinguish actual VPN connections from system services like iCloud Private Relay.

IP geolocation is provided by [ip-api.com](http://ip-api.com).

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel Mac

## Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/ddobrinskiy/VPNStatus-macos-menubar.git
   cd vc-ipstatus
   ```

2. Open in Xcode:
   ```bash
   open VPNStatus.xcodeproj
   ```

3. Build and run with `⌘R`

Or build from command line:
```bash
xcodebuild -project VPNStatus.xcodeproj -scheme VPNStatus -configuration Release build
```

## License

MIT License - feel free to use, modify, and distribute.

## Credits

Built with SwiftUI for macOS. IP geolocation by [ip-api.com](http://ip-api.com).

