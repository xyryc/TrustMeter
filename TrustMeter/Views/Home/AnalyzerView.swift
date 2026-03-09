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
    private let trustChecks = [
        ("tag", "Price consistency"),
        ("doc.text.magnifyingglass", "Metadata quality"),
        ("checkmark.shield", "Trust signals")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                inputCard
                checksCard

                if isAnalyzing {
                    analyzingCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .background {
            Rectangle()
                .fill(backgroundGradient)
                .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.25), value: isAnalyzing)
        .navigationDestination(isPresented: $showResult) {
            ResultView(result: dummyResult)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trust Meter")
                        .font(.largeTitle.bold())

                    Text("Inspect any product page and get a fast trust score before you buy.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.blue.opacity(0.12))
                        .frame(width: 68, height: 68)

                    Image(systemName: "viewfinder")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }

            HStack(spacing: 10) {
                quickStat(title: "3 checks", subtitle: "core signals")
                quickStat(title: "Fast", subtitle: "instant preview")
            }
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Product URL", systemImage: "link")
                .font(.headline)

            TextField("http://example.com/product", text: $productURLText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .disabled(isAnalyzing)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button(action: startAnalysis) {
                HStack {
                    Image(systemName: isAnalyzing ? "hourglass" : "viewfinder.circle.fill")
                    Text(isAnalyzing ? "Analyzing..." : "Analyze Product")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(isAnalyzing || trimmedURL.isEmpty)
            .opacity(isAnalyzing || trimmedURL.isEmpty ? 0.65 : 1)
        }
        .cardStyle()
    }

    private var checksCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What we inspect")
                .font(.headline)

            ForEach(trustChecks, id: \.1) { check in
                HStack(spacing: 12) {
                    Image(systemName: check.0)
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(Color.accentColor)

                    Text(check.1)
                        .font(.subheadline.weight(.medium))

                    Spacer()
                }
            }
        }
        .cardStyle()
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

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.12),
                Color.clear,
                Color.indigo.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var buttonBackground: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.indigo],
            startPoint: .leading,
            endPoint: .trailing
        )
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

    private var trimmedURL: String {
        productURLText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func quickStat(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
