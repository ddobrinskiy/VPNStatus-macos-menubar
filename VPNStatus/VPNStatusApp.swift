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
        HStack(spacing: 8) {
            Image(systemName: vpnMonitor.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(vpnMonitor.isConnected ? .green : .red)
            Text(vpnMonitor.isConnected ? "VPN Connected" : "VPN Disconnected")
        }
        .padding(.horizontal, 4)
        
        if vpnMonitor.isConnected && !vpnMonitor.vpnInterfaces.isEmpty {
            Divider()
            
            Text("Active Interfaces:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(vpnMonitor.vpnInterfaces, id: \.self) { interface in
                HStack(spacing: 6) {
                    Image(systemName: "network")
                        .foregroundStyle(.secondary)
                    Text(interface)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        
        Divider()
        
        Button {
            vpnMonitor.checkVPNStatus()
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh")
            }
        }
        .keyboardShortcut("r", modifiers: .command)
        
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            HStack {
                Image(systemName: "power")
                Text("Quit")
            }
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
