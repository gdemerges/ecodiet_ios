import SwiftUI
import Combine

// MARK: - Debouncer

/// Classe utilitaire pour debouncer les actions
@Observable
class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval

    init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }

    /// Execute l'action apres le delai specifie
    func debounce(action: @escaping () async -> Void) {
        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if !Task.isCancelled {
                    await action()
                }
            } catch {}
        }
    }

    /// Annule l'action en cours
    func cancel() {
        task?.cancel()
    }
}

// MARK: - Debounced Search Modifier

/// View modifier pour ajouter une recherche debouncee
struct DebouncedSearchModifier: ViewModifier {
    @Binding var text: String
    let delay: TimeInterval
    let onSearch: (String) -> Void

    @State private var debouncedText = ""
    @State private var debounceTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { _, newValue in
                debounceTask?.cancel()

                debounceTask = Task {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        if !Task.isCancelled {
                            await MainActor.run {
                                debouncedText = newValue
                                onSearch(newValue)
                            }
                        }
                    } catch {}
                }
            }
    }
}

extension View {
    /// Ajoute un debouncing a une valeur de recherche
    func debounceSearch(
        text: Binding<String>,
        delay: TimeInterval = 0.3,
        onSearch: @escaping (String) -> Void
    ) -> some View {
        self.modifier(DebouncedSearchModifier(text: text, delay: delay, onSearch: onSearch))
    }
}

// MARK: - Debounced State Property Wrapper

/// Property wrapper pour un etat debounce
@propertyWrapper
struct DebouncedState<Value>: DynamicProperty {
    @State private var value: Value
    @State private var debouncedValue: Value
    @State private var task: Task<Void, Never>?

    let delay: TimeInterval

    init(wrappedValue: Value, delay: TimeInterval = 0.3) {
        self._value = State(initialValue: wrappedValue)
        self._debouncedValue = State(initialValue: wrappedValue)
        self.delay = delay
    }

    var wrappedValue: Value {
        get { value }
        nonmutating set {
            value = newValue
            scheduleUpdate(newValue)
        }
    }

    var projectedValue: Value {
        debouncedValue
    }

    private func scheduleUpdate(_ newValue: Value) {
        task?.cancel()

        task = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if !Task.isCancelled {
                    debouncedValue = newValue
                }
            } catch {}
        }
    }
}
