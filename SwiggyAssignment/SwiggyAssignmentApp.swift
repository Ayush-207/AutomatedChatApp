//
//  SwiggyAssignmentApp.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 09/01/26.
//

import SwiftUI
import SwiftData

@main
struct SwiggyChatApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(StorageService.shared.container)
    }
}
