import SwiftUI

struct AISettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var apiKey: String = ""
    @State private var showingInfo = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("OpenAI API Configuration")) {
                    SecureField("API Key", text: $apiKey)

                    Button(action: { showingInfo = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("How to get an API key")
                                .foregroundColor(themeManager.accentColor)
                        }
                    }
                }

                Section(header: Text("API Status")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        if apiKey.isEmpty {
                            Text("Not configured")
                                .foregroundColor(.red)
                        } else {
                            Text("Configured")
                                .foregroundColor(.green)
                        }
                    }
                }

                Section {
                    Button(action: saveAPIKey) {
                        HStack {
                            Spacer()
                            Text("Save API Key")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(apiKey.isEmpty)
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("How to Get an API Key", isPresented: $showingInfo) {
                Button("Open OpenAI", action: openOpenAI)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("""
                1. Go to platform.openai.com
                2. Sign up or log in
                3. Click on your profile → View API keys
                4. Create new secret key
                5. Copy and paste it here

                Note: You'll need to add billing information to OpenAI to use the API.
                """)
            }
            .onAppear {
                loadAPIKey()
            }
        }
    }

    private func loadAPIKey() {
        apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }

    private func saveAPIKey() {
        UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
        AIAssistantService.shared.setAPIKey(apiKey)
        dismiss()
    }

    private func openOpenAI() {
        if let url = URL(string: "https://platform.openai.com/api-keys") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    AISettingsView()
        .environmentObject(ThemeManager())
}
