import SwiftUI
import Firebase
import FirebaseFirestore

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Firebase Setup Complete!")
                .padding()
        }
        .onAppear {
            let db = Firestore.firestore()
            db.collection("test").addDocument(data: ["message": "Hello Firebase"]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document successfully added!")
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
