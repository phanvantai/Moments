import Foundation
import AVFoundation
import UIKit

final class AVThumbnailGenerator: ThumbnailGeneratorProtocol {
    func generateThumbnailData(videoURL: URL) throws -> Data {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)

        guard let jpegData = uiImage.jpegData(compressionQuality: 0.7) else {
            throw MediaFileError.thumbnailGenerationFailed
        }
        return jpegData
    }
}
