import Firebase
import SwiftUI

@main
struct BudgetBuddyApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
