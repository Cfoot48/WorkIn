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

        print("🎬 LottieView: Attempting to load animation: \(fileName)")

        // Try multiple loading strategies
        var animation: LottieAnimation? = nil

        // Strategy 1: Try loading by name (for .json files in bundle)
        print("🔍 Strategy 1: LottieAnimation.named(\"\(fileName)\")")
        animation = LottieAnimation.named(fileName)
        if animation != nil {
            print("✅ Loaded via named: \(fileName)")
        } else {
            print("❌ Strategy 1 failed")
        }

        // Strategy 2: Try with .json extension
        if animation == nil {
            print("🔍 Strategy 2: LottieAnimation.named(\"\(fileName)\", bundle: .main)")
            animation = LottieAnimation.named(fileName, bundle: .main)
            if animation != nil {
                print("✅ Loaded via named with bundle: \(fileName)")
            } else {
                print("❌ Strategy 2 failed")
            }
        }

        // Strategy 3: Try loading .lottie file as filepath
        if animation == nil {
            print("🔍 Strategy 3: Looking for resource \"\(fileName)\" with extension \"lottie\"")
            if let path = Bundle.main.path(forResource: fileName, ofType: "lottie") {
                print("🔍 Found .lottie file at: \(path)")
                animation = LottieAnimation.filepath(path)
                if animation != nil {
                    print("✅ Loaded via filepath: \(path)")
                } else {
                    print("❌ filepath() returned nil for: \(path)")
                }
            } else {
                print("❌ Bundle.main.path(forResource: \"\(fileName)\", ofType: \"lottie\") returned nil")
            }
        }

        // Strategy 4: Try without extension (in case it's already included)
        if animation == nil {
            print("🔍 Strategy 4: Looking for resource \"\(fileName)\" with no extension")
            if let path = Bundle.main.path(forResource: fileName, ofType: nil) {
                print("🔍 Found file without extension at: \(path)")
                animation = LottieAnimation.filepath(path)
                if animation != nil {
                    print("✅ Loaded via filepath no extension: \(path)")
                } else {
                    print("❌ filepath() returned nil for: \(path)")
                }
            } else {
                print("❌ Bundle.main.path(forResource: \"\(fileName)\", ofType: nil) returned nil")
            }
        }

        // Strategy 5: Try dotLottie format (for .lottie files)
        if animation == nil {
            print("🔍 Strategy 5: Trying DotLottieFile")
            // Try multiple variations of the filename
            let possibleNames = [
                (fileName, nil as String?),
                (fileName, "lottie"),
                (fileName + ".lottie", nil as String?)
            ]

            for (name, ext) in possibleNames {
                print("🔍 Trying Bundle.main.url(forResource: \"\(name)\", withExtension: \(ext ?? "nil"))")
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    print("🔍 Found URL: \(url.path)")

                    // Verify file exists
                    if FileManager.default.fileExists(atPath: url.path) {
                        print("✅ File exists at path")

                        // Try DotLottieFile with data initializer
                        do {
                            let data = try Data(contentsOf: url)
                            print("📦 Loaded \(data.count) bytes")

                            // For .lottie files, use DotLottieFile
                            if url.pathExtension == "lottie" {
                                print("🔍 Attempting DotLottieFile(data:)")
                                do {
                                    let dotLottie = try DotLottieFile(data: data)
                                    print("✅ Created DotLottieFile from data")

                                    if let anim = try dotLottie.animation() {
                                        animation = anim
                                        print("✅ Loaded animation from DotLottieFile!")
                                        break
                                    } else {
                                        print("❌ dotLottie.animation() returned nil")
                                    }
                                } catch {
                                    print("❌ DotLottieFile error: \(error.localizedDescription)")
                                }
                            }
                        } catch {
                            print("❌ Failed to load data: \(error.localizedDescription)")
                        }
                    } else {
                        print("❌ File doesn't exist at path")
                    }
                } else {
                    print("❌ URL not found for this combination")
                }
            }
        }

        if let animation = animation {
            animationView.animation = animation
        } else {
            print("❌ LottieView: Failed to load animation: \(fileName)")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
        }

        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFit
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
