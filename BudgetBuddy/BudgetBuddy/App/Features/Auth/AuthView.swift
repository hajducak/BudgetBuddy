import SwiftUI
import Combine

struct AuthView: View {
    @ObservedObject var presenter: AuthPresenter
    
    var body: some View {
        VStack {
            Spacer()
            Image(.buddyBudget)
                .resizable()
                .frame(width: 400, height: 400)
            Spacer()
            Picker("Login or Register", selection: $presenter.selectedTab) {
                Text("Login").tag(0)
                Text("Registration").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if presenter.selectedTab == 0 {
                login.padding(.horizontal, 20)
            } else {
                register.padding(.horizontal, 20)
            }
            Spacer()
        }
        .background(Color(.accent))
        .toast($presenter.toast, timeout: 3)
    }
    
    var login: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $presenter.email)
                .padding()
                .textFieldStyle()
            
            SecureField("Password", text: $presenter.password)
                .padding()
                .textFieldStyle()
            
            PrimaryButton(
                title: "Login",
                isLoading: presenter.isLoading,
                isEnabled: presenter.loginEnabled
            ) {
                presenter.login()
            }
        }
    }
    
    var register: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $presenter.name)
                .padding()
                .textFieldStyle()

            TextField("Email", text: $presenter.email)
                .padding()
                .textFieldStyle()
            
            SecureField("Password", text: $presenter.password)
                .padding()
                .textFieldStyle()
            
            PrimaryButton(
                title: "Register",
                isLoading: presenter.isLoading,
                isEnabled: presenter.registrationEnabled
            ) {
                presenter.register()
            }
        }
    }
}
