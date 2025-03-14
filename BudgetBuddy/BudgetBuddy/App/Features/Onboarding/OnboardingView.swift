import SwiftUI

struct OnboardingView: View {
    @ObservedObject var presenter: OnboardingPresenter
    @State private var selectedTab = 0
    @FocusState private var isBalanceFieldFocused: Bool
    @FocusState private var isCurrencyFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading,  spacing: 8) {
            ScrollView {
                VStack(alignment: .leading,  spacing: 8) {
                    Text("Onboarding")
                        .font(.largeTitle).bold()
                    Text("Setup your wallet:")
                        .font(.headline)
                    TextField("Balance", text: $presenter.balance)
                        .keyboardType(.numberPad)
                        .textFieldStyle()
                        .focused($isBalanceFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                if isBalanceFieldFocused {
                                    Spacer()
                                    Button("Done") {
                                        isBalanceFieldFocused = false
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    TextField("Currency", text: $presenter.currency)
                        .textFieldStyle()
                        .focused($isCurrencyFieldFocused)
                }
                categorySelectionView
            }
            Spacer()
            PrimaryButton(
                title: "Finish",
                isLoading: presenter.onbaordingIsLoading,
                isEnabled: presenter.isFinishOnbaordingEnabled
            ) {
                presenter.completeOnboarding()
            }
        }
        .padding(.horizontal, 20)
        .toast($presenter.toast, timeout: 3)
        .background(Color(.accent))
    }
    
    var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Categories you want to use:")
                .font(.headline)
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
                    ForEach(Category.predefinedCategories.filter { $0.type == .expense }, id: \.id) { category in
                        ChoosableCategoryView(presenter: presenter, category: category)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
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
                    ForEach(Category.predefinedCategories.filter { $0.type == .income }, id: \.id) { category in
                        ChoosableCategoryView(presenter: presenter, category: category)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
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
