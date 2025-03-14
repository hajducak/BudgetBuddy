import SwiftUI

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 50)
            .background(Color.white.cornerRadius(8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(UIColor.systemGray6.color, lineWidth: 1)
            )
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
    func textFieldStyle() -> some View {
        modifier(CustomTextFieldStyle())
    }
    
    func authBaseView() -> some View {
        modifier(AuthBaseView())
    }
}
                 
extension UIColor {
    var color: Color {
        Color(self)
    }
}
