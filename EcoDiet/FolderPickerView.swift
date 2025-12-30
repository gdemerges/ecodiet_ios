import SwiftUI
import SwiftData

/// Vue permettant de sélectionner des dossiers pour y ajouter une recette
struct FolderPickerView: View {
    let recipe: Recipe
    let dataManager: SwiftDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewFolderSheet = false
    @State private var newFolderTitle = ""
    @State private var selectedIconOption: FolderIconOption = FolderIconOption.allOptions[0]
    @State private var selectedFolders: Set<RecipeFolder> = []
    @State private var hasChanges = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !dataManager.folders.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dossiers existants")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(dataManager.folders) { folder in
                                        Button {
                                            toggleFolder(folder)
                                        } label: {
                                            HStack(spacing: 14) {
                                                // Logo coloré
                                                ZStack {
                                                    Circle()
                                                        .fill(folder.color.gradient)
                                                        .frame(width: 50, height: 50)

                                                    Image(systemName: folder.imageName)
                                                        .font(.system(size: 22, weight: .semibold))
                                                        .foregroundStyle(.white)
                                                }

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(folder.title)
                                                        .font(.body.weight(.medium))
                                                        .foregroundStyle(.primary)

                                                    Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }

                                                Spacer()

                                                if selectedFolders.contains(folder) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(
                                                            LinearGradient(
                                                                colors: [
                                                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                                                    Color(red: 0.2, green: 0.6, blue: 0.5)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                } else {
                                                    Image(systemName: "circle")
                                                        .font(.title2)
                                                        .foregroundStyle(.tertiary)
                                                }
                                            }
                                            .padding(16)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(.ultraThinMaterial)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(
                                                        selectedFolders.contains(folder) ?
                                                        LinearGradient(
                                                            colors: [
                                                                Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.5),
                                                                Color(red: 0.2, green: 0.6, blue: 0.5).opacity(0.3)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ) :
                                                        LinearGradient(
                                                            colors: [.clear, .clear],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 2
                                                    )
                                            )
                                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Bouton créer un nouveau dossier
                        VStack(alignment: .leading, spacing: 12) {
                            if !dataManager.folders.isEmpty {
                                Text("Nouveau dossier")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                            }

                            Button {
                                showingNewFolderSheet = true
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                                        Color(red: 0.2, green: 0.6, blue: 0.5)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)

                                        Image(systemName: "plus")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Créer un nouveau dossier")
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)

                                        Text("Organiser vos recettes")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3),
                                                    Color(red: 0.2, green: 0.6, blue: 0.5).opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15), radius: 12, x: 0, y: 6)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, hasChanges ? 80 : 0)
                }

                // Bouton de validation fixe en bas
                if hasChanges {
                    VStack {
                        Spacer()

                        Button {
                            saveChanges()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))

                                Text("Valider la sélection")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.7, blue: 0.4),
                                        Color(red: 0.2, green: 0.6, blue: 0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Ajouter à un dossier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeSelection()
            }
            .sheet(isPresented: $showingNewFolderSheet) {
                NavigationStack {
                    ZStack {
                        AuthBackground().ignoresSafeArea()

                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Aperçu du dossier
                                VStack(spacing: 16) {
                                    Text("Aperçu")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIconOption.color.gradient)
                                                .frame(width: 56, height: 56)

                                            Image(systemName: selectedIconOption.systemImage)
                                                .font(.system(size: 26, weight: .semibold))
                                                .foregroundStyle(.white)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(newFolderTitle.isEmpty ? "Mon dossier" : newFolderTitle)
                                                .font(.title3.weight(.semibold))

                                            Text("0 recette")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)

                                // Nom du dossier
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Nom du dossier")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)

                                    TextField("Ex: Recettes d'été", text: $newFolderTitle)
                                        .textFieldStyle(.plain)
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(selectedIconOption.color.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal, 20)

                                // Sélection d'icône
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Choisir une icône")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)

                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)
                                    ], spacing: 12) {
                                        ForEach(FolderIconOption.allOptions) { option in
                                            iconButton(for: option)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                            }
                        }

                        // Bouton de création fixe en bas
                        VStack {
                            Spacer()

                            Button {
                                createFolderAndAdd()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 18, weight: .semibold))

                                    Text("Créer et ajouter")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.7, blue: 0.4),
                                            Color(red: 0.2, green: 0.6, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 12, x: 0, y: 6)
                            }
                            .disabled(newFolderTitle.isEmpty)
                            .opacity(newFolderTitle.isEmpty ? 0.5 : 1.0)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .navigationTitle("Nouveau dossier")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuler") {
                                showingNewFolderSheet = false
                                resetForm()
                            }
                        }
                    }
                }
                .presentationDetents([.large])
            }
        }
    }

    @ViewBuilder
    private func iconButton(for option: FolderIconOption) -> some View {
        let isSelected = selectedIconOption.id == option.id

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIconOption = option
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(option.color.gradient)
                        .frame(width: 50, height: 50)

                    Image(systemName: option.systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Text(option.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? option.color : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? option.color.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? option.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private func initializeSelection() {
        // Initialiser la sélection avec les dossiers qui contiennent déjà la recette
        selectedFolders = Set(dataManager.folders.filter { $0.recipes.contains(recipe) })
    }

    private func toggleFolder(_ folder: RecipeFolder) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedFolders.contains(folder) {
                selectedFolders.remove(folder)
            } else {
                selectedFolders.insert(folder)
            }
            hasChanges = true
        }
    }

    private func saveChanges() {
        // Parcourir tous les dossiers
        for folder in dataManager.folders {
            let isSelected = selectedFolders.contains(folder)
            let containsRecipe = folder.recipes.contains(recipe)

            if isSelected && !containsRecipe {
                // Ajouter la recette au dossier
                dataManager.addRecipe(recipe, to: folder)
            } else if !isSelected && containsRecipe {
                // Retirer la recette du dossier
                dataManager.removeRecipe(recipe, from: folder)
            }
        }

        dismiss()
    }

    private func createFolderAndAdd() {
        let newFolder = RecipeFolder(
            title: newFolderTitle,
            imageName: selectedIconOption.systemImage,
            colorHex: selectedIconOption.colorHex
        )
        dataManager.addFolder(newFolder)
        dataManager.addRecipe(recipe, to: newFolder)

        showingNewFolderSheet = false
        resetForm()
        dismiss()
    }

    private func resetForm() {
        newFolderTitle = ""
        selectedIconOption = FolderIconOption.allOptions[0]
    }

    // Couleur basée sur l'icône du dossier (même logique que CompactFolderButton)
    private func folderColor(for folder: RecipeFolder) -> Color {
        switch folder.imageName {
        case "figure.run", "bolt.fill":
            return Color(red: 0.95, green: 0.5, blue: 0.2) // Orange sport
        case "snowflake", "drop.fill":
            return Color(red: 0.3, green: 0.6, blue: 0.9) // Bleu hiver
        case "leaf.fill", "leaf", "leaf.circle":
            return Color(red: 0.4, green: 0.7, blue: 0.4) // Vert nature
        case "flame", "sun.max":
            return Color(red: 0.95, green: 0.4, blue: 0.2) // Orange/rouge feu
        case "moon.stars":
            return Color(red: 0.5, green: 0.4, blue: 0.7) // Violet nuit
        case "heart.fill", "heart":
            return Color(red: 0.9, green: 0.3, blue: 0.4) // Rose/rouge
        case "star.fill", "star":
            return Color(red: 0.95, green: 0.7, blue: 0.2) // Jaune doré
        default:
            return Color(red: 0.4, green: 0.7, blue: 0.4) // Vert par défaut
        }
    }
}
