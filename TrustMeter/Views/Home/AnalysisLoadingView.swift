//
//  AnalysisLoadingView.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct AnalysisLoadingView: View {
    @State private var animationStep = 0

    private let analyzingMessages = [
        "Inspecting product page",
        "Scanning metadata",
        "Calculating trust signals"
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color(.systemBackground),
                    Color.indigo.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    scanningIndicator

                    Text("Analyzing Product")
                        .font(.title2.bold())

                    Text(analyzingMessages[animationStep])
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(analyzingMessages.enumerated()), id: \.offset) { index, message in
                        analyzingStepRow(
                            number: index + 1,
                            message: message,
                            isActive: index == animationStep,
                            isComplete: index < animationStep
                        )
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                ProgressView(value: Double(animationStep + 1), total: Double(analyzingMessages.count))
                    .tint(.accentColor)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .interactiveDismissDisabled()
        .task {
            await animateSteps()
        }
    }

    private var scanningIndicator: some View {
        ZStack {
            Circle()
                .stroke(.tint.opacity(0.2), lineWidth: 12)
                .frame(width: 88, height: 88)

            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(.tint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 88, height: 88)
                .rotationEffect(.degrees(Double(animationStep) * 120))
                .animation(.easeInOut(duration: 0.45), value: animationStep)

            Image(systemName: "viewfinder")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.tint)
        }
    }

    private func analyzingStepRow(
        number: Int,
        message: String,
        isActive: Bool,
        isComplete: Bool
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(stepFillColor(isActive: isActive, isComplete: isComplete))
                    .frame(width: 34, height: 34)
                    .overlay {
                        Circle()
                            .stroke(stepBorderColor(isActive: isActive, isComplete: isComplete), lineWidth: 1)
                    }

                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isActive ? .white : .primary)
                }
            }
            .scaleEffect(isActive ? 1.08 : 1)
            .animation(.easeInOut(duration: 0.35), value: isActive)

            VStack(alignment: .leading, spacing: 2) {
                Text("Step \(number)")
                    .font(.subheadline.weight(.semibold))

                Text(message)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isActive {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private func stepFillColor(isActive: Bool, isComplete: Bool) -> Color {
        if isComplete || isActive {
            return .accentColor
        }

        return Color(.systemGray5)
    }

    private func stepBorderColor(isActive: Bool, isComplete: Bool) -> Color {
        if isComplete || isActive {
            return .accentColor
        }

        return Color(.systemGray4)
    }

    private func animateSteps() async {
        for step in analyzingMessages.indices {
            animationStep = step
            try? await Task.sleep(for: .milliseconds(1100))
        }
    }
}

struct AnalysisLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisLoadingView()
    }
}
