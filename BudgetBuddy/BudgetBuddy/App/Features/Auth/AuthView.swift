import SwiftUI
import Combine

struct AuthView: View {
    @ObservedObject var presenter: AuthPresenter
    @State var passwordIsSecured: Bool = true
    
    var body: some View {
        VStack(alignment: .leading,  spacing: 16) {
            Picker("Login or Register", selection: $presenter.selectedTab) {
                Text("Login").tag(0)
                Text("Registration").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            if presenter.selectedTab == 0 {
                login
            } else {
                register
            }
        }
        .authBaseView()
        .toast($presenter.toast, timeout: 3)
        .sheet(isPresented: $presenter.showBiometricPrompt) {
            biometricPromptView
        }
        .onAppear {
            if presenter.biometricType != .none && presenter.keychainService.isBiometricEnabled() {
                presenter.authenticateWithBiometrics()
            }
        }
    }
    
    var login: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $presenter.email)
                .textFieldStyle()
            SecureField("Password", text: $presenter.password)
                .textFieldStyle()
            Spacer()
            
            if presenter.biometricType != .none && presenter.keychainService.isBiometricEnabled() {
                faceIDButton
            }

            PrimaryButton(
                title: "Login",
                isLoading: presenter.isLoading,
                isEnabled: presenter.loginEnabled
            ) {
                presenter.login()
            }
        }.padding(.horizontal, 20)
    }
    
    var register: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $presenter.name)
                .textFieldStyle()

            TextField("Email", text: $presenter.email)
                .textFieldStyle()
            
            HStack {
                Button {
                    presenter.generateRandomPassword()
                } label: {
                    Image(systemName: "square.and.pencil.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(height: 25)
                }
                Button {
                    passwordIsSecured.toggle()
                } label: {
                    Image(systemName: passwordIsSecured ? "eye.slash.circle" : "eye.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(height: 25)
                }
                if passwordIsSecured {
                    SecureField("Password", text: $presenter.password)
                } else {
                    TextField("Password", text: $presenter.password)
                }
            }
            .textFieldStyle()
            Spacer()
            PrimaryButton(
                title: "Register",
                isLoading: presenter.isLoading,
                isEnabled: presenter.registrationEnabled
            ) {
                presenter.register()
            }
        }
        .padding(.horizontal, 20)
    }
    
    var biometricPromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: presenter.biometricType.systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Enable \(presenter.biometricType.displayName)?")
                .font(.title2)
                .bold()
            
            Text("Would you like to enable \(presenter.biometricType.displayName) for quick and secure access to your account?")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Button("Not Now") {
                    presenter.showBiometricPrompt = false
                }
                .buttonStyle(.bordered)
                
                Button("Enable") {
                    presenter.enableBiometricAuthentication()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
        .presentationDetents([.height(300)])
    }
    
    var faceIDButton: some View {
        Button(action: {
            presenter.authenticateWithBiometrics()
        }) {
            HStack {
                Image(systemName: presenter.biometricType.systemImageName)
                Text("Login with \(presenter.biometricType.displayName)")
            }.foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.blue)
        .cornerRadius(12)
        .frame(height: 48)
    }
}

struct AuthBaseView: ViewModifier {
    func body(content: Content) -> some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 20)
            Image(.buddyBudget)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 1.5)
                .padding(.horizontal, 20)
            Spacer().frame(height: 20)
            content
        }
        .background(Color(.accent))
    }
}

extension View {
    func authBaseView() -> some View {
        modifier(AuthBaseView())
    }
}
