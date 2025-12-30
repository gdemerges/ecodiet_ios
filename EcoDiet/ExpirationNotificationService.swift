import SwiftUI
import UserNotifications
import SwiftData

// MARK: - Expiration Notification Service

/// Service pour gerer les notifications d'expiration des ingredients
@Observable
class ExpirationNotificationService {
    static let shared = ExpirationNotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationCategoryID = "INGREDIENT_EXPIRATION"

    var isAuthorized = false

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Demande l'autorisation pour les notifications
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("Erreur autorisation notifications: \(error)")
            return false
        }
    }

    /// Verifie le statut d'autorisation actuel
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    // MARK: - Schedule Notifications

    /// Planifie les notifications pour tous les ingredients avec date d'expiration
    func scheduleExpirationNotifications(for ingredients: [Ingredient]) async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }

        // Annuler les anciennes notifications
        await cancelAllExpirationNotifications()

        // Planifier les nouvelles
        for ingredient in ingredients where ingredient.isInFridge {
            guard let expirationDate = ingredient.expirationDate else { continue }

            // Notification 1 jour avant expiration
            await scheduleNotification(
                for: ingredient,
                daysBefore: 1,
                expirationDate: expirationDate
            )

            // Notification le jour de l'expiration
            await scheduleNotification(
                for: ingredient,
                daysBefore: 0,
                expirationDate: expirationDate
            )
        }
    }

    /// Planifie une notification pour un ingredient specifique
    func scheduleNotification(for ingredient: Ingredient, daysBefore: Int, expirationDate: Date) async {
        let calendar = Calendar.current

        // Calculer la date de notification
        guard let notificationDate = calendar.date(byAdding: .day, value: -daysBefore, to: expirationDate) else {
            return
        }

        // Ne pas programmer si la date est deja passee
        guard notificationDate > Date() else { return }

        // Creer le contenu
        let content = UNMutableNotificationContent()

        if daysBefore == 0 {
            content.title = "Expiration aujourd'hui !"
            content.body = "\(ingredient.name) expire aujourd'hui. Pensez a l'utiliser !"
        } else if daysBefore == 1 {
            content.title = "Expiration demain"
            content.body = "\(ingredient.name) expire demain. Planifiez une recette !"
        } else {
            content.title = "Expiration proche"
            content.body = "\(ingredient.name) expire dans \(daysBefore) jours."
        }

        content.sound = .default
        content.categoryIdentifier = notificationCategoryID
        content.userInfo = ["ingredientId": ingredient.id.uuidString]

        // Creer le trigger
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Creer l'identifiant unique
        let identifier = "\(ingredient.id.uuidString)_\(daysBefore)"

        // Creer la requete
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Erreur programmation notification: \(error)")
        }
    }

    /// Annule toutes les notifications d'expiration
    func cancelAllExpirationNotifications() async {
        let pending = await notificationCenter.pendingNotificationRequests()
        let identifiers = pending.filter { $0.content.categoryIdentifier == notificationCategoryID }.map { $0.identifier }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Annule les notifications pour un ingredient specifique
    func cancelNotifications(for ingredient: Ingredient) {
        let identifiers = [
            "\(ingredient.id.uuidString)_0",
            "\(ingredient.id.uuidString)_1",
            "\(ingredient.id.uuidString)_3"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Expiring Ingredients

    /// Retourne les ingredients qui expirent bientot (dans les 3 prochains jours)
    func expiringIngredients(from ingredients: [Ingredient]) -> [Ingredient] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return ingredients.filter { ingredient in
            guard ingredient.isInFridge,
                  let expirationDate = ingredient.expirationDate else {
                return false
            }

            let expirationDay = calendar.startOfDay(for: expirationDate)
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDay).day ?? 0

            return daysUntilExpiration >= 0 && daysUntilExpiration <= 3
        }.sorted { first, second in
            (first.expirationDate ?? .distantFuture) < (second.expirationDate ?? .distantFuture)
        }
    }

    /// Retourne les ingredients expires
    func expiredIngredients(from ingredients: [Ingredient]) -> [Ingredient] {
        let today = Calendar.current.startOfDay(for: Date())

        return ingredients.filter { ingredient in
            guard ingredient.isInFridge,
                  let expirationDate = ingredient.expirationDate else {
                return false
            }

            return Calendar.current.startOfDay(for: expirationDate) < today
        }
    }
}

// MARK: - Expiring Ingredients Banner View

/// Banniere affichant les ingredients qui expirent bientot
struct ExpiringIngredientsBanner: View {
    let ingredients: [Ingredient]
    let onTap: () -> Void

    private var expiringCount: Int {
        ExpirationNotificationService.shared.expiringIngredients(from: ingredients).count
    }

    private var expiredCount: Int {
        ExpirationNotificationService.shared.expiredIngredients(from: ingredients).count
    }

    var body: some View {
        if expiringCount > 0 || expiredCount > 0 {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: expiredCount > 0 ? "exclamationmark.triangle.fill" : "clock.badge.exclamationmark.fill")
                        .font(.title2)
                        .foregroundStyle(expiredCount > 0 ? .red : .orange)

                    VStack(alignment: .leading, spacing: 2) {
                        if expiredCount > 0 {
                            Text("\(expiredCount) ingredient\(expiredCount > 1 ? "s" : "") expire\(expiredCount > 1 ? "s" : "")")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.red)
                        }

                        if expiringCount > 0 {
                            Text("\(expiringCount) expire\(expiringCount > 1 ? "nt" : "") bientot")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(expiredCount > 0 ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(expiredCount > 0 ? Color.red.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Expiration Badge

/// Badge affichant le statut d'expiration d'un ingredient
struct ExpirationBadge: View {
    let expirationDate: Date?

    private var daysUntilExpiration: Int? {
        guard let expirationDate = expirationDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiration = calendar.startOfDay(for: expirationDate)
        return calendar.dateComponents([.day], from: today, to: expiration).day
    }

    private var status: ExpirationStatus {
        guard let days = daysUntilExpiration else { return .noDate }

        if days < 0 {
            return .expired
        } else if days == 0 {
            return .today
        } else if days <= 3 {
            return .soon(days: days)
        } else {
            return .ok(days: days)
        }
    }

    var body: some View {
        switch status {
        case .noDate:
            EmptyView()
        case .expired:
            badgeView(text: "Expire", color: .red, icon: "exclamationmark.triangle.fill")
        case .today:
            badgeView(text: "Aujourd'hui", color: .orange, icon: "clock.fill")
        case .soon(let days):
            badgeView(text: "J-\(days)", color: .orange, icon: "clock")
        case .ok(let days):
            badgeView(text: "J-\(days)", color: .green, icon: "checkmark.circle")
        }
    }

    private func badgeView(text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15), in: Capsule())
    }

    private enum ExpirationStatus {
        case noDate
        case expired
        case today
        case soon(days: Int)
        case ok(days: Int)
    }
}
