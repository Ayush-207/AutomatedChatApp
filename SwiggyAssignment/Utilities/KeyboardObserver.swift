//
//  KeyboardObserver.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 12/01/26.
//

import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        let willShow = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillShowNotification
        )
        let willHide = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillHideNotification
        )

        Publishers.Merge(willShow, willHide)
            .sink { notification in
                let frame = notification
                    .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                self.height = notification.name == UIResponder.keyboardWillHideNotification
                    ? 0
                    : frame?.height ?? 0
                
                print("LOGS:: keyboard height: \(self.height)")
            }
            .store(in: &cancellables)
    }
}
