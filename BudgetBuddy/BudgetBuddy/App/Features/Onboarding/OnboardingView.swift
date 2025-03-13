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
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text("Select Categories you want to use:")
                .font(.headline)
                .padding(.horizontal, 20)
            VStack(alignment: .leading, spacing: 10) {
                Text("Expenses")
                    .font(.headline)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(presenter.defaultCategories.filter { $0.type == .expense }, id: \.id) { category in
                        ChoosableCategoryView(presenter: presenter, category: category)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Incomes")
                    .font(.headline)
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(presenter.defaultCategories.filter { $0.type == .income }, id: \.id) { category in
                        ChoosableCategoryView(presenter: presenter, category: category)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            PrimaryButton(
                title: "Finish",
                isLoading: presenter.onbaordingIsLoading,
                isEnabled: presenter.isFinishOnbaordingEnabled
            ) {
                presenter.completeOnboarding()
            }
            .padding(.horizontal, 20)
            Spacer().frame(height: 25)
        }
    }
}

struct ChoosableCategoryView: View {
    @ObservedObject var presenter: OnboardingPresenter
    var category: Category

    var body: some View {
        let selected = presenter.selectedCategories.contains(where: { $0.id == category.id })
        HStack(spacing: 8) {
            Text(category.name)
                .lineLimit(1)
                .padding(8)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(selected ? .white : .primary)
            Spacer(minLength: 0)
        }
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(selected ? Color(.blue) : Color(.systemBackground).opacity(0.8))
        )
        .tap {
            presenter.toggleCategorySelection(category)
        }
    }
}
