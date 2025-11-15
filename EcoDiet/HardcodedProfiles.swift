//
//  HardcodedProfiles.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import Foundation

/// Profils utilisateur hardcodés temporaires
/// TODO: Migrer vers PostgreSQL
struct HardcodedProfiles {
    
    // MARK: - Structure pour les credentials
    struct UserCredentials {
        let email: String
        let password: String
        let profile: UserProfileData
    }
    
    struct UserProfileData {
        let name: String
        let age: Int
        let height: Double // en cm
        let weight: Double // en kg
        let activityLevel: ActivityLevel
        let dietaryPreferences: [String]
        let allergies: [String]
        let healthGoals: [String]
    }
    
    enum ActivityLevel: String {
        case sedentary = "Sédentaire"
        case light = "Légère"
        case moderate = "Modérée"
        case active = "Active"
        case veryActive = "Très active"
    }
    
    // MARK: - Profils prédéfinis
    static let profiles: [UserCredentials] = [
        // Profil 1 - Utilisateur standard
        UserCredentials(
            email: "demo@ecodiet.com",
            password: "demo123",
            profile: UserProfileData(
                name: "Utilisateur Demo",
                age: 30,
                height: 170,
                weight: 70,
                activityLevel: .moderate,
                dietaryPreferences: ["Équilibré", "Bio"],
                allergies: [],
                healthGoals: ["Manger sainement", "Réduire le gaspillage"]
            )
        ),
        
        // Profil 2 - Utilisateur végétarien
        UserCredentials(
            email: "veggie@ecodiet.com",
            password: "veggie123",
            profile: UserProfileData(
                name: "Marie Végétarienne",
                age: 28,
                height: 165,
                weight: 60,
                activityLevel: .active,
                dietaryPreferences: ["Végétarien", "Sans lactose"],
                allergies: ["Lactose"],
                healthGoals: ["Manger végétarien", "Perdre du poids"]
            )
        ),
        
        // Profil 3 - Utilisateur sportif
        UserCredentials(
            email: "sport@ecodiet.com",
            password: "sport123",
            profile: UserProfileData(
                name: "Jean Sportif",
                age: 35,
                height: 180,
                weight: 85,
                activityLevel: .veryActive,
                dietaryPreferences: ["Riche en protéines", "Faible en glucides"],
                allergies: [],
                healthGoals: ["Prendre du muscle", "Améliorer les performances"]
            )
        ),
        
        // Profil 4 - Utilisateur avec allergies
        UserCredentials(
            email: "allergic@ecodiet.com",
            password: "allergic123",
            profile: UserProfileData(
                name: "Sophie Allergique",
                age: 25,
                height: 160,
                weight: 55,
                activityLevel: .light,
                dietaryPreferences: ["Sans gluten", "Sans lactose"],
                allergies: ["Gluten", "Lactose", "Arachides"],
                healthGoals: ["Éviter les allergènes", "Manger sainement"]
            )
        ),
        
        // Profil 5 - Utilisateur vegan
        UserCredentials(
            email: "vegan@ecodiet.com",
            password: "vegan123",
            profile: UserProfileData(
                name: "Paul Vegan",
                age: 32,
                height: 175,
                weight: 72,
                activityLevel: .moderate,
                dietaryPreferences: ["Vegan", "Bio", "Local"],
                allergies: [],
                healthGoals: ["Manger vegan", "Réduire l'impact écologique"]
            )
        )
    ]
    
    // MARK: - Méthodes utilitaires
    
    /// Vérifie si les credentials correspondent à un profil hardcodé
    static func authenticate(email: String, password: String) -> UserCredentials? {
        return profiles.first { profile in
            profile.email.lowercased() == email.lowercased() && 
            profile.password == password
        }
    }
    
    /// Vérifie si un email existe déjà
    static func emailExists(_ email: String) -> Bool {
        return profiles.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    /// Liste tous les emails disponibles (pour debug/test)
    static func listAvailableEmails() -> [String] {
        return profiles.map { $0.email }
    }
    
    /// Retourne un profil par défaut pour les tests
    static var defaultProfile: UserCredentials {
        return profiles.first!
    }
}

// MARK: - Extension pour convertir en UserProfile SwiftData
extension HardcodedProfiles.UserProfileData {
    
    /// Convertit les données hardcodées en UserProfile pour SwiftData
    func toUserProfile() -> UserProfile {
        let profile = UserProfile(name: name)
        profile.age = age
        profile.height = height
        profile.weight = weight
        profile.activityLevel = activityLevel.rawValue
        profile.dietaryPreferences = dietaryPreferences
        profile.allergies = allergies
        profile.healthGoals = healthGoals
        return profile
    }
}
