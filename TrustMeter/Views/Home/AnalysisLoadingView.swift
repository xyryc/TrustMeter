//
//  AnalysisLoadingView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct AnalysisLoadingView: View {
    let totalDuration: Double
    @State private var animationStep = 0
    @State private var activeDetailIndex = 0
    private let accentColor = Color(hex: "71C9CE")

    private let loadingSteps = [
        LoadingStep(
            title: "Step 1",
            messages: [
                "Opening the product page",
                "Reading storefront response",
                "Preparing content for inspection"
            ]
        ),
        LoadingStep(
            title: "Step 2",
            messages: [
                "Scanning metadata tags",
                "Checking pricing and availability",
                "Matching structured product fields"
            ]
        ),
        LoadingStep(
            title: "Step 3",
            messages: [
                "Calculating score signals",
                "Weighing trust and confidence",
                "Preparing your final result"
            ]
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analyzing Product")
                        .font(.title2.bold())

                    Text("Each step completes one by one before moving to the next.")
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    ForEach(Array(loadingSteps.enumerated()), id: \.offset) { index, step in
                        VStack(spacing: 10) {
                            StepBlockView(
                                number: index + 1,
                                title: step.title,
                                message: displayedMessage(for: index),
                                isActive: index == animationStep,
                                isComplete: index < animationStep,
                                accentColor: accentColor
                            )

                            if index < loadingSteps.count - 1 {
                                Image(systemName: "chevron.down")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(index == animationStep ? accentColor : Color(.systemGray3))
                                    .frame(height: 18)
                                    .animation(.easeInOut(duration: 0.35), value: animationStep)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .interactiveDismissDisabled()
        .task {
            await animateSteps()
        }
    }

    private func displayedMessage(for index: Int) -> String {
        let step = loadingSteps[index]

        if index < animationStep {
            return step.messages.last ?? ""
        }

        if index == animationStep {
            return step.messages[activeDetailIndex]
        }

        return step.messages.first ?? ""
    }

    private func animateSteps() async {
        let stepCount = Double(loadingSteps.count)
        let stepDuration = totalDuration / stepCount

        for step in loadingSteps.indices {
            let detailMessages = loadingSteps[step].messages
            let detailDuration = stepDuration / Double(detailMessages.count)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animationStep = step
                    activeDetailIndex = 0
                }
            }

            for detailIndex in detailMessages.indices {
                if detailIndex > 0 {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            activeDetailIndex = detailIndex
                        }
                    }
                }

                let nanoseconds = UInt64(detailDuration * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
            }
        }
    }
}

private struct LoadingStep {
    let title: String
    let messages: [String]
}

private struct StepBlockView: View {
    let number: Int
    let title: String
    let message: String
    let isActive: Bool
    let isComplete: Bool
    let accentColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(badgeFillColor)
                    .frame(width: 46, height: 46)

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isActive ? .white : .primary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                ZStack(alignment: .leading) {
                    Text(message)
                        .id(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .clipped()
                .animation(.easeInOut(duration: 0.4), value: message)
            }

            Spacer()

            if isActive {
                ProgressView()
                    .tint(accentColor)
                    .controlSize(.small)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(blockBackgroundColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(blockBorderColor, lineWidth: isActive ? 1.5 : 0.5)
        }
        .scaleEffect(isActive ? 1 : 0.98)
        .animation(.easeInOut(duration: 0.35), value: isActive)
        .animation(.easeInOut(duration: 0.35), value: isComplete)
    }

    private var badgeFillColor: Color {
        if isComplete || isActive {
            return accentColor
        }

        return Color(.systemGray5)
    }

    private var blockBackgroundColor: Color {
        if isActive {
            return accentColor.opacity(0.10)
        }

        if isComplete {
            return accentColor.opacity(0.06)
        }

        return Color(.secondarySystemBackground)
    }

    private var blockBorderColor: Color {
        if isActive || isComplete {
            return accentColor.opacity(0.35)
        }

        return Color(.separator)
    }
}

struct AnalysisLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisLoadingView(totalDuration: 12)
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
