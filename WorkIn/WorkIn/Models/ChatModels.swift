import Foundation
import FirebaseFirestore

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: String
    let username: String
    let message: String
    let timestamp: Date
    let userHighestRank: StrengthRank?

    init(id: UUID = UUID(), userId: String, username: String, message: String, timestamp: Date = Date(), userHighestRank: StrengthRank? = nil) {
        self.id = id
        self.userId = userId
        self.username = username
        self.message = message
        self.timestamp = timestamp
        self.userHighestRank = userHighestRank
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
                    try? self.parseMessage(from: document.data(), id: document.documentID)
                }

                DispatchQueue.main.async {
                    self.messages = messages
                    self.isLoading = false
                }
            }
    }

    // MARK: - Send Message
    func sendMessage(userId: String, username: String, message: String, userHighestRank: StrengthRank?) async throws {
        print("💬 ChatManager: Sending message from \(username)")

        // Content moderation check
        let moderationResult = try await moderateContent(message)

        if !moderationResult.isAllowed {
            print("💬 ChatManager: Message blocked by content moderation: \(moderationResult.reason)")
            throw ChatError.messageBlocked(reason: moderationResult.reason)
        }

        let messageData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": userId,
            "username": username,
            "message": message,
            "timestamp": FieldValue.serverTimestamp(),
            "userHighestRank": userHighestRank?.rawValue ?? "",
            "moderated": true
        ]

        try await db.collection("globalChat")
            .addDocument(data: messageData)

        print("💬 ChatManager: Message sent successfully")
    }

    // MARK: - Content Moderation
    private func moderateContent(_ message: String) async throws -> ModerationResult {
        // Check for profanity and inappropriate content
        let lowercaseMessage = message.lowercased()

        // Hard-banned words that should always be blocked as whole words
        let wholeBannedWords = [
            "fuck", "fucking", "fucker", "fucked", "fck", "fuk",
            "shit", "shitting", "shitty", "sh1t", "shyt",
            "bitch", "bitches", "bitching", "b1tch", "biatch",
            "asshole", "assholes", "a$$hole",
            "bastard", "bastards",
            "damn", "dammit", "damned",
            "dick", "dicks", "d1ck",
            "cock", "cocks", "c0ck",
            "pussy", "pussies", "puss",
            "cunt", "cunts", "c*nt",
            "whore", "whores", "wh0re",
            "slut", "sluts", "slutty", "sl*t",
            "fag", "faggot", "fags", "f@g",
            "nigger", "nigga", "niggers", "n1gga", "n1gger",
            "retard", "retarded", "retards", "retrd",
            "rape", "raping", "rapist", "r@pe",
            "nazi", "nazis", "naz1",
            "kys"
        ]

        // Phrases that should be blocked as substrings
        let bannedPhrases = [
            "kill yourself",
            "kill your self"
        ]

        // Check for banned phrases first (substring match)
        for phrase in bannedPhrases {
            if lowercaseMessage.contains(phrase) {
                return ModerationResult(isAllowed: false, reason: "Inappropriate language detected")
            }
        }

        // Split message into words (handles punctuation)
        let words = lowercaseMessage.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        // Check for whole banned words
        for word in words {
            if wholeBannedWords.contains(word) {
                return ModerationResult(isAllowed: false, reason: "Inappropriate language detected")
            }
        }

        // Check for spam (repeated characters)
        let repeatedPattern = try? NSRegularExpression(pattern: "(.)\\1{4,}", options: [])
        if let matches = repeatedPattern?.matches(in: message, range: NSRange(message.startIndex..., in: message)),
           !matches.isEmpty {
            return ModerationResult(isAllowed: false, reason: "Spam detected")
        }

        // Check for excessive caps
        let uppercaseCount = message.filter { $0.isUppercase }.count
        if message.count > 10 && Double(uppercaseCount) / Double(message.count) > 0.7 {
            return ModerationResult(isAllowed: false, reason: "Excessive caps")
        }

        return ModerationResult(isAllowed: true, reason: "")
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

        return ChatMessage(
            id: messageId,
            userId: userId,
            username: username,
            message: message,
            timestamp: timestamp,
            userHighestRank: rank
        )
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

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid chat message data"
        case .userNotAuthenticated:
            return "User must be authenticated to chat"
        case .messageBlocked(let reason):
            return "Message blocked: \(reason)"
        }
    }
}
