//
//  MessageInputView.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//

import SwiftUI
import Combine

struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    var isTextFieldFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = viewModel.selectedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.selectedImage = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    isTextFieldFocused.wrappedValue = false
                    viewModel.showActionSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
                
                TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)
                    .focused(isTextFieldFocused)
                
                Button(action: {
                    if viewModel.selectedImage != nil {
                        viewModel.sendImageMessage()
                    } else {
                        viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.isMessageValid ? .blue : .gray)
                }
                .disabled(!viewModel.isMessageValid)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .confirmationDialog("Choose Image Source", isPresented: $viewModel.showActionSheet) {
            Button("Camera") {
                viewModel.openCamera()
            }
            Button("Photo Library") {
                viewModel.openPhotoLibrary()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: viewModel.imageSourceType)
        }
    }
}
