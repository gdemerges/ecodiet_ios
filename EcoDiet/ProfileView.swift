import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.primary)
                Text("Profil utilisateur")
                    .font(.title2.weight(.semibold))
                Text("À personnaliser : infos, préférences, etc.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
