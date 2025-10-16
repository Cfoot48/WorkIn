import SwiftUI

struct MuscleGroupDiagram: View {
    let muscleGroupRanks: [String: StrengthRank] // Maps muscle group to its rank
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Base muscle silhouette image (gray outline)
            Image("muscle-silhouette")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .colorMultiply(DesignSystem.Colors.textSecondary(for: colorScheme).opacity(0.4))

            // Individual muscle overlays using mask images with rank colors
            ForEach(Array(muscleGroupRanks.keys.sorted()), id: \.self) { muscleGroup in
                if let rank = muscleGroupRanks[muscleGroup] {
                    MuscleHighlightMask(muscleGroup: muscleGroup, rank: rank)
                }
            }
        }
    }
}

struct MuscleHighlightMask: View {
    let muscleGroup: String
    let rank: StrengthRank
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let maskImageName = getMuscleMaskImageName(muscleGroup) {
            Image(maskImageName)
                .resizable()
                .renderingMode(.template) // Treat image as template to ignore original colors
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(rank.glowColor) // Apply rank color to template
                .opacity(0.8)
        }
    }

    private func getMuscleMaskImageName(_ group: String) -> String? {
        let normalizedGroup = group.lowercased()

        // Map muscle groups to their mask image names
        if normalizedGroup.contains("chest") || normalizedGroup.contains("pec") {
            return "chest-mask"
        }
        else if normalizedGroup.contains("shoulder") || normalizedGroup.contains("delt") {
            return "shoulders-mask"
        }
        else if normalizedGroup.contains("bicep") {
            return "biceps-mask"
        }
        else if normalizedGroup.contains("tricep") {
            return "triceps-mask"
        }
        else if normalizedGroup.contains("forearm") {
            return "forearms-mask"
        }
        else if normalizedGroup.contains("back") || normalizedGroup.contains("lat") || normalizedGroup.contains("trap") {
            return "back-mask"
        }
        else if normalizedGroup.contains("abductor") || normalizedGroup.contains("hip abductor") {
            return "abductors-mask"
        }
        else if normalizedGroup.contains("oblique") {
            return "obliques-mask"
        }
        else if normalizedGroup.contains("ab") || normalizedGroup.contains("core") {
            return "abs-mask"
        }
        else if normalizedGroup.contains("quad") || normalizedGroup.contains("thigh") {
            return "quads-mask"
        }
        else if normalizedGroup.contains("hamstring") {
            return "hamstrings-mask"
        }
        else if normalizedGroup.contains("glute") || normalizedGroup.contains("butt") {
            return "glutes-mask"
        }
        else if normalizedGroup.contains("cal") || normalizedGroup.contains("calf") {
            return "calves-mask"
        }
        else if normalizedGroup.contains("fibular") || normalizedGroup.contains("peroneal") {
            return "fibularis-mask"
        }
        else if normalizedGroup.contains("tibialis") || normalizedGroup.contains("shin") {
            return "tibialis-mask"
        }
        else {
            return nil
        }
    }
}

#Preview {
    VStack {
        MuscleGroupDiagram(muscleGroupRanks: ["Chest": .diamond, "Biceps": .gold])
            .frame(width: 200, height: 400)
            .padding()

        MuscleGroupDiagram(muscleGroupRanks: ["Biceps": .superman, "Shoulders": .platinum])
            .frame(width: 200, height: 400)
            .padding()
    }
}
