//
//  ResultView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//

import SwiftUI

struct ResultView: View {
    let result: AnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Result")
                .font(.title.bold())

            Text("Total: \(result.scoreBreakdown.totalScore)")
                .font(.title2)

            Text("Price: \(result.scoreBreakdown.priceScore)/25")
            Text("Metadata: \(result.scoreBreakdown.metadataScore)/25")
            Text("Completeness: \(result.scoreBreakdown.completenessScore)/25")
            Text("Trust: \(result.scoreBreakdown.trustScore)/25")
        }
        .padding()
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ResultView(result: .sample)
}
