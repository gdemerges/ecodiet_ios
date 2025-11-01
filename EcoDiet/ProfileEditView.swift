import SwiftUI

struct ProfileEditView: View {
    @Bindable var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var selectedCookingLevel: CookingLevel = .beginner
    @State private var dietaryPreferences: [String] = []
    @State private var allergies: [String] = []
    @State private var newPreference: String = ""
    @State private var newAllergy: String = ""
    @State private var showingPreferenceAlert = false
    @State private var showingAllergyAlert = false
    
    let availableDietaryPreferences = [
        "Végétarien", "Végétalien", "Sans gluten", "Bio", "Local", 
        "Faible en sel", "Faible en sucre", "Keto", "Paleo"
    ]
    
    let commonAllergies = [
        "Fruits à coque", "Arachides", "Gluten", "Lactose", "Œufs", 
        "Poisson", "Crustacés", "Soja", "Sésame"
    ]
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    personalInformationSection
                    cookingLevelSection
                    dietaryPreferencesSection
                    allergiesSection
                    saveButton
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Modifier le profil")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadCurrentProfile()
        }
        .alert("Ajouter une préférence", isPresented: $showingPreferenceAlert) {
            TextField("Nouvelle préférence", text: $newPreference)
            Button("Ajouter") {
                if !newPreference.isEmpty && !dietaryPreferences.contains(newPreference) {
                    dietaryPreferences.append(newPreference)
                    newPreference = ""
                }
            }
            Button("Annuler", role: .cancel) {
                newPreference = ""
            }
        }
        .alert("Ajouter une allergie", isPresented: $showingAllergyAlert) {
            TextField("Nouvelle allergie", text: $newAllergy)
            Button("Ajouter") {
                if !newAllergy.isEmpty && !allergies.contains(newAllergy) {
                    allergies.append(newAllergy)
                    newAllergy = ""
                }
            }
            Button("Annuler", role: .cancel) {
                newAllergy = ""
            }
        }
    }
    
    // MARK: - View Components
    
    private var personalInformationSection: some View {
        ProfileEditSection(title: "Informations personnelles", icon: "person.fill") {
            VStack(spacing: 16) {
                CustomTextField(
                    title: "Nom complet",
                    text: $name,
                    icon: "person"
                )
                
                CustomTextField(
                    title: "Email",
                    text: $email,
                    icon: "envelope"
                )
            }
        }
    }
    
    private var cookingLevelSection: some View {
        ProfileEditSection(title: "Niveau de cuisine", icon: "chef.hat") {
            VStack(spacing: 8) {
                ForEach(CookingLevel.allCases, id: \.self) { level in
                    cookingLevelButton(for: level)
                }
            }
        }
    }
    
    private func cookingLevelButton(for level: CookingLevel) -> some View {
        Button {
            selectedCookingLevel = level
        } label: {
            HStack {
                Image(systemName: selectedCookingLevel == level ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(selectedCookingLevel == level ? .primary : .secondary)
                
                Text(level.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                if selectedCookingLevel == level {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dietaryPreferencesSection: some View {
        ProfileEditSection(title: "Préférences alimentaires", icon: "leaf.fill") {
            VStack(alignment: .leading, spacing: 12) {
                selectedPreferencesView
                availablePreferencesView
                addCustomPreferenceButton
            }
        }
    }
    
    @ViewBuilder
    private var selectedPreferencesView: some View {
        if !dietaryPreferences.isEmpty {
            FlowLayout(spacing: 8) {
                ForEach(dietaryPreferences, id: \.self) { preference in
                    TagView(
                        text: preference,
                        isSelected: true,
                        onTap: {
                            dietaryPreferences.removeAll { $0 == preference }
                        }
                    )
                }
            }
        }
    }
    
    private var availablePreferencesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ajouter des préférences :")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(availableDietaryPreferences.filter { !dietaryPreferences.contains($0) }, id: \.self) { preference in
                    TagView(
                        text: preference,
                        isSelected: false,
                        onTap: {
                            dietaryPreferences.append(preference)
                        }
                    )
                }
            }
        }
    }
    
    private var addCustomPreferenceButton: some View {
        Button {
            showingPreferenceAlert = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("Ajouter une préférence personnalisée")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private var allergiesSection: some View {
        ProfileEditSection(title: "Allergies et intolérances", icon: "exclamationmark.triangle.fill") {
            VStack(alignment: .leading, spacing: 12) {
                selectedAllergiesView
                commonAllergiesView
                addCustomAllergyButton
            }
        }
    }
    
    @ViewBuilder
    private var selectedAllergiesView: some View {
        if !allergies.isEmpty {
            FlowLayout(spacing: 8) {
                ForEach(allergies, id: \.self) { allergy in
                    TagView(
                        text: allergy,
                        isSelected: true,
                        color: .red,
                        onTap: {
                            allergies.removeAll { $0 == allergy }
                        }
                    )
                }
            }
        }
    }
    
    private var commonAllergiesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Allergies courantes :")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(commonAllergies.filter { !allergies.contains($0) }, id: \.self) { allergy in
                    TagView(
                        text: allergy,
                        isSelected: false,
                        color: .red,
                        onTap: {
                            allergies.append(allergy)
                        }
                    )
                }
            }
        }
    }
    
    private var addCustomAllergyButton: some View {
        Button {
            showingAllergyAlert = true
        } label: {
            HStack {
                Image(systemName: "plus.circle")
                Text("Ajouter une allergie personnalisée")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private var saveButton: some View {
        Button {
            saveProfile()
        } label: {
            Text("Sauvegarder les modifications")
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.primary, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Helper Methods
    
    private func loadCurrentProfile() {
        name = profileManager.userProfile.name
        email = profileManager.userProfile.email
        selectedCookingLevel = profileManager.userProfile.cookingLevel
        dietaryPreferences = profileManager.userProfile.dietaryPreferences
        allergies = profileManager.userProfile.allergies
    }
    
    private func saveProfile() {
        profileManager.updateProfile(
            name: name,
            email: email,
            cookingLevel: selectedCookingLevel,
            dietaryPreferences: dietaryPreferences,
            allergies: allergies
        )
        dismiss()
    }
}

struct ProfileEditSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack {
                content
            }
            .padding(20)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                TextField(title, text: $text)
                    .textFieldStyle(.plain)
                    .font(.body)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct TagView: View {
    let text: String
    var isSelected: Bool
    var color: Color = .blue
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.caption.weight(.medium))
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .foregroundStyle(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? color : color.opacity(0.15),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
}

struct FlowResult {
    var size: CGSize = .zero
    var positions: [CGPoint] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        self.size = CGSize(width: maxWidth, height: y + lineHeight)
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(profileManager: UserProfileManager())
    }
}