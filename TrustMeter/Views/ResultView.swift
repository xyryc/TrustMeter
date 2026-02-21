//
//  ResultView.swift
//  TrustMeter
//
//  Created by Anik on 21/2/26.
//
import SwiftUI

struct ResultView: View{
    let totalScore: Int
    let priceScore: Int
    let metaDataScore: Int
    let completenessScore: Int
    let trustScore: Int
    
    var body: some View{
        VStack(){
            Text("Result")
                .font(.title.bold())
            
            Text("Total: \(totalScore)")
                .font(.title2)
            
            Text("Price: \(priceScore)/25")
            Text("Metadata: \(metaDataScore)/25")
            Text("Completeness: \(completenessScore)/25")
            Text("Trust: \(trustScore)/25")
            
            Spacer()
        }
        .padding()
    }
}

#Preview{
    ResultView(
        totalScore: 85,
        priceScore: 20,
        metaDataScore: 50,
        completenessScore: 20,
        trustScore: 60
    )
}
