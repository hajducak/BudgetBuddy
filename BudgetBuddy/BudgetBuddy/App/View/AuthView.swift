import SwiftUI
import Combine

struct AuthView: View {
    @ObservedObject var presenter: AuthPresenter
    @State private var selectedTab = 0
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Picker("Login or Register", selection: $selectedTab) {
                Text("Login").tag(0)
                Text("Register").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedTab == 0 {
                login
            } else {
                register
            }
        }
        .padding()
    }
    
    var login: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if presenter.isLoading {
                ProgressView()
                    .padding()
            }
            
            if let errorMessage = presenter.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Login") {
                presenter.login(email: email, password: password)
            }
            .padding()
        }
    }
    
    var register: some View {
        VStack {
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if presenter.isLoading {
                ProgressView()
                    .padding()
            }
            
            if let errorMessage = presenter.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Register") {
                presenter.register(name: name, email: email, password: password)
            }
            .padding()
        }
    }
}
