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

extension View {
    func textFieldStyle() -> some View {
        modifier(CustomTextFieldStyle())
    }
}
                 
extension UIColor {
    var color: Color {
        Color(self)
    }
}
