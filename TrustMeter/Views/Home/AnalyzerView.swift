//
//  AnalyzerView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct AnalyzerView: View {
    @State private var productURLText = ""
    @State private var showResult = false
    @State private var isAnalyzing = false
    @State private var animationStep = 0

    private let dummyResult = AnalysisResult.sample
    private let analyzingMessages = [
        "Inspecting product page",
        "Scanning metadata",
        "Calculating trust signals"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trust Meter")
                .font(.largeTitle.bold())

            Text("Paste a product url to analyze.")
                .foregroundStyle(.secondary)

            TextField("http://example.com/product", text: $productURLText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)
                .disabled(isAnalyzing)

            Button(action: startAnalysis) {
                Text(isAnalyzing ? "Analyzing..." : "Analyze")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAnalyzing || productURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if isAnalyzing {
                analyzingCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: isAnalyzing)
        .navigationDestination(isPresented: $showResult) {
            ResultView(result: dummyResult)
        }
    }

    private var analyzingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                scanningIndicator

                VStack(alignment: .leading, spacing: 4) {
                    Text("Analyzing")
                        .font(.headline)

                    Text(analyzingMessages[animationStep])
                        .foregroundStyle(.secondary)
                }
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

            ProgressView(value: Double(animationStep + 1), total: Double(analyzingMessages.count))
                .tint(.accentColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var scanningIndicator: some View {
        ZStack {
            Circle()
                .stroke(.tint.opacity(0.2), lineWidth: 10)
                .frame(width: 52, height: 52)

            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(.tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 52, height: 52)
                .rotationEffect(.degrees(Double(animationStep) * 120))
                .animation(.easeInOut(duration: 0.45), value: animationStep)

            Image(systemName: "viewfinder")
                .font(.title3.weight(.semibold))
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

    private func startAnalysis() {
        guard !isAnalyzing else { return }

        isAnalyzing = true
        animationStep = 0

        Task {
            for step in analyzingMessages.indices {
                await MainActor.run {
                    animationStep = step
                }

                try? await Task.sleep(for: .milliseconds(1100))
            }

            await MainActor.run {
                isAnalyzing = false
                showResult = true
            }
        }
    }
}

#Preview {
    AnalyzerView()
}
