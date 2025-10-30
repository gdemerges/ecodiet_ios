import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
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

                Spacer()
            }
            .padding(24)
        }
    }

    private func login() {
        errorMessage = nil
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        // Simulation d'authentification asynchrone
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoading = false
            isAuthenticated = true
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isAuth in
        LoginView(isAuthenticated: isAuth, onSignup: {})
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

struct AuthBackground: View {
    private let top = Color(hue: 0.33, saturation: 0.25, brightness: 0.98)
    private let bottom = Color(hue: 0.33, saturation: 0.10, brightness: 0.92)
    private let accent = Color(hue: 0.33, saturation: 0.55, brightness: 0.72)

    var body: some View {
        ZStack {
            LinearGradient(colors: [top, bottom], startPoint: .topLeading, endPoint: .bottomTrailing)

            // subtle decorative circles
            Circle()
                .fill(accent.opacity(0.15))
                .frame(width: 280, height: 280)
                .blur(radius: 40)
                .offset(x: -120, y: -240)

            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 36)
                .offset(x: 140, y: 180)

            Circle()
                .strokeBorder(accent.opacity(0.18), lineWidth: 2)
                .frame(width: 420, height: 420)
                .blur(radius: 2)
                .offset(x: 80, y: -60)
        }
    }
}
