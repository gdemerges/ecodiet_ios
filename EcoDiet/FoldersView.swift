import SwiftUI
import SwiftData

struct FoldersView: View {
    let dataManager: SwiftDataManager
    @State private var showingAddFolder = false
    @State private var newFolderTitle = ""
    @State private var selectedIcon = "folder"
    
    private let availableIcons = [
        "folder", "folder.fill", "figure.run", "snowflake", "leaf.fill",
        "flame", "moon.stars", "sun.max", "heart.fill", "star.fill"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder, dataManager: dataManager)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: folder.imageName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(folder.title)
                                    .font(.body)
                                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
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
                NavigationStack {
                    Form {
                        Section("Informations du dossier") {
                            TextField("Nom du dossier", text: $newFolderTitle)
                            
                            Picker("Icône", selection: $selectedIcon) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    HStack {
                                        Image(systemName: icon)
                                        Text(icon)
                                    }
                                    .tag(icon)
                                }
                            }
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
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Créer") {
                                addFolder()
                            }
                            .disabled(newFolderTitle.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func addFolder() {
        let newFolder = RecipeFolder(
            title: newFolderTitle,
            imageName: selectedIcon
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
        selectedIcon = "folder"
    }
}

#Preview {
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    return FoldersView(dataManager: manager)
}
