import SwiftUI

struct UserPreferences {
    var isVegetarian: Bool
    var isVegan: Bool
    var isGlutenFree: Bool
    var isLactoseFree: Bool
}

struct SignupFlowView: View {
    enum Step { case credentials, preferences }

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .credentials
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var isVegetarian: Bool = false
    @State private var isVegan: Bool = false
    @State private var isGlutenFree: Bool = false
    @State private var isLactoseFree: Bool = false

    var onComplete: (String, String, UserPreferences) -> Void

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .credentials:
                    credentialsView
                case .preferences:
                    preferencesView
                }
            }
            .navigationTitle(step == .credentials ? "Inscription" : "Préférences alimentaires")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    private var credentialsView: some View {
        Form {
            Section(header: Text("Informations de connexion")) {
                TextField("Adresse e-mail", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                SecureField("Mot de passe", text: $password)
                    .textContentType(.newPassword)
            }

            Section {
                Button {
                    withAnimation { step = .preferences }
                } label: {
                    Text("Continuer")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!isCredentialsValid)
            }
        }
    }

    private var preferencesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Régimes alimentaires")
                    .font(.headline)
                    .padding(.horizontal)

                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]

                LazyVGrid(columns: columns, spacing: 16) {
                    preferenceCard(title: "Végétarien", systemImage: "leaf", isOn: $isVegetarian)
                    preferenceCard(title: "Végan", systemImage: "leaf.circle", isOn: $isVegan)
                    preferenceCard(title: "Sans gluten", systemImage: "wheat.slash", isOn: $isGlutenFree)
                    preferenceCard(title: "Sans lactose", systemImage: "drop.triangle", isOn: $isLactoseFree)
                }
                .padding(.horizontal)

                VStack {
                    Button {
                        let prefs = UserPreferences(
                            isVegetarian: isVegetarian,
                            isVegan: isVegan,
                            isGlutenFree: isGlutenFree,
                            isLactoseFree: isLactoseFree
                        )
                        onComplete(email, password, prefs)
                        dismiss()
                    } label: {
                        Text("Créer le compte")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func preferenceCard(title: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        let selected = isOn.wrappedValue
        Button(action: { isOn.wrappedValue.toggle() }) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(selected ? Color.white : Color.accentColor)
                    .frame(height: 32)
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? Color.accentColor : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .animation(.easeInOut(duration: 0.15), value: selected)
        }
        .buttonStyle(.plain)
    }

    private var isCredentialsValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
}

#Preview {
    SignupFlowView { email, password, prefs in
        print(email, password, prefs)
    }
}
