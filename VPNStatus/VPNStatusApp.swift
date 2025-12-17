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
        
        if vpnMonitor.isConnected && !vpnMonitor.vpnInterfaces.isEmpty {
            Divider()
            
            Section("Active Interfaces") {
                ForEach(vpnMonitor.vpnInterfaces, id: \.self) { interface in
                    Label(interface, systemImage: "network")
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
}
