//
//  AnalyzerView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct AnalyzerView: View {
    @StateObject private var viewModel = AnalyzerViewModel()
    @State private var productURLText = ""
    @State private var showResult = false
    @State private var showAnalyzingScreen = false
    @FocusState private var isURLFieldFocused: Bool

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

                Spacer(minLength: 0)
            }
            .padding()
        }
        .background {
            Rectangle()
                .fill(backgroundGradient)
                .ignoresSafeArea()
        }
        .navigationDestination(isPresented: $showResult) {
            if let result = viewModel.latestResult {
                ResultView(result: result)
            }
        }
        .fullScreenCover(isPresented: $showAnalyzingScreen) {
            AnalysisLoadingView()
        }
        .alert("Analysis Failed", isPresented: errorAlertBinding) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .onReceive(viewModel.$latestResult) { result in
            if result != nil {
                showAnalyzingScreen = false
                showResult = true
            }
        }
        .onReceive(viewModel.$isAnalyzing) { isAnalyzing in
            showAnalyzingScreen = isAnalyzing
        }
        .onReceive(viewModel.$errorMessage) { errorMessage in
            if errorMessage != nil {
                showAnalyzingScreen = false
            }
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
                .submitLabel(.go)
                .focused($isURLFieldFocused)
                .disabled(viewModel.isAnalyzing)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onSubmit {
                    startAnalysis()
                }

            Button(action: startAnalysis) {
                HStack {
                    Image(systemName: viewModel.isAnalyzing ? "hourglass" : "viewfinder.circle.fill")
                    Text(viewModel.isAnalyzing ? "Analyzing..." : "Analyze Product")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(viewModel.isAnalyzing || trimmedURL.isEmpty)
            .opacity(viewModel.isAnalyzing || trimmedURL.isEmpty ? 0.65 : 1)
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

    private var trimmedURL: String {
        productURLText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
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
        guard !viewModel.isAnalyzing else { return }
        guard !trimmedURL.isEmpty else { return }

        isURLFieldFocused = false

        Task {
            await viewModel.analyze(
                urlText: trimmedURL,
                minimumDuration: .milliseconds(3300)
            )
        }
    }
}

struct AnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzerView()
    }
}
