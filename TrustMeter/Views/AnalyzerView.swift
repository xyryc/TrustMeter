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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text("Trust Meter").font(.largeTitle.bold())
            
            Text("Paste a product url to analyze.").foregroundStyle(.secondary)
            
            TextField("http://example.com/product", text: $productURLText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)
            
            Button("Analyze"){
                showResult = true
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $showResult){
            ResultView(totalScore: 10, priceScore: 20, metaDataScore: 30, completenessScore: 40, trustScore: 50)
        }
    }
}

#Preview {
    AnalyzerView()
}

