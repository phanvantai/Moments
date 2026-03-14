import Foundation
import NaturalLanguage
import Vision

final class CategoryEngine: CategoryEngineProtocol, @unchecked Sendable {

    // MARK: - Public

    func suggest(
        text: String?,
        voiceTranscript: String?,
        imageData: [Data]?,
        location: Location?
    ) async -> [String] {
        var scores: [String: Double] = [:]

        // Signal 1 — NLP keywords from text and transcript
        let nlpResults = analyzeText(text, transcript: voiceTranscript)
        for suggestion in nlpResults {
            scores[suggestion.key, default: 0] += suggestion.confidence
        }

        // Signal 2 — Vision classification from images
        let visionResults = await analyzeImages(imageData)
        for suggestion in visionResults {
            scores[suggestion.key, default: 0] += suggestion.confidence
        }

        // Signal 3 — Location-based categories
        let locationResults = analyzeLocation(location)
        for suggestion in locationResults {
            scores[suggestion.key, default: 0] += suggestion.confidence
        }

        // Sort by confidence descending, deduplicated
        let sorted = scores
            .sorted { $0.value > $1.value }
            .map(\.key)

        // Default to "daily" if nothing matched
        if sorted.isEmpty {
            return ["daily"]
        }

        return sorted
    }

    // MARK: - NLP Analysis

    func analyzeText(_ text: String?, transcript: String?) -> [CategorySuggestion] {
        let combined = [text, transcript]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !combined.isEmpty else { return [] }

        var suggestions: [CategorySuggestion] = []

        for category in MomentCategory.predefined {
            for keyword in category.keywords {
                if combined.contains(keyword.lowercased()) {
                    suggestions.append(
                        CategorySuggestion(key: category.key, confidence: 0.6)
                    )
                    break // one match per category is enough
                }
            }
        }

        return suggestions
    }

    // MARK: - Vision Analysis

    func analyzeImages(_ imageData: [Data]?) async -> [CategorySuggestion] {
        guard let imageData, !imageData.isEmpty else { return [] }

        var suggestions: [CategorySuggestion] = []

        for data in imageData {
            let labels = classifyImage(data)
            let mapped = mapVisionLabels(labels)
            suggestions.append(contentsOf: mapped)
        }

        return suggestions
    }

    func classifyImage(_ data: Data) -> [String] {
        guard let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) else {
            return []
        }

        var labels: [String] = []
        let request = VNClassifyImageRequest { request, _ in
            guard let observations = request.results as? [VNClassificationObservation] else { return }
            let topLabels = observations
                .filter { $0.confidence > 0.3 }
                .prefix(5)
                .map { $0.identifier.lowercased() }
            labels = topLabels
        }

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])

        return labels
    }

    func mapVisionLabels(_ labels: [String]) -> [CategorySuggestion] {
        let mapping: [String: String] = [
            "outdoor": "outdoor",
            "landscape": "outdoor",
            "sky": "outdoor",
            "tree": "outdoor",
            "plant": "outdoor",
            "nature": "outdoor",
            "garden": "outdoor",
            "beach": "outdoor",
            "mountain": "outdoor",
            "food": "food",
            "meal": "food",
            "fruit": "food",
            "drink": "food",
            "cooking": "food",
            "animal": "outdoor",
            "pet": "daily",
            "people": "family",
            "person": "family",
            "baby": "family",
            "child": "family",
            "sport": "play",
            "game": "play",
            "toy": "play",
            "book": "learn",
            "text": "learn",
            "vehicle": "travel",
            "airplane": "travel",
            "building": "daily",
            "hospital": "health",
        ]

        var suggestions: [CategorySuggestion] = []
        var seenKeys = Set<String>()

        for label in labels {
            for (keyword, categoryKey) in mapping {
                if label.contains(keyword), !seenKeys.contains(categoryKey) {
                    seenKeys.insert(categoryKey)
                    suggestions.append(
                        CategorySuggestion(key: categoryKey, confidence: 0.4)
                    )
                }
            }
        }

        return suggestions
    }

    // MARK: - Location Analysis

    func analyzeLocation(_ location: Location?) -> [CategorySuggestion] {
        guard let placeType = location?.placeType?.lowercased(), !placeType.isEmpty else {
            return []
        }

        let mapping: [String: String] = [
            "park": "outdoor",
            "garden": "outdoor",
            "beach": "outdoor",
            "hospital": "health",
            "clinic": "health",
            "restaurant": "food",
            "cafe": "food",
            "food": "food",
            "school": "learn",
            "university": "learn",
            "museum": "learn",
            "hotel": "travel",
            "airport": "travel",
            "transport": "travel",
            "shopping": "daily",
            "mall": "daily",
            "worship": "daily",
        ]

        if let categoryKey = mapping[placeType] {
            return [CategorySuggestion(key: categoryKey, confidence: 0.5)]
        }

        return []
    }
}
