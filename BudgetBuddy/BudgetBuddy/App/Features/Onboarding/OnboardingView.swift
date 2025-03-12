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
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Image(.buddyBudget)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 1.5)
                .padding(.horizontal, 20)
            Spacer()
            Text("Setup your wallet:")
                .font(.title2)
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
            Spacer().frame(height: 40)
        }.padding(.horizontal, 20)
    }
    
    var categorySelectionView: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(.buddyBudget)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 1.5)
                .padding(.horizontal, 20)
            Text("Select Categories you want to use:")
                .font(.title2)
                .padding(.horizontal, 20)
            ScrollView {
                Text("Expenses")
                    .font(.headline)
                ForEach(presenter.defaultCategories.filter { $0.type == .expense }, id: \.id) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        if presenter.selectedCategories.contains(where: { $0.id == category.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                    .tap {
                        presenter.toggleCategorySelection(category)
                    }
                }
                Text("Incomes")
                    .font(.headline)
                ForEach(presenter.defaultCategories.filter { $0.type == .income }, id: \.id) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        if presenter.selectedCategories.contains(where: { $0.id == category.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                    .tap {
                        presenter.toggleCategorySelection(category)
                    }
                }
            }
            PrimaryButton(title: "Finish", isLoading: presenter.onbaordingIsLoading, isEnabled: presenter.isFinishOnbaordingEnabled) {
                presenter.completeOnboarding()
            }.padding(.horizontal, 20)
            Spacer().frame(height: 40)
        }
    }

}
