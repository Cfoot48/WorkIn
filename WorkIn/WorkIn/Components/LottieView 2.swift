import SwiftUI
#if canImport(Lottie)
import Lottie

struct LottieView: UIViewRepresentable {
    let fileName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat

    init(fileName: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1.0) {
        self.fileName = fileName
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()

        print("🎬 LottieView 2: Attempting to load animation: \(fileName)")

        var animation: LottieAnimation?

        // Method 1: Try loading by name (for JSON files)
        print("🔍 Method 1: LottieAnimation.named(\"\(fileName)\")")
        animation = LottieAnimation.named(fileName)
        if animation != nil {
            print("✅ Loaded using LottieAnimation.named")
        }

        // Method 2: Try with filepath and json extension
        if animation == nil {
            print("🔍 Method 2: Looking for JSON file")
            if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
                print("🔍 Found JSON at: \(path)")
                animation = LottieAnimation.filepath(path)
                if animation != nil {
                    print("✅ Loaded from filepath with .json: \(path)")
                }
            }
        }

        // Method 3: Try with filepath without extension
        if animation == nil {
            print("🔍 Method 3: Looking for file without extension")
            if let path = Bundle.main.path(forResource: fileName, ofType: nil) {
                print("🔍 Found file at: \(path)")
                animation = LottieAnimation.filepath(path)
                if animation != nil {
                    print("✅ Loaded from filepath: \(path)")
                }
            }
        }

        // Method 4: Try .lottie file with extension
        if animation == nil {
            print("🔍 Method 4: Looking for .lottie file")
            if let path = Bundle.main.path(forResource: fileName, ofType: "lottie") {
                print("🔍 Found .lottie file at: \(path)")
                animation = LottieAnimation.filepath(path)
                if animation != nil {
                    print("✅ Loaded from .lottie filepath")
                } else {
                    print("❌ filepath() couldn't parse .lottie file")
                }
            } else {
                print("❌ No .lottie file found for: \(fileName)")
            }
        }

        if let animation = animation {
            animationView.animation = animation
            print("🎉 Animation loaded successfully!")
        } else {
            print("❌ Failed to load animation: \(fileName)")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")

            // List all files in bundle for debugging
            if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath) {
                let lottieFiles = files.filter { $0.contains("lottie") || $0.contains("Lottie") || $0.contains("WorkIn") }
                print("📋 Lottie-related files in bundle: \(lottieFiles)")
            }
        }

        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .clear
        animationView.play()

        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Update if needed
    }
}
#else
// Fallback when Lottie is not available
struct LottieView: View {
    let fileName: String
    let loopMode: Any
    let animationSpeed: CGFloat

    init(fileName: String, loopMode: Any = 0, animationSpeed: CGFloat = 1.0) {
        self.fileName = fileName
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }

    var body: some View {
        // Temporary placeholder
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 30)

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundColor(Color.orange)
        }
    }
}
#endif
