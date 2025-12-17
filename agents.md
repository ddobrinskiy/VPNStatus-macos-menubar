# VPN Status Menu Bar App - Implementation Notes

## Overview

A native macOS menu bar application that detects VPN connection status and displays a corresponding icon. Built with Swift and SwiftUI, targeting macOS 14+.

## Architecture

```
VPNStatus/
├── VPNStatusApp.swift      # SwiftUI App with MenuBarExtra
├── VPNMonitor.swift        # VPN detection logic + network monitoring
├── Info.plist              # LSUIElement=true (menu bar only, no dock icon)
├── VPNStatus.entitlements  # App permissions (sandbox disabled)
└── Assets.xcassets/        # App icons and colors
```

## Thought Process

### 1. VPN Detection Strategy

**Initial approach:** Check for network interfaces with VPN-related prefixes:
- `utun*` - Modern VPN tunnels (WireGuard, IKEv2, etc.)
- `ppp*` - Point-to-Point Protocol (L2TP, PPTP)
- `ipsec*` - IPsec tunnels
- `tap*` / `tun*` - OpenVPN-style interfaces

**Problem encountered:** macOS uses `utun` interfaces for system services too (iCloud Private Relay, network extensions), not just VPNs. These persist even when no VPN is connected.

**Solution:** Filter to only detect interfaces that have an **IPv4 address** assigned. Real VPN connections assign an IPv4 address to the tunnel interface, while system `utun` interfaces only have IPv6 link-local addresses.

```swift
let hasIPv4 = addr.pointee.ifa_addr?.pointee.sa_family == UInt8(AF_INET)
if isUp && isRunning && hasIPv4 {
    vpnNames.insert(interfaceName)
}
```

### 2. Real-time Updates

Used `NWPathMonitor` from the Network framework to observe network path changes. When connectivity changes, the VPN status is automatically rechecked.

```swift
pathMonitor?.pathUpdateHandler = { [weak self] _ in
    Task { @MainActor [weak self] in
        self?.checkVPNStatus()
    }
}
```

### 3. Menu Bar UI

Used SwiftUI's `MenuBarExtra` (available macOS 13+) for a modern, declarative approach:

- **Connected:** Filled shield icon (`lock.shield.fill`) in green
- **Disconnected:** Empty shield icon (`lock.shield`) in gray

The dropdown menu shows:
- Connection status with checkmark/X icon
- List of active VPN interfaces (for debugging)
- Refresh button (⌘R)
- Quit button (⌘Q)

### 4. App Sandbox Issue

**Problem:** Initial builds with app sandbox enabled couldn't read network interface information via `getifaddrs()`.

**Solution:** Disabled the app sandbox in entitlements. This is acceptable for a simple utility app that only reads network interface data.

```xml
<key>com.apple.security.app-sandbox</key>
<false/>
```

## Key Implementation Details

### Network Interface Detection

Uses the Darwin C API `getifaddrs()` to enumerate all network interfaces:

```swift
var addresses: UnsafeMutablePointer<ifaddrs>?
guard getifaddrs(&addresses) == 0, let firstAddr = addresses else {
    return []
}
defer { freeifaddrs(addresses) }
```

For each interface, checks:
1. Name matches VPN prefix (`utun`, `ppp`, etc.)
2. Interface flags include `IFF_UP` and `IFF_RUNNING`
3. Has an IPv4 address assigned (`AF_INET`)

### Menu Bar Only App

Set `LSUIElement = true` in Info.plist to make the app appear only in the menu bar with no Dock icon.

### SwiftUI Concurrency

The `VPNMonitor` class is marked `@MainActor` to ensure all UI updates happen on the main thread. The `NWPathMonitor` callback dispatches back to the main actor via `Task { @MainActor }`.

## Testing

1. **VPN Connected:** Shield icon turns green, shows "VPN Connected" with active interfaces listed
2. **VPN Disconnected:** Shield icon turns gray, shows "VPN Disconnected"
3. **Manual Refresh:** ⌘R or click Refresh button rechecks status
4. **Auto Update:** Connecting/disconnecting VPN triggers automatic status refresh via `NWPathMonitor`

## Future Improvements

- Add notification when VPN connects/disconnects
- Show VPN provider name if detectable
- Add "Launch at Login" option
- Support for detecting specific VPN configurations via `NEVPNManager`

