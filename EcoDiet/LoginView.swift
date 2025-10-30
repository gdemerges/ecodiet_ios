import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    var onSignup: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("EcoDiet")
                    .font(.largeTitle).bold()
                Text("L'appli qui vous veux du bien")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                TextField("Email ou identifiant", text: $username)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("Mot de passe", text: $password)
                    .textContentType(.password)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
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
            .disabled(isLoading || username.isEmpty || password.isEmpty)

            Button {
                onSignup()
            } label: {
                Text("S’inscrire")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.accentColor)

            Spacer()
        }
        .padding(24)
    }

    private func login() {
        errorMessage = nil
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isLoading = false
            isAuthenticated = true
        }
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isAuth in
        LoginView(isAuthenticated: isAuth, onSignup: {})
            .padding()
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

