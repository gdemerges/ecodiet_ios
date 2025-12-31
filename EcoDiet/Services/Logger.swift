import Foundation
import os.log

// MARK: - Logger

/// Service de logging centralisé pour l'application EcoDiet.
/// Utilise os.log pour une meilleure intégration avec les outils Apple.
enum Logger {
    /// Catégories de log disponibles
    enum Category: String {
        case data = "Data"
        case network = "Network"
        case ui = "UI"
        case auth = "Auth"
        case cache = "Cache"
        case notification = "Notification"
        case general = "General"
    }

    /// Niveaux de log
    enum Level {
        case debug
        case info
        case warning
        case error

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }

        var prefix: String {
            switch self {
            case .debug: return "[DEBUG]"
            case .info: return "[INFO]"
            case .warning: return "[WARNING]"
            case .error: return "[ERROR]"
            }
        }
    }

    // MARK: - Private

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.ecodiet"

    private static func logger(for category: Category) -> os.Logger {
        os.Logger(subsystem: subsystem, category: category.rawValue)
    }

    // MARK: - Public API

    /// Log un message debug (visible uniquement en développement)
    static func debug(_ message: String, category: Category = .general) {
        #if DEBUG
        logger(for: category).debug("\(Level.debug.prefix) \(message)")
        #endif
    }

    /// Log un message info
    static func info(_ message: String, category: Category = .general) {
        logger(for: category).info("\(Level.info.prefix) \(message)")
    }

    /// Log un avertissement
    static func warning(_ message: String, category: Category = .general) {
        logger(for: category).warning("\(Level.warning.prefix) \(message)")
    }

    /// Log une erreur
    static func error(_ message: String, category: Category = .general) {
        logger(for: category).error("\(Level.error.prefix) \(message)")
    }

    /// Log une erreur avec l'objet Error associé
    static func error(_ message: String, error: Error, category: Category = .general) {
        logger(for: category).error("\(Level.error.prefix) \(message): \(error.localizedDescription)")
    }

    // MARK: - Convenience Methods

    /// Log une erreur de données
    static func dataError(_ message: String, error: Error? = nil) {
        if let error = error {
            self.error(message, error: error, category: .data)
        } else {
            self.error(message, category: .data)
        }
    }

    /// Log une erreur réseau
    static func networkError(_ message: String, error: Error? = nil) {
        if let error = error {
            self.error(message, error: error, category: .network)
        } else {
            self.error(message, category: .network)
        }
    }

    /// Log une info réseau
    static func networkInfo(_ message: String) {
        info(message, category: .network)
    }

    /// Log une info cache
    static func cacheInfo(_ message: String) {
        debug(message, category: .cache)
    }
}
