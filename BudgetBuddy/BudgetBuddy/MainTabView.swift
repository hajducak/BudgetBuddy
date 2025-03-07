import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("View 1")
                .tabItem {
                    Label("Wallet", systemImage: "wallet.pass")
                }
            
            Text("View 2")
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            
            Text("View 3")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
