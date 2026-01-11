//
//  TypingIndicatorView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationOffsets: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffsets[index])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        for index in 0..<3 {
            withAnimation(
                Animation
                    .easeInOut(duration: 0.6)
                    .repeatForever()
                    .delay(Double(index) * 0.2)
            ) {
                if animationOffsets[index] < 0 {
                    animationOffsets[index] = 0
                } else {
                    animationOffsets[index] = -4
                }
            }
        }
    }
}

#Preview {
    TypingIndicatorView()
}
