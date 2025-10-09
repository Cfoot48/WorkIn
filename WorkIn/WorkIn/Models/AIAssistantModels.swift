import Foundation

// MARK: - AI Assistant Service
class AIAssistantService {
    static let shared = AIAssistantService()

    private var apiKey: String = ""
    private let apiURL = "https://openrouter.ai/api/v1/chat/completions"

    init() {
        // Load API key from UserDefaults
        if let savedKey = UserDefaults.standard.string(forKey: "openai_api_key") {
            apiKey = savedKey
        } else {
            // Set default API key
            let defaultKey = "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"
            apiKey = defaultKey
            UserDefaults.standard.set(defaultKey, forKey: "openai_api_key")
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

        let response = try await callOpenAI(prompt: prompt, systemMessage: "You are a professional fitness coach. You MUST respond with ONLY valid JSON - no markdown formatting, no code blocks, no explanations. Just raw JSON matching the exact format provided in the prompt.")

        return try parseWorkoutPlan(from: response)
    }

    // MARK: - Generate Meal Plan
    func generateMealPlan(userProfile: UserProfile, preferences: String?) async throws -> AIMealPlan {
        let prompt = buildMealPrompt(userProfile: userProfile, preferences: preferences)

        let response = try await callOpenAI(prompt: prompt, systemMessage: "You are a professional nutritionist. You MUST respond with ONLY valid JSON - no markdown formatting, no code blocks, no explanations. Just raw JSON matching the exact format provided in the prompt.")

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

        IMPORTANT: Respond ONLY with valid JSON in this exact format (no markdown, no explanations):
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

        Create a complete workout with 6-8 exercises. All fields are required except description (optional).
        """

        return prompt
    }

    private func buildMealPrompt(userProfile: UserProfile, preferences: String?) -> String {
        var prompt = """
        Create 5 healthy meal/recipe ideas for me based on the following information:

        User Profile:
        - Goal: \(userProfile.goalType.rawValue)
        - Daily Calorie Goal: \(userProfile.dailyCalories) calories
        - Daily Protein Goal: \(userProfile.dailyProtein)g protein

        """

        if let prefs = preferences, !prefs.isEmpty {
            prompt += "Additional Preferences: \(prefs)\n"
        }

        prompt += """

        IMPORTANT: Respond ONLY with valid JSON in this exact format (no markdown, no explanations):
        {
          "meals": [
            {
              "name": "Recipe Name",
              "description": "Brief 1-2 sentence description of the meal",
              "ingredients": [
                "1 cup chicken breast, diced",
                "2 cups brown rice",
                "1 tbsp olive oil"
              ],
              "instructions": [
                "Heat oil in a pan over medium heat",
                "Add chicken and cook until golden brown",
                "Serve over rice"
              ],
              "servings": 1,
              "totalCalories": 450,
              "totalProtein": 35,
              "totalCarbs": 45,
              "totalFat": 12
            }
          ]
        }

        Create exactly 5 diverse meal/recipe ideas. Each meal should:
        - Be a complete recipe with ingredients and instructions
        - Fit within the user's macro goals (each meal should be reasonable for their daily totals)
        - Include accurate nutritional information
        - Have clear, easy-to-follow instructions
        - Use common ingredients

        All fields are required. The instructions should be brief but clear steps.
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
        request.setValue("https://github.com/WorkIn-App", forHTTPHeaderField: "HTTP-Referer")

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
        print("🤖 AI Response: \(response)")

        // The response is already clean JSON, just trim whitespace
        let jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)

        print("🤖 Extracted JSON: \(jsonString)")

        guard let data = jsonString.data(using: .utf8) else {
            print("🤖 ERROR: Failed to convert JSON string to data")
            throw AIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            let plan = try decoder.decode(AIWorkoutPlan.self, from: data)
            print("🤖 Successfully decoded workout plan: \(plan.name)")
            return plan
        } catch let DecodingError.keyNotFound(key, context) {
            print("🤖 ERROR: Missing key '\(key.stringValue)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("🤖 ERROR: Type mismatch for type '\(type)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("🤖 ERROR: Value not found for type '\(type)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch {
            print("🤖 ERROR: Failed to decode JSON: \(error)")
            print("🤖 ERROR Details: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("🤖 Decoding Error: \(decodingError)")
            }
            throw AIError.parsingError
        }
    }

    private func parseMealPlan(from response: String) throws -> AIMealPlan {
        print("🍽️ AI Response: \(response)")

        // The response is already clean JSON, just trim whitespace
        let jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)

        print("🍽️ Extracted JSON: \(jsonString)")

        guard let data = jsonString.data(using: .utf8) else {
            print("🍽️ ERROR: Failed to convert JSON string to data")
            throw AIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            let plan = try decoder.decode(AIMealPlan.self, from: data)
            print("🍽️ Successfully decoded meal plan: \(plan.name)")
            return plan
        } catch let DecodingError.keyNotFound(key, context) {
            print("🍽️ ERROR: Missing key '\(key.stringValue)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("🍽️ ERROR: Type mismatch for type '\(type)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("🍽️ ERROR: Value not found for type '\(type)' - \(context.debugDescription)")
            throw AIError.parsingError
        } catch {
            print("🍽️ ERROR: Failed to decode JSON: \(error)")
            print("🍽️ ERROR Details: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("🍽️ Decoding Error: \(decodingError)")
            }
            throw AIError.parsingError
        }
    }
}

// MARK: - AI Models

struct AIWorkoutPlan: Codable {
    let name: String
    let description: String?
    let exercises: [AIExercise]
}

struct AIExercise: Codable {
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double?
    let restTime: Double?
    let muscleGroups: [String]?
    let equipment: String?

    enum CodingKeys: String, CodingKey {
        case name, sets, reps, weight, restTime, muscleGroups, equipment
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decode(Int.self, forKey: .sets)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try? container.decode(Double.self, forKey: .weight)
        restTime = try? container.decode(Double.self, forKey: .restTime)
        muscleGroups = try? container.decode([String].self, forKey: .muscleGroups)
        equipment = try? container.decode(String.self, forKey: .equipment)
    }
}

struct AIMealPlan: Codable {
    let meals: [AIMeal]

    // For compatibility, provide a default name
    var name: String {
        return "AI-Generated Meal Plan"
    }
}

struct AIMeal: Codable {
    let name: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let servings: Int
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
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
    var ingredients: [String]?
    var instructions: [String]?
    var servings: Int?

    init(id: UUID = UUID(), name: String, foods: [FoodEntry], ingredients: [String]? = nil, instructions: [String]? = nil, servings: Int? = nil) {
        self.id = id
        self.name = name
        self.foods = foods
        self.ingredients = ingredients
        self.instructions = instructions
        self.servings = servings
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
        print("📝 TemplateStore: Adding template '\(template.name)' with \(template.exercises.count) exercises")
        workoutTemplates.insert(template, at: 0)
        print("📝 TemplateStore: Total templates after insert: \(workoutTemplates.count)")
        saveWorkoutTemplates()
        print("📝 TemplateStore: Saved to UserDefaults")
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
        print("📂 TemplateStore: Loading templates from UserDefaults")
        if let data = UserDefaults.standard.data(forKey: workoutTemplatesKey),
           let decoded = try? JSONDecoder().decode([AIWorkoutTemplate].self, from: data) {
            workoutTemplates = decoded
            print("📂 TemplateStore: Loaded \(workoutTemplates.count) workout templates")
        } else {
            print("📂 TemplateStore: No workout templates found in UserDefaults")
        }

        if let data = UserDefaults.standard.data(forKey: mealTemplatesKey),
           let decoded = try? JSONDecoder().decode([MealTemplate].self, from: data) {
            mealTemplates = decoded
            print("📂 TemplateStore: Loaded \(mealTemplates.count) meal templates")
        } else {
            print("📂 TemplateStore: No meal templates found in UserDefaults")
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
            return "OpenAI API key not set. Please add your API key in settings."
        case .invalidResponse:
            return "The AI service returned an invalid response. Please try again."
        case .apiError(let statusCode):
            if statusCode == 401 {
                return "Invalid API key. Please check your OpenRouter API key."
            } else if statusCode == 429 {
                return "Too many requests. Please wait a moment and try again."
            } else if statusCode == 500 {
                return "AI service error. Please try again later."
            } else {
                return "AI service error (code \(statusCode)). Please try again."
            }
        case .parsingError:
            return "The AI generated an invalid workout plan. Please try again with different preferences or simpler instructions."
        }
    }
}
