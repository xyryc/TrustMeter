//
//  AnalyzerView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct AnalyzerView: View {
    @State private var productURLText = ""
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text("Trust Meter").font(.largeTitle.bold())
            
            Text("Paste a product url to analyze.").foregroundStyle(.secondary)
            
            TextField("http://example.com/product", text: $productURLText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.URL)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(.red, lineWidth: 1)
        )
    }
}

#Preview {
    AnalyzerView()
}

