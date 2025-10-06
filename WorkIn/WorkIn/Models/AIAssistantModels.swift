import Foundation

// MARK: - AI Assistant Service
class AIAssistantService {
    static let shared = AIAssistantService()

    private var apiKey: String = ""
    private let apiURL = "https://api.openai.com/v1/chat/completions"

    init() {
        // Load API key from UserDefaults
        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            apiKey = savedKey
        }
    }

    func setAPIKey(_ key: String) {
        apiKey = key
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }

    func reloadAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            apiKey = savedKey
        }
    }

    // MARK: - Generate Workout Plan
    func generateWorkoutPlan(userProfile: UserProfile, workoutHistory: [Workout], preferences: String?) async throws -> AIWorkoutPlan {
        let prompt = buildWorkoutPrompt(userProfile: userProfile, workoutHistory: workoutHistory, preferences: preferences)

        let response = try await callOpenAI(prompt: prompt, systemMessage: "You are a professional fitness coach creating personalized workout plans. Respond with workout plans in JSON format with exercises, sets, reps, and rest times.")

        return try parseWorkoutPlan(from: response)
    }

    // MARK: - Generate Meal Plan
    func generateMealPlan(userProfile: UserProfile, preferences: String?) async throws -> AIMealPlan {
        let prompt = buildMealPrompt(userProfile: userProfile, preferences: preferences)

        let response = try await callOpenAI(prompt: prompt, systemMessage: "You are a professional nutritionist creating personalized meal plans. Respond with meal plans in JSON format with meals, foods, and macros.")

        return try parseMealPlan(from: response)
    }

    // MARK: - Build Prompts
    private func buildWorkoutPrompt(userProfile: UserProfile, workoutHistory: [Workout], preferences: String?) -> String {
        var prompt = """
        Create a personalized workout plan for me based on the following information:

        User Profile:
        - Goal: \(userProfile.goalType.rawValue)
        - Current Weight: \(userProfile.currentWeight) lbs
        - Goal Weight: \(userProfile.goalWeight) lbs
        - Weekly Workout Goal: \(userProfile.weeklyWorkoutGoal) workouts

        """

        if !workoutHistory.isEmpty {
            prompt += "\nRecent Workouts:\n"
            for workout in workoutHistory.prefix(3) {
                prompt += "- \(workout.name) with \(workout.exercises.count) exercises\n"
            }
        }

        if let prefs = preferences, !prefs.isEmpty {
            prompt += "\nAdditional Preferences: \(prefs)\n"
        }

        prompt += """

        Please create a workout plan in the following JSON format:
        {
          "name": "Workout Name",
          "description": "Brief description",
          "exercises": [
            {
              "name": "Exercise Name",
              "sets": 3,
              "reps": 10,
              "weight": 135,
              "restTime": 60,
              "muscleGroups": ["Chest", "Triceps"],
              "equipment": "Barbell"
            }
          ]
        }
        """

        return prompt
    }

    private func buildMealPrompt(userProfile: UserProfile, preferences: String?) -> String {
        var prompt = """
        Create a personalized meal plan for me based on the following information:

        User Profile:
        - Goal: \(userProfile.goalType.rawValue)
        - Daily Calorie Goal: \(userProfile.dailyCalories) calories
        - Daily Protein Goal: \(userProfile.dailyProtein)g protein

        """

        if let prefs = preferences, !prefs.isEmpty {
            prompt += "Additional Preferences: \(prefs)\n"
        }

        prompt += """

        Please create a meal plan in the following JSON format:
        {
          "name": "Meal Plan Name",
          "description": "Brief description",
          "meals": [
            {
              "name": "Meal Name",
              "foods": [
                {
                  "name": "Food Item",
                  "calories": 300,
                  "protein": 25,
                  "carbs": 30,
                  "fat": 10
                }
              ]
            }
          ]
        }
        """

        return prompt
    }

    // MARK: - Call OpenAI API
    private func callOpenAI(prompt: String, systemMessage: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.apiKeyNotSet
        }

        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("🤖 OpenAI Error: \(errorBody)")
            throw AIError.apiError(statusCode: httpResponse.statusCode)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }

        return content
    }

    // MARK: - Parse Responses
    private func parseWorkoutPlan(from response: String) throws -> AIWorkoutPlan {
        // Extract JSON from potential markdown code blocks
        var jsonString = response
        if let jsonStart = response.range(of: "```json")?.upperBound,
           let jsonEnd = response.range(of: "```", range: jsonStart..<response.endIndex)?.lowerBound {
            jsonString = String(response[jsonStart..<jsonEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let jsonStart = response.range(of: "{"),
                  let jsonEnd = response.range(of: "}", options: .backwards) {
            jsonString = String(response[jsonStart.lowerBound...jsonEnd.upperBound])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parsingError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(AIWorkoutPlan.self, from: data)
    }

    private func parseMealPlan(from response: String) throws -> AIMealPlan {
        // Extract JSON from potential markdown code blocks
        var jsonString = response
        if let jsonStart = response.range(of: "```json")?.upperBound,
           let jsonEnd = response.range(of: "```", range: jsonStart..<response.endIndex)?.lowerBound {
            jsonString = String(response[jsonStart..<jsonEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let jsonStart = response.range(of: "{"),
                  let jsonEnd = response.range(of: "}", options: .backwards) {
            jsonString = String(response[jsonStart.lowerBound...jsonEnd.upperBound])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parsingError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(AIMealPlan.self, from: data)
    }
}

// MARK: - AI Models

struct AIWorkoutPlan: Codable {
    let name: String
    let description: String
    let exercises: [AIExercise]
}

struct AIExercise: Codable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double
    let restTime: Double
    let muscleGroups: [String]
    let equipment: String
}

struct AIMealPlan: Codable {
    let name: String
    let description: String
    let meals: [AIMeal]
}

struct AIMeal: Codable {
    let name: String
    let foods: [AIFood]
}

struct AIFood: Codable {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

// MARK: - AI Workout Template (stored in memory, not conflicting with existing WorkoutTemplate)
struct AIWorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [Exercise]

    init(id: UUID = UUID(), name: String, exercises: [Exercise]) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }

    func createWorkout() -> Workout {
        return Workout(name: name, exercises: exercises)
    }
}

// MARK: - Meal Template
struct MealTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var foods: [FoodEntry]

    init(id: UUID = UUID(), name: String, foods: [FoodEntry]) {
        self.id = id
        self.name = name
        self.foods = foods
    }
}

// MARK: - Template Store
class TemplateStore: ObservableObject {
    @Published var workoutTemplates: [AIWorkoutTemplate] = []
    @Published var mealTemplates: [MealTemplate] = []

    private let workoutTemplatesKey = "aiWorkoutTemplates"
    private let mealTemplatesKey = "aiMealTemplates"

    init() {
        loadTemplates()
    }

    // MARK: - Workout Templates
    func addWorkoutTemplate(_ template: AIWorkoutTemplate) {
        workoutTemplates.insert(template, at: 0)
        saveWorkoutTemplates()
    }

    func deleteWorkoutTemplate(_ template: AIWorkoutTemplate) {
        workoutTemplates.removeAll { $0.id == template.id }
        saveWorkoutTemplates()
    }

    private func saveWorkoutTemplates() {
        if let encoded = try? JSONEncoder().encode(workoutTemplates) {
            UserDefaults.standard.set(encoded, forKey: workoutTemplatesKey)
        }
    }

    // MARK: - Meal Templates
    func addMealTemplate(_ template: MealTemplate) {
        mealTemplates.insert(template, at: 0)
        saveMealTemplates()
    }

    func deleteMealTemplate(_ template: MealTemplate) {
        mealTemplates.removeAll { $0.id == template.id }
        saveMealTemplates()
    }

    private func saveMealTemplates() {
        if let encoded = try? JSONEncoder().encode(mealTemplates) {
            UserDefaults.standard.set(encoded, forKey: mealTemplatesKey)
        }
    }

    // MARK: - Load Templates
    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: workoutTemplatesKey),
           let decoded = try? JSONDecoder().decode([AIWorkoutTemplate].self, from: data) {
            workoutTemplates = decoded
        }

        if let data = UserDefaults.standard.data(forKey: mealTemplatesKey),
           let decoded = try? JSONDecoder().decode([MealTemplate].self, from: data) {
            mealTemplates = decoded
        }
    }
}

// MARK: - AI Errors
enum AIError: Error, LocalizedError {
    case apiKeyNotSet
    case invalidResponse
    case apiError(statusCode: Int)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "OpenAI API key not set. Please add your API key in AIAssistantModels.swift"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let statusCode):
            return "AI API error: Status code \(statusCode)"
        case .parsingError:
            return "Failed to parse AI response"
        }
    }
}
