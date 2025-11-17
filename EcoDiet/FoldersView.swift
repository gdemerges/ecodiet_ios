import SwiftUI
import SwiftData

struct FoldersView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    @State private var showingAddFolder = false
    @State private var newFolderTitle = ""
    @State private var selectedIconOption: FolderIconOption = FolderIconOption.allOptions[0]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder, dataManager: dataManager, profileManager: profileManager)
                    } label: {
                        HStack(spacing: 14) {
                            // Logo coloré
                            ZStack {
                                Circle()
                                    .fill(folder.color.gradient)
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: folder.imageName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(folder.title)
                                    .font(.body.weight(.medium))
                                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteFolder)
            }
            .navigationTitle("Mes dossiers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                createFolderSheet
            }
        }
    }
    
    private var createFolderSheet: some View {
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
                        addFolder()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Créer le dossier")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedIconOption.color.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: selectedIconOption.color.opacity(0.4), radius: 12, x: 0, y: 6)
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
                        showingAddFolder = false
                        resetForm()
                    }
                }
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
    
    private func addFolder() {
        let newFolder = RecipeFolder(
            title: newFolderTitle,
            imageName: selectedIconOption.systemImage,
            colorHex: selectedIconOption.colorHex
        )
        dataManager.addFolder(newFolder)
        showingAddFolder = false
        resetForm()
    }
    
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            if index < dataManager.folders.count {
                let folder = dataManager.folders[index]
                dataManager.deleteFolder(folder)
            }
        }
    }
    
    private func resetForm() {
        newFolderTitle = ""
        selectedIconOption = FolderIconOption.allOptions[0]
    }
}

#Preview {
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let profileManager = UserProfileManager()
    profileManager.configure(with: manager)
    return FoldersView(dataManager: manager, profileManager: profileManager)
}
