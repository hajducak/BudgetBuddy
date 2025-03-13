import SwiftUI

struct OnboardingView: View {
    @ObservedObject var presenter: OnboardingPresenter
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            walletSelectionView
                .tag(0)
            categorySelectionView
                .tag(1)
        }
        .toast($presenter.toast, timeout: 3)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(Color(.accent))
    }
    
    var walletSelectionView: some View {
        VStack(alignment: .leading,  spacing: 16) {
            Text("Setup your wallet:")
                .font(.headline)
            TextField("Balance", text: $presenter.balance)
                .keyboardType(.numberPad)
                .textFieldStyle()
            TextField("Currency", text: $presenter.currency)
                .textFieldStyle()
            Spacer()
            PrimaryButton(title: "Next", isLoading: false, isEnabled: true) {
                withAnimation {
                    selectedTab = 1
                }
            }
        }
        .authBaseView()
        .padding(.horizontal, 20)
    }
    
    var categorySelectionView: some View {
        VStack(alignment: .leading,  spacing: 16) {
            Text("Select Categories you want to use:")
                .font(.headline)
                .padding(.horizontal, 20)
            Text("Expenses")
                .font(.headline)
            ScrollView {
                ForEach(presenter.defaultCategories.filter { $0.type == .expense }, id: \.id) { category in
                    ChoosableCategoryView(presenter: presenter, category: category)
                }
            }
            Text("Incomes")
                .font(.headline)
            ScrollView {
                ForEach(presenter.defaultCategories.filter { $0.type == .income }, id: \.id) { category in
                    ChoosableCategoryView(presenter: presenter, category: category)
                }
            }
            Spacer()
            PrimaryButton(title: "Finish", isLoading: presenter.onbaordingIsLoading, isEnabled: presenter.isFinishOnbaordingEnabled) {
                presenter.completeOnboarding()
            }.padding(.horizontal, 20)
        }.authBaseView()
    }
}

struct ChoosableCategoryView: View {
    @ObservedObject var presenter: OnboardingPresenter
    var category: Category

    var body: some View {
        HStack {
            if presenter.selectedCategories.contains(where: { $0.id == category.id }) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
            } else {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 18, height: 18)
                }
            }
            Text(category.name).lineLimit(1)
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 20)
        .tap {
            presenter.toggleCategorySelection(category)
        }
    }
}
