import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var workoutStore: WorkoutStore

    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatManager.messages) { message in
                                ChatMessageRow(
                                    message: message,
                                    onDelete: {
                                        deleteMessage(message)
                                    }
                                )
                                .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: chatManager.messages.count) { _ in
                        scrollToBottom()
                    }
                }

                Divider()

                // Message Input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : themeManager.accentColor)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(themeManager.secondaryBackgroundColor)
            }
            .navigationTitle("Community Chat")
            .navigationBarTitleDisplayMode(.inline)
            .background(themeManager.backgroundColor)
            .onAppear {
                chatManager.startListening()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        guard let userId = authManager.user?.uid else {
            print("💬 Error: User not authenticated")
            return
        }

        // Use displayName if set, otherwise use "Anonymous"
        let username = profileStore.profile.displayName.isEmpty ? "Anonymous" : profileStore.profile.displayName

        // Calculate user's highest rank from all workouts
        let highestRank = calculateUserHighestRank()

        Task {
            do {
                try await chatManager.sendMessage(
                    userId: userId,
                    username: username,
                    message: trimmedMessage,
                    userHighestRank: highestRank,
                    userEmail: authManager.user?.email
                )
                await MainActor.run {
                    messageText = ""
                }
            } catch {
                print("💬 Error sending message: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }

    private func scrollToBottom() {
        guard let lastMessage = chatManager.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    private func deleteMessage(_ message: ChatMessage) {
        guard let userId = authManager.user?.uid else { return }
        let userEmail = authManager.user?.email

        Task {
            do {
                try await chatManager.deleteMessage(message, currentUserId: userId, userEmail: userEmail)
            } catch {
                print("💬 Error deleting message: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }

    private func calculateUserHighestRank() -> StrengthRank? {
        var highestRank: StrengthRank?

        for workout in workoutStore.workouts {
            if let workoutRank = workout.getHighestRank(bodyWeight: workout.bodyWeight ?? profileStore.profile.currentWeight) {
                if highestRank == nil {
                    highestRank = workoutRank
                } else {
                    let currentIndex = StrengthRank.allCases.firstIndex(of: workoutRank) ?? 0
                    let highestIndex = StrengthRank.allCases.firstIndex(of: highestRank!) ?? 0

                    if currentIndex > highestIndex {
                        highestRank = workoutRank
                    }
                }
            }
        }

        return highestRank
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage
    let onDelete: () -> Void

    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingDeleteConfirmation = false

    var isCurrentUser: Bool {
        message.userId == authManager.user?.uid
    }

    var canDelete: Bool {
        // User can delete their own messages or admin can delete any message
        let isAdmin = authManager.user?.email == "wkbf10@gmail.com"
        return isCurrentUser || isAdmin
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isCurrentUser {
                // Other user's message - left aligned
                VStack(alignment: .leading, spacing: 4) {
                    // Username with rank badge
                    HStack(spacing: 6) {
                        if let rank = message.userHighestRank {
                            Image(rank.badgeImageName)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        Text(message.username)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.secondaryTextColor)

                        if message.isDeveloper {
                            Text("(Developer)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }

                    Text(message.message)
                        .padding(10)
                        .background(themeManager.cardBackgroundColor)
                        .foregroundColor(themeManager.primaryTextColor)
                        .cornerRadius(12)
                        .contextMenu {
                            if canDelete {
                                Button(role: .destructive) {
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete Message", systemImage: "trash")
                                }
                            }
                        }

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Spacer()
            } else {
                // Current user's message - right aligned
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // Username with rank badge
                    HStack(spacing: 6) {
                        if message.isDeveloper {
                            Text("(Developer)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        Text(message.username)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.secondaryTextColor)
                        if let rank = message.userHighestRank {
                            Image(rank.badgeImageName)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }

                    Text(message.message)
                        .padding(10)
                        .background(themeManager.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .contextMenu {
                            if canDelete {
                                Button(role: .destructive) {
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete Message", systemImage: "trash")
                                }
                            }
                        }

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
        }
        .confirmationDialog("Delete Message", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this message?")
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }

        return formatter.string(from: date)
    }
}

#Preview {
    ChatView()
        .environmentObject(ChatManager())
        .environmentObject(AuthenticationManager())
        .environmentObject(UserProfileStore())
        .environmentObject(ThemeManager())
        .environmentObject(WorkoutStore())
}
