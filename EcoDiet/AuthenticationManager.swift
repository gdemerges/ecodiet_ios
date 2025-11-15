//
//  AuthenticationManager.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import Foundation
import SwiftUI

/// Gestionnaire d'authentification temporaire
/// TODO: Remplacer par une vraie authentification avec PostgreSQL
@Observable
class AuthenticationManager {
    
    private(set) var currentUser: HardcodedProfiles.UserCredentials?
    private(set) var isAuthenticated = false
    
    // MARK: - Authentication
    
    /// Authentifie un utilisateur avec email et mot de passe
    func login(email: String, password: String) -> Result<HardcodedProfiles.UserCredentials, AuthError> {
        // Vérifier les profils hardcodés
        if let user = HardcodedProfiles.authenticate(email: email, password: password) {
            currentUser = user
            isAuthenticated = true
            return .success(user)
        }
        
        // Si pas trouvé, erreur
        return .failure(.invalidCredentials)
    }
    
    /// Déconnecte l'utilisateur actuel
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
    
    /// Vérifie si un email existe
    func checkEmailExists(_ email: String) -> Bool {
        return HardcodedProfiles.emailExists(email)
    }
    
    /// Récupère le profil de l'utilisateur actuel
    func getCurrentUserProfile() -> UserProfile? {
        guard let user = currentUser else { return nil }
        return user.profile.toUserProfile()
    }
    
    // MARK: - Errors
    
    enum AuthError: LocalizedError {
        case invalidCredentials
        case emailNotFound
        case networkError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Email ou mot de passe incorrect"
            case .emailNotFound:
                return "Aucun compte associé à cet email"
            case .networkError:
                return "Erreur de connexion au serveur"
            case .unknownError:
                return "Une erreur inconnue s'est produite"
            }
        }
    }
}

// MARK: - Preview Helper
extension AuthenticationManager {
    /// Crée un AuthenticationManager pré-authentifié pour les previews
    static func authenticated() -> AuthenticationManager {
        let manager = AuthenticationManager()
        _ = manager.login(email: "demo@ecodiet.com", password: "demo123")
        return manager
    }
}
