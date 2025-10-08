import Foundation
import FirebaseFirestore
import FirebaseFunctions

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: String
    let username: String
    let message: String
    let timestamp: Date
    let userHighestRank: StrengthRank?
    let isDeveloper: Bool
    var firestoreDocumentId: String? // Store the Firestore document ID for deletion

    init(id: UUID = UUID(), userId: String, username: String, message: String, timestamp: Date = Date(), userHighestRank: StrengthRank? = nil, isDeveloper: Bool = false, firestoreDocumentId: String? = nil) {
        self.id = id
        self.userId = userId
        self.username = username
        self.message = message
        self.timestamp = timestamp
        self.userHighestRank = userHighestRank
        self.isDeveloper = isDeveloper
        self.firestoreDocumentId = firestoreDocumentId
    }
}

// MARK: - Chat Manager
class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        print("💬 ChatManager: Initializing...")
    }

    // MARK: - Start Listening to Messages
    func startListening() {
        print("💬 ChatManager: Starting to listen for messages...")

        listener = db.collection("globalChat")
            .order(by: "timestamp", descending: false)
            .limit(toLast: 100) // Load last 100 messages
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("💬 ChatManager Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let snapshot = snapshot else { return }

                print("💬 ChatManager: Received \(snapshot.documents.count) messages")

                let messages = snapshot.documents.compactMap { document -> ChatMessage? in
                    var message = try? self.parseMessage(from: document.data(), id: document.documentID)
                    message?.firestoreDocumentId = document.documentID
                    return message
                }

                DispatchQueue.main.async {
                    self.messages = messages
                    self.isLoading = false
                }
            }
    }

    // MARK: - Send Message
    func sendMessage(userId: String, username: String, message: String, userHighestRank: StrengthRank?, userEmail: String?) async throws {
        print("💬 ChatManager: Sending message from \(username)")

        // Content moderation check using Cloud Function
        let moderationResult = try await moderateContentWithPerspectiveAPI(message)

        if !moderationResult.isAllowed {
            print("💬 ChatManager: Message blocked by Perspective API: \(moderationResult.reason)")
            throw ChatError.messageBlocked(reason: moderationResult.reason)
        }

        let isDeveloper = userEmail == "wkbf10@gmail.com"

        let messageData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": userId,
            "username": username,
            "message": message,
            "timestamp": FieldValue.serverTimestamp(),
            "userHighestRank": userHighestRank?.rawValue ?? "",
            "isDeveloper": isDeveloper,
            "moderated": true
        ]

        try await db.collection("globalChat")
            .addDocument(data: messageData)

        print("💬 ChatManager: Message sent successfully")
    }

    // MARK: - Public Moderation Method (for usernames and other content)
    func moderateContent(_ content: String) async throws -> ModerationResult {
        return try await moderateContentWithPerspectiveAPI(content)
    }

    // MARK: - Content Moderation with Perspective API
    private func moderateContentWithPerspectiveAPI(_ message: String) async throws -> ModerationResult {
        print("💬 ChatManager: Calling Cloud Function for moderation")

        // Call the Cloud Function
        let functions = Functions.functions()
        let moderateMessage = functions.httpsCallable("moderateMessage")

        do {
            let result = try await moderateMessage.call(["message": message])

            guard let data = result.data as? [String: Any],
                  let isAllowed = data["isAllowed"] as? Bool,
                  let reason = data["reason"] as? String else {
                print("💬 ChatManager: Invalid response from Cloud Function")
                throw ChatError.invalidData
            }

            print("💬 ChatManager: Moderation result - isAllowed: \(isAllowed), reason: \(reason)")

            return ModerationResult(isAllowed: isAllowed, reason: reason)

        } catch {
            print("💬 ChatManager: Cloud Function error: \(error.localizedDescription)")

            // Fallback to basic client-side check if Cloud Function fails
            if message.lowercased().contains("fuck") ||
               message.lowercased().contains("shit") ||
               message.lowercased().contains("nigger") ||
               message.lowercased().contains("cunt") {
                return ModerationResult(isAllowed: false, reason: "Inappropriate language detected")
            }

            // If Cloud Function is unavailable, allow message but log warning
            print("⚠️ ChatManager: Using fallback moderation - allowing message")
            return ModerationResult(isAllowed: true, reason: "")
        }
    }

    // MARK: - Parse Message
    private func parseMessage(from data: [String: Any], id: String) throws -> ChatMessage {
        guard let idString = data["id"] as? String,
              let messageId = UUID(uuidString: idString),
              let userId = data["userId"] as? String,
              let username = data["username"] as? String,
              let message = data["message"] as? String,
              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
            throw ChatError.invalidData
        }

        let rankString = data["userHighestRank"] as? String ?? ""
        let rank = StrengthRank(rawValue: rankString)
        let isDeveloper = data["isDeveloper"] as? Bool ?? false

        return ChatMessage(
            id: messageId,
            userId: userId,
            username: username,
            message: message,
            timestamp: timestamp,
            userHighestRank: rank,
            isDeveloper: isDeveloper
        )
    }

    // MARK: - Delete Message
    func deleteMessage(_ message: ChatMessage, currentUserId: String, userEmail: String?) async throws {
        guard let documentId = message.firestoreDocumentId else {
            throw ChatError.invalidData
        }

        // Check if user is admin or message owner
        let isAdmin = userEmail == "wkbf10@gmail.com"
        let isOwner = message.userId == currentUserId

        guard isAdmin || isOwner else {
            throw ChatError.unauthorizedDeletion
        }

        print("💬 ChatManager: Deleting message \(documentId)")

        try await db.collection("globalChat").document(documentId).delete()

        print("💬 ChatManager: Message deleted successfully")
    }

    // MARK: - Stop Listening
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        stopListening()
    }
}

// MARK: - Moderation Result
struct ModerationResult {
    let isAllowed: Bool
    let reason: String
}

// MARK: - Chat Error
enum ChatError: Error, LocalizedError {
    case invalidData
    case userNotAuthenticated
    case messageBlocked(reason: String)
    case unauthorizedDeletion

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid chat message data"
        case .userNotAuthenticated:
            return "User must be authenticated to chat"
        case .messageBlocked(let reason):
            return "Message blocked: \(reason)"
        case .unauthorizedDeletion:
            return "You don't have permission to delete this message"
        }
    }
}
