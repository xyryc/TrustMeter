//
//  ScoreRing.swift
//  TrustMeter
//
//  Created by Codex on 9/3/26.
//

import SwiftUI

struct ScoreRing: View {
    let score: Int
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: 10)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.title2.bold())

                Text("/100")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 92, height: 92)
    }
}
