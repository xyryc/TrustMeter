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
        ("tag", "Price consistency", "Detects visible price and currency details."),
        ("doc.text.magnifyingglass", "Metadata quality", "Checks product title, description, and page metadata."),
        ("checkmark.shield", "Trust signals", "Looks for HTTPS, schema, and availability details.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                inputCard
                checksCard
                footerNote
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
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trust Meter")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text("Analyze a product page before you buy and turn messy store pages into a simple trust score.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.18), Color.indigo.opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 86, height: 86)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                        .frame(width: 68, height: 68)

                    Image(systemName: "viewfinder")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }

            HStack(spacing: 12) {
                quickStat(title: "3", subtitle: "signal groups")
                quickStat(title: "Live", subtitle: "URL analysis")
                quickStat(title: "Fast", subtitle: "one tap flow")
            }
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Analyze a product page", systemImage: "link")
                    .font(.headline)

                Text("Paste any store product URL below to inspect pricing, metadata, and trust indicators.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("http://example.com/product", text: $productURLText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .submitLabel(.go)
                .focused($isURLFieldFocused)
                .disabled(viewModel.isAnalyzing)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.blue.opacity(0.12), lineWidth: 1)
                }
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
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(viewModel.isAnalyzing || trimmedURL.isEmpty)
            .opacity(viewModel.isAnalyzing || trimmedURL.isEmpty ? 0.65 : 1)

            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(.secondary)

                Text("Your analysis runs only when you press the button.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 18, y: 10)
    }

    private var checksCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What gets checked")
                .font(.headline)

            ForEach(trustChecks, id: \.1) { check in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: check.0)
                        .frame(width: 34, height: 34)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(Color.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(check.1)
                            .font(.subheadline.weight(.semibold))

                        Text(check.2)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

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
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3.bold())

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var footerNote: some View {
        Text("Best results come from direct product pages, not category or search pages.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
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
