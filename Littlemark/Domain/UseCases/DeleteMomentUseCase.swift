import Foundation

protocol DeleteMomentUseCaseProtocol: Sendable {
    func execute(momentId: UUID) async throws
}

struct DeleteMomentUseCase: DeleteMomentUseCaseProtocol {
    private let momentRepository: MomentRepositoryProtocol
    private let mediaRepository: MediaRepositoryProtocol

    init(
        momentRepository: MomentRepositoryProtocol,
        mediaRepository: MediaRepositoryProtocol
    ) {
        self.momentRepository = momentRepository
        self.mediaRepository = mediaRepository
    }

    func execute(momentId: UUID) async throws {
        let moment = try await momentRepository.fetch(byId: momentId)
        guard let moment else {
            throw DeleteMomentError.momentNotFound
        }

        // Delete media files
        for mediaItem in moment.mediaItems {
            try? await mediaRepository.deleteMedia(filePath: mediaItem.filePath)
            if let thumbnailPath = mediaItem.thumbnailPath {
                try? await mediaRepository.deleteMedia(filePath: thumbnailPath)
            }
        }

        // Delete voice note file
        if let voiceNote = moment.voiceNote {
            try? await mediaRepository.deleteVoiceNote(filePath: voiceNote.filePath)
        }

        // Delete moment from repository
        try await momentRepository.delete(byId: momentId)
    }
}

enum DeleteMomentError: Error, Equatable {
    case momentNotFound
}
