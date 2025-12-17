import Foundation
import Network
import Combine

/// Monitors VPN connection status by checking network interfaces
@MainActor
final class VPNMonitor: ObservableObject {
    
    /// Whether a VPN connection is currently active
    @Published private(set) var isConnected: Bool = false
    
    /// List of detected VPN interface names (for debugging)
    @Published private(set) var vpnInterfaces: [String] = []
    
    /// Network path monitor for detecting connectivity changes
    private var pathMonitor: NWPathMonitor?
    private let monitorQueue = DispatchQueue(label: "com.vpnstatus.networkmonitor")
    
    /// VPN interface name prefixes to detect
    private let vpnInterfacePrefixes = [
        "utun",   // Modern VPN tunnels (WireGuard, IKEv2, system VPNs)
        "ppp",    // Point-to-Point Protocol (L2TP, PPTP)
        "ipsec",  // IPsec tunnels
        "tap",    // OpenVPN TAP interfaces
        "tun",    // OpenVPN TUN interfaces
        "gpd",    // GlobalProtect
        "wg"      // WireGuard (some implementations)
    ]
    
    init() {
        checkVPNStatus()
        startMonitoring()
    }
    
    deinit {
        pathMonitor?.cancel()
    }
    
    /// Check current VPN connection status by examining network interfaces
    func checkVPNStatus() {
        let interfaces = getActiveVPNInterfaces()
        
        self.vpnInterfaces = interfaces
        self.isConnected = !interfaces.isEmpty
    }
    
    /// Get list of active network interfaces that appear to be VPN tunnels
    private func getActiveVPNInterfaces() -> [String] {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        var vpnNames: Set<String> = []
        
        // Get all network interfaces
        guard getifaddrs(&addresses) == 0, let firstAddr = addresses else {
            return []
        }
        
        defer { freeifaddrs(addresses) }
        
        // Iterate through all interfaces
        var currentAddr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = currentAddr {
            let interfaceName = String(cString: addr.pointee.ifa_name)
            
            // Check if this interface name matches any VPN prefix
            for prefix in vpnInterfacePrefixes {
                if interfaceName.hasPrefix(prefix) {
                    // Verify the interface is up and running
                    let flags = Int32(addr.pointee.ifa_flags)
                    let isUp = (flags & IFF_UP) != 0
                    let isRunning = (flags & IFF_RUNNING) != 0
                    
                    // Check if this is an IPv4 address (AF_INET)
                    // VPN tunnels with actual traffic have IPv4 addresses assigned
                    // System utun interfaces (iCloud Private Relay, etc.) only have IPv6 link-local
                    let hasIPv4 = addr.pointee.ifa_addr?.pointee.sa_family == UInt8(AF_INET)
                    
                    if isUp && isRunning && hasIPv4 {
                        vpnNames.insert(interfaceName)
                    }
                    break
                }
            }
            
            currentAddr = addr.pointee.ifa_next
        }
        
        return Array(vpnNames).sorted()
    }
    
    /// Start monitoring for network changes
    private func startMonitoring() {
        pathMonitor = NWPathMonitor()
        
        pathMonitor?.pathUpdateHandler = { [weak self] _ in
            // Network path changed, recheck VPN status
            Task { @MainActor [weak self] in
                self?.checkVPNStatus()
            }
        }
        
        pathMonitor?.start(queue: monitorQueue)
    }
    
    /// Stop monitoring for network changes
    private func stopMonitoring() {
        pathMonitor?.cancel()
        pathMonitor = nil
    }
}

