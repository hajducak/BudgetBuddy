import SwiftUI

extension View {
    @ViewBuilder
    func tap(count: Int = 1, perform: @escaping () -> Void) -> some View {
        contentShape(Rectangle())
            .onTapGesture(count: count, perform: perform)
    }
}
