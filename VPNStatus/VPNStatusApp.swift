import SwiftUI

@main
struct VPNStatusApp: App {
    @StateObject private var vpnMonitor = VPNMonitor()
    
    var body: some Scene {
        MenuBarExtra {
            VPNStatusMenu(vpnMonitor: vpnMonitor)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: vpnMonitor.isConnected ? "checkmark.shield.fill" : "xmark.shield")
                if vpnMonitor.isConnected {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                }
            }
        }
    }
}

struct VPNStatusMenu: View {
    @ObservedObject var vpnMonitor: VPNMonitor
    
    var body: some View {
        // Status header
        Label(
            vpnMonitor.isConnected ? "VPN Connected" : "VPN Disconnected",
            systemImage: vpnMonitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .foregroundStyle(vpnMonitor.isConnected ? .green : .red)
        
        // Location info
        if let country = vpnMonitor.country {
            Divider()
            
            Section("Location") {
                if let countryCode = vpnMonitor.countryCode {
                    let flag = countryCodeToFlag(countryCode)
                    Text("\(flag) \(country)")
                } else {
                    Label(country, systemImage: "globe")
                }
                
                if let city = vpnMonitor.city {
                    Label(city, systemImage: "building.2")
                }
                
                if let ip = vpnMonitor.ipAddress {
                    Label(ip, systemImage: "network")
                        .font(.system(.body, design: .monospaced))
                }
            }
        } else if vpnMonitor.isLoadingLocation {
            Divider()
            Text("Loading location...")
                .foregroundStyle(.secondary)
        }
        
        if vpnMonitor.isConnected && !vpnMonitor.vpnInterfaces.isEmpty {
            Divider()
            
            Section("Interfaces") {
                ForEach(vpnMonitor.vpnInterfaces, id: \.self) { interface in
                    Label(interface, systemImage: "point.3.connected.trianglepath.dotted")
                }
            }
        }
        
        Divider()
        
        Button {
            vpnMonitor.checkVPNStatus()
        } label: {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .keyboardShortcut("r", modifiers: .command)
        
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Label("Quit", systemImage: "power")
        }
        .keyboardShortcut("q", modifiers: .command)
    }
    
    /// Convert country code to flag emoji
    private func countryCodeToFlag(_ code: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in code.uppercased().unicodeScalars {
            if let unicode = Unicode.Scalar(base + scalar.value) {
                flag.append(String(unicode))
            }
        }
        return flag
    }
}
