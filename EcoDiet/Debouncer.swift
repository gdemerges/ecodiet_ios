import SwiftUI

// MARK: - Debouncer

/// Utilitaire pour retarder l'exécution d'actions répétées.
/// Utile pour éviter les appels réseau excessifs lors de la saisie de texte.
///
/// Exemple d'utilisation:
/// ```swift
/// @State private var debouncer = Debouncer(delay: 0.3)
///
/// .onChange(of: searchText) { _, newValue in
///     debouncer.debounce {
///         await performSearch(newValue)
///     }
/// }
/// ```
@Observable
final class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval

    /// Crée un debouncer avec le délai spécifié
    /// - Parameter delay: Délai en secondes avant l'exécution (défaut: 0.3s)
    init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }

    /// Exécute l'action après le délai spécifié.
    /// Si une action est déjà en attente, elle est annulée.
    /// - Parameter action: L'action async à exécuter
    func debounce(action: @escaping () async -> Void) {
        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if !Task.isCancelled {
                    await action()
                }
            } catch {
                // Task was cancelled, nothing to do
            }
        }
    }

    /// Annule l'action en attente
    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
