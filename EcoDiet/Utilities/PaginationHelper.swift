import SwiftData
import Observation

@Observable
class PaginationHelper<T: PersistentModel> {
    private(set) var items: [T] = []
    private(set) var currentPage = 1
    private(set) var isLoading = false
    private(set) var hasMore = true

    let pageSize: Int

    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }

    /// Charge la page suivante d'items
    /// - Parameter fetcher: Closure qui récupère les items pour une page donnée
    func loadNextPage(_ fetcher: (Int, Int) async throws -> [T]) async {
        guard !isLoading && hasMore else { return }
        isLoading = true

        do {
            let newItems = try await fetcher(currentPage, pageSize)
            items.append(contentsOf: newItems)
            hasMore = newItems.count == pageSize
            currentPage += 1
        } catch {
            print("Pagination error: \(error)")
        }

        isLoading = false
    }

    /// Réinitialise la pagination (utile pour les nouvelles recherches)
    func reset() {
        items = []
        currentPage = 1
        hasMore = true
        isLoading = false
    }
}
