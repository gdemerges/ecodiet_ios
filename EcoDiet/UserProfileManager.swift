//
//  UserProfileManager.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import Foundation
import SwiftData

/// Gestionnaire du profil utilisateur
/// Fait le pont entre l'authentification et SwiftData
@Observable
class UserProfileManager {
    
    private(set) var userProfile: UserProfile?
    private var dataManager: SwiftDataManager?
    
    /// Configure le manager avec un SwiftDataManager
    func configure(with manager: SwiftDataManager) {
        self.dataManager = manager
    }
    
    /// Charge ou crée un profil depuis les credentials hardcodées
    func loadOrCreateProfile(from credentials: HardcodedProfiles.UserCredentials) {
        guard let dataManager = dataManager else {
            print("⚠️ DataManager non configuré")
            return
        }
        
        // Convertir les données hardcodées en UserProfile
        let profile = credentials.profile.toUserProfile()
        
        // Sauvegarder dans SwiftData
        dataManager.createProfile(profile)
        
        // Définir comme profil actuel
        self.userProfile = profile
        
        print("✅ Profil chargé: \(profile.name)")
    }
    
    /// Crée un profil depuis le signup
    func createProfileFromSignup(email: String, password: String, profile: UserProfile) {
        guard let dataManager = dataManager else {
            print("⚠️ DataManager non configuré")
            return
        }
        
        // Sauvegarder dans SwiftData
        dataManager.createProfile(profile)
        
        // Définir comme profil actuel
        self.userProfile = profile
        
        print("✅ Nouveau profil créé: \(profile.name)")
    }
    
    /// Déconnecte l'utilisateur et nettoie le profil
    func logout() {
        userProfile = nil
        print("🔓 Utilisateur déconnecté")
    }
    
    /// Met à jour le profil utilisateur
    func updateProfile(_ profile: UserProfile) {
        guard let dataManager = dataManager else {
            print("⚠️ DataManager non configuré")
            return
        }
        
        dataManager.updateProfile(profile)
        self.userProfile = profile
        
        print("✅ Profil mis à jour: \(profile.name)")
    }
    
    /// Vérifie si une recette est dans les favoris
    func isFavorite(_ recipe: Recipe) -> Bool {
        guard let profile = userProfile else { return false }
        return profile.favoriteRecipes.contains(recipe)
    }
    
    /// Ajoute une recette aux favoris
    func addFavoriteRecipe(_ recipe: Recipe) {
        guard let profile = userProfile else {
            print("⚠️ Aucun profil actif")
            return
        }
        
        // Vérifier si la recette n'est pas déjà dans les favoris
        guard !profile.favoriteRecipes.contains(recipe) else {
            print("ℹ️ Recette déjà dans les favoris")
            return
        }
        
        profile.favoriteRecipes.append(recipe)
        
        // Sauvegarder
        dataManager?.updateProfile(profile)
        
        print("✅ Recette ajoutée aux favoris: \(recipe.title)")
    }
    
    /// Retire une recette des favoris
    func removeFavoriteRecipe(_ recipe: Recipe) {
        guard let profile = userProfile else {
            print("⚠️ Aucun profil actif")
            return
        }
        
        profile.favoriteRecipes.removeAll { $0 == recipe }
        
        // Sauvegarder
        dataManager?.updateProfile(profile)
        
        print("✅ Recette retirée des favoris: \(recipe.title)")
    }
}

// MARK: - Extension pour SwiftDataManager
extension SwiftDataManager {
    
    /// Crée ou met à jour un profil
    func createProfile(_ profile: UserProfile) {
        modelContext.insert(profile)
        try? modelContext.save()
    }
    
    /// Met à jour un profil existant
    func updateProfile(_ profile: UserProfile) {
        try? modelContext.save()
    }
}
