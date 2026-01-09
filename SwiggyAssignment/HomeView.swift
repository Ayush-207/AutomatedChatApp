//
//  HomeView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 09/01/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink(destination: ChatView()) {
                    Text("Open Chat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
