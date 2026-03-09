//
//  ScoreBarRow.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct ScoreBarRow: View {
    let title: String
    let score: Int
    let tint: Color
    var hidesHeader: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !hidesHeader {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Spacer()

                    Text("\(score)/25")
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(Color(.tertiarySystemFill))

                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.7), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * (CGFloat(score) / 25))
                }
            }
            .frame(height: 10)
        }
    }
}
