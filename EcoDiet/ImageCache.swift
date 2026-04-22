import SwiftUI

// MARK: - Image Cache Service
/// Service de cache d'images en mémoire et sur disque pour optimiser les performances

actor ImageCacheService {
    static let shared = ImageCacheService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        cacheDirectory = cachePath.appendingPathComponent("ImageCache", isDirectory: true)

        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        evictStaleFiles()
    }

    private func evictStaleFiles(olderThan days: Int = 7) {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        let cutoff = Date().addingTimeInterval(-Double(days) * 86400)
        for file in files {
            let modified = (try? file.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            if modified < cutoff {
                try? fileManager.removeItem(at: file)
            }
        }
    }

    // MARK: - Public API

    /// Récupère une image depuis le cache ou la télécharge
    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        // 1. Vérifier le cache mémoire
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }

        // 2. Vérifier le cache disque
        if let diskImage = loadFromDisk(key: key) {
            memoryCache.setObject(diskImage, forKey: key as NSString)
            return diskImage
        }

        // 3. Télécharger l'image
        guard let downloadedImage = await downloadImage(from: url) else {
            return nil
        }

        // 4. Mettre en cache
        memoryCache.setObject(downloadedImage, forKey: key as NSString)
        saveToDisk(image: downloadedImage, key: key)

        return downloadedImage
    }

    /// Précharge une liste d'images
    func preload(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = await self.image(for: url)
                }
            }
        }
    }

    /// Vide le cache
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private Methods

    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }

    private func diskPath(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let path = diskPath(for: key)
        guard fileManager.fileExists(atPath: path.path),
              let data = try? Data(contentsOf: path),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private func saveToDisk(image: UIImage, key: String) {
        let path = diskPath(for: key)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: path)
    }

    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let image = UIImage(data: data) else {
                return nil
            }

            return downsample(image, to: 800)
        } catch {
            Logger.networkError("Erreur téléchargement image", error: error)
            return nil
        }
    }

    private func downsample(_ image: UIImage, to maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension else { return image }
        let scale = maxDimension / longestSide
        let newSize = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}

// MARK: - Cached Async Image View

/// Vue SwiftUI pour afficher une image avec cache
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = true

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }

        isLoading = true
        image = await ImageCacheService.shared.image(for: url)
        isLoading = false
    }
}

// MARK: - Convenience Initializer

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: url, content: content) {
            ProgressView()
        }
    }
}

extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(url: url) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
    }
}
