import Firebase
import SwiftUI

@main
struct BudgetBuddyApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .preferredColorScheme(.light)
        }
    }
}
