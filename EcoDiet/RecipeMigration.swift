import SwiftData
import Foundation

// MARK: - Migration Helper pour Recipe

/// Ce fichier aide à migrer le modèle Recipe existant pour ajouter les nouveaux champs
/// nécessaires à l'intégration PostgreSQL

/// Instructions de migration :
///
/// 1. Si vous obtenez une erreur "Model has incompatible schema"
/// 2. Vous avez deux options :

// OPTION 1 : Migration automatique (Recommandé pour développement)
// SwiftData tentera de migrer automatiquement en ajoutant les nouveaux champs
// Les données existantes seront préservées

// OPTION 2 : Réinitialisation complète (Si problèmes)
/*
 1. Supprimer l'app du simulateur/appareil
 2. Clean Build Folder (Cmd+Shift+K)
 3. Rebuild
 
 ⚠️ ATTENTION : Cela supprimera toutes les données de l'app
*/

// OPTION 3 : Migration personnalisée (Production)
enum RecipeV1toV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [RecipeV1.self]
    }
    
    @Model
    final class RecipeV1 {
        var id: UUID
        var title: String
        var subtitle: String
        var imageName: String
        var timestamp: Date
        var carbonFootprint: Double
        var preparationTime: Int
        var dietaryTags: [String]
        var allergens: [String]
        var ingredientsData: Data?
        
        init(id: UUID, title: String, subtitle: String, imageName: String, 
             timestamp: Date, carbonFootprint: Double, preparationTime: Int,
             dietaryTags: [String], allergens: [String], ingredientsData: Data?) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.imageName = imageName
            self.timestamp = timestamp
            self.carbonFootprint = carbonFootprint
            self.preparationTime = preparationTime
            self.dietaryTags = dietaryTags
            self.allergens = allergens
            self.ingredientsData = ingredientsData
        }
    }
}

enum RecipeV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [RecipeV2.self]
    }
    
    @Model
    final class RecipeV2 {
        var id: UUID
        var title: String
        var subtitle: String
        var imageName: String
        var timestamp: Date
        var carbonFootprint: Double
        var preparationTime: Int
        var dietaryTags: [String]
        var allergens: [String]
        var ingredientsData: Data?
        
        // Nouveaux champs pour PostgreSQL
        var ustensiles: [String]
        var etapes: [String]
        var sourceURL: String?
        
        init(id: UUID, title: String, subtitle: String, imageName: String,
             timestamp: Date, carbonFootprint: Double, preparationTime: Int,
             dietaryTags: [String], allergens: [String], ingredientsData: Data?,
             ustensiles: [String] = [], etapes: [String] = [], sourceURL: String? = nil) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.imageName = imageName
            self.timestamp = timestamp
            self.carbonFootprint = carbonFootprint
            self.preparationTime = preparationTime
            self.dietaryTags = dietaryTags
            self.allergens = allergens
            self.ingredientsData = ingredientsData
            self.ustensiles = ustensiles
            self.etapes = etapes
            self.sourceURL = sourceURL
        }
    }
}

// Plan de migration
enum RecipeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [RecipeV1toV2.self, RecipeV2.self]
    }
    
    static var stages: [MigrationStage] {
        [
            migrateV1toV2
        ]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: RecipeV1toV2.self,
        toVersion: RecipeV2.self,
        willMigrate: { context in
            // Avant la migration
            print("🔄 Début de la migration Recipe V1 → V2")
        },
        didMigrate: { context in
            // Après la migration
            print("✅ Migration Recipe V1 → V2 terminée")
            
            // Optionnel : Initialiser les nouveaux champs avec des valeurs par défaut
            let recipes = try? context.fetch(FetchDescriptor<RecipeV2.RecipeV2>())
            recipes?.forEach { recipe in
                if recipe.ustensiles.isEmpty {
                    recipe.ustensiles = []
                }
                if recipe.etapes.isEmpty {
                    recipe.etapes = []
                }
                if recipe.sourceURL == nil {
                    recipe.sourceURL = nil
                }
            }
            
            try? context.save()
        }
    )
}

// MARK: - Utilisation dans l'app

/// Pour activer la migration, modifiez votre ModelContainer dans l'app :

/*
 // AVANT (sans migration)
 let container = try ModelContainer(
     for: Recipe.self,
     configurations: ModelConfiguration(isStoredInMemoryOnly: false)
 )
 
 // APRÈS (avec migration)
 let container = try ModelContainer(
     for: Recipe.self,
     migrationPlan: RecipeMigrationPlan.self
 )
*/

// MARK: - Vérification de la migration

@MainActor
class MigrationVerifier {
    static func verifyMigration(modelContext: ModelContext) async {
        print("🔍 Vérification de la migration...")
        
        do {
            let descriptor = FetchDescriptor<Recipe>()
            let recipes = try modelContext.fetch(descriptor)
            
            print("📊 Nombre de recettes : \(recipes.count)")
            
            let recettesAvecUstensiles = recipes.filter { !$0.ustensiles.isEmpty }
            print("🔪 Recettes avec ustensiles : \(recettesAvecUstensiles.count)")
            
            let recettesAvecEtapes = recipes.filter { !$0.etapes.isEmpty }
            print("📝 Recettes avec étapes : \(recettesAvecEtapes.count)")
            
            let recettesAvecSource = recipes.filter { $0.sourceURL != nil }
            print("🔗 Recettes avec URL source : \(recettesAvecSource.count)")
            
            print("✅ Vérification terminée")
        } catch {
            print("❌ Erreur lors de la vérification : \(error)")
        }
    }
}

// MARK: - Notes importantes

/*
 ⚠️ ATTENTION :
 
 1. SwiftData gère automatiquement les migrations simples (ajout de champs)
 2. Si vous renommez ou supprimez des champs, utilisez un MigrationPlan
 3. En développement, la méthode la plus simple est de réinstaller l'app
 4. En production, TOUJOURS tester la migration sur des données de test d'abord
 
 📝 Checklist de migration :
 
 □ Sauvegarder les données existantes si nécessaire
 □ Tester la migration sur un simulateur avec données de test
 □ Vérifier que toutes les recettes sont accessibles après migration
 □ Tester l'import de nouvelles recettes depuis PostgreSQL
 □ Vérifier que les relations (folders, userProfiles) fonctionnent
 
 🐛 En cas de problème :
 
 1. Consulter la console pour les erreurs SwiftData
 2. Vérifier que les types de données correspondent
 3. S'assurer que les valeurs par défaut sont définies
 4. En dernier recours : réinstaller l'app (développement uniquement)
*/

// MARK: - Tests de migration

#if DEBUG
extension MigrationVerifier {
    /// Crée une recette de test pour vérifier la migration
    static func createTestRecipe(modelContext: ModelContext) {
        let testRecipe = Recipe(
            title: "Test PostgreSQL",
            subtitle: "Recette de test",
            imageName: "fork.knife",
            carbonFootprint: 500,
            preparationTime: 30,
            dietaryTags: ["Test"],
            allergens: [],
            requiredIngredients: [
                RecipeIngredient(name: "Test", quantity: 1, unit: "pièce")
            ],
            ustensiles: ["Four", "Casserole"],
            etapes: [
                "Étape 1 de test",
                "Étape 2 de test"
            ],
            sourceURL: "https://example.com/test"
        )
        
        modelContext.insert(testRecipe)
        
        do {
            try modelContext.save()
            print("✅ Recette de test créée avec succès")
        } catch {
            print("❌ Erreur création recette de test : \(error)")
        }
    }
}
#endif
