import SwiftUI

struct LoginView: View {
    let authManager: AuthenticationManager
    let profileManager: UserProfileManager
    @Binding var isAuthenticated: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showTestAccounts: Bool = false
    var onSignup: () -> Void = {}

    private let primaryGreen = Color(hue: 0.33, saturation: 0.65, brightness: 0.55)
    private let leafGreen = Color(hue: 0.33, saturation: 0.55, brightness: 0.72)
    private let citrus = Color(hue: 0.15, saturation: 0.85, brightness: 0.95)
    private let tomato = Color(hue: 0.01, saturation: 0.80, brightness: 0.90)

    var body: some View {
        ZStack {
            AuthBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 12)

                // Header with logo
                VStack(spacing: 10) {
                    Group {
                        if UIImage(named: "EcoDietLogo") != nil {
                            Image("EcoDietLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 88, height: 88)
                                .shadow(color: primaryGreen.opacity(0.2), radius: 10, x: 0, y: 8)
                        } else {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60, weight: .semibold))
                                .foregroundStyle(leafGreen)
                                .symbolRenderingMode(.palette)
                                .shadow(color: primaryGreen.opacity(0.25), radius: 8, x: 0, y: 6)
                        }
                    }

                    Text("EcoDiet")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.primary)
                    Text("L'appli qui vous veux du bien")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Card container for inputs
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(leafGreen)
                        TextField("Email ou identifiant", text: $username)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(leafGreen.opacity(0.15), lineWidth: 1)
                    )

                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(leafGreen)
                        SecureField("Mot de passe", text: $password)
                            .textContentType(.password)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(leafGreen.opacity(0.15), lineWidth: 1)
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: login) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text("Se connecter").bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(primaryGreen)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: primaryGreen.opacity(0.22), radius: 12, x: 0, y: 8)
                    .disabled(isLoading || username.isEmpty || password.isEmpty)

                    Button { onSignup() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                            Text("S’inscrire")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(leafGreen)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)

                // Section comptes de test
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        showTestAccounts.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: showTestAccounts ? "eye.slash" : "eye")
                            .font(.caption)
                        Text(showTestAccounts ? "Masquer les comptes de test" : "Comptes de test")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                
                if showTestAccounts {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comptes de test disponibles")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        ForEach(HardcodedProfiles.profiles, id: \.email) { testProfile in
                            Button {
                                username = testProfile.email
                                password = testProfile.password
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(testProfile.profile.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        Text(testProfile.email)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        if !testProfile.profile.dietaryPreferences.isEmpty {
                                            Text(testProfile.profile.dietaryPreferences.joined(separator: ", "))
                                                .font(.caption2)
                                                .foregroundStyle(.tertiary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundStyle(leafGreen)
                                }
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(leafGreen.opacity(0.15), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.caption2)
                            Text("Ces comptes sont temporaires en attendant PostgreSQL")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
            .padding(24)
        }
    }

    private func login() {
        errorMessage = nil
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        
        // Authentification réelle via AuthenticationManager
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = authManager.login(email: username, password: password)
            
            switch result {
            case .success(let userCredentials):
                // Charger le profil utilisateur dans SwiftData
                profileManager.loadOrCreateProfile(from: userCredentials)
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAuthenticated = true
                }
            case .failure(let error):
                errorMessage = error.errorDescription
            }
            
            isLoading = false
        }
    }
}

#Preview {
    let authManager = AuthenticationManager()
    let profileManager = UserProfileManager()
    return StatefulPreviewWrapper(false) { isAuth in
        LoginView(authManager: authManager, profileManager: profileManager, isAuthenticated: isAuth, onSignup: {})
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View { content($value) }
}
