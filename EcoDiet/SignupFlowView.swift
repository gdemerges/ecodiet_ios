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

    private let primaryGreen = Color(hue: 0.33, saturation: 0.65, brightness: 0.55)
    private let leafGreen = Color(hue: 0.33, saturation: 0.55, brightness: 0.72)
    private let citrus = Color(hue: 0.15, saturation: 0.85, brightness: 0.95)

    var body: some View {
        ZStack {
            AuthBackground()
                .ignoresSafeArea()

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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(step == .credentials ? "Inscription" : "Préférences alimentaires")
                            .font(.title2.weight(.semibold))
                            .kerning(0.5)
                            .foregroundStyle(primaryGreen)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { dismiss() }
                    }
                }
            }
        }
    }

    private var credentialsView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Informations de connexion")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill").foregroundStyle(leafGreen)
                        TextField("Adresse e-mail", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(leafGreen.opacity(0.15), lineWidth: 1))

                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill").foregroundStyle(leafGreen)
                        SecureField("Mot de passe", text: $password)
                            .textContentType(.newPassword)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(leafGreen.opacity(0.15), lineWidth: 1))
                }
            }
            .padding(18)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)

            Button {
                withAnimation { step = .preferences }
            } label: {
                Text("Continuer")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(primaryGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(!isCredentialsValid)
        }
        .padding()
    }

    private var preferencesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Régimes alimentaires")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

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
                            .padding(.vertical, 12)
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                    .foregroundStyle(selected ? Color.white : leafGreen)
                    .frame(height: 32)
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(selected ? AnyShapeStyle(primaryGreen) : AnyShapeStyle(.ultraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? primaryGreen.opacity(0.9) : leafGreen.opacity(0.15), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
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
