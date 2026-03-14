import UIKit

actor ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSString, UIImage>()
    private var loadingTasks: [String: Task<UIImage?, Never>] = [:]

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func image(for path: String) -> UIImage? {
        cache.object(forKey: path as NSString)
    }

    func setImage(_ image: UIImage, for path: String) {
        cache.setObject(image, forKey: path as NSString)
    }

    func loadThumbnail(for path: String) async -> UIImage? {
        // Check cache first
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }

        // Check if already loading
        if let existingTask = loadingTasks[path] {
            return await existingTask.value
        }

        // Start loading on background thread
        let task = Task<UIImage?, Never> {
            let url = MomentDisplayHelper.mediaFileURL(path)
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                return nil
            }

            // Generate thumbnail at reduced size
            let maxDimension: CGFloat = 300
            let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

            let renderer = UIGraphicsImageRenderer(size: newSize)
            let thumbnail = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            cache.setObject(thumbnail, forKey: path as NSString)
            return thumbnail
        }

        loadingTasks[path] = task
        let result = await task.value
        loadingTasks.removeValue(forKey: path)
        return result
    }

    func clearCache() {
        cache.removeAllObjects()
        loadingTasks.removeAll()
    }
}
