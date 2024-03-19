//
//  ImagePicker.swift
//  Module8
//
//  Created by Cenk Bilgen on 2024-03-08.
//

import SwiftUI
import PhotosUI

class PhotosState: ObservableObject {
    @Published var imagesSelection:[PhotosPickerItem] = [] {
        didSet {
            setImages(from: imagesSelection)
        }
    }
    
    @Published var images: [UIImage] = []
    
    private func setImages(from selections:[PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            
            for selection in selections{
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            
            self.images = images
        }
    }
}

struct ImagePicker: View {
    @StateObject var state = PhotosState()
    @State private var presentPhotos = false
    @State private var presentFiles = false
    @State private var showHistorySheet = false
    @State private var sheetHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack (alignment:.topTrailing) {
                if let latestImage = state.images.last {
                    Image(uiImage: latestImage)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6)
                        .ignoresSafeArea()
                        .aspectRatio(1, contentMode: .fit)
                    if state.images.count >= 2 {
                        Button (
                            action: {
                                showHistorySheet.toggle()
                            }, label: {
                                Text("Images History")
                                    .padding()
                                    .background(.blue)
                                    .foregroundStyle(.white)
                            }
                        )
                        .padding()
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            
            HStack(spacing: 10) {
                Button {
                    presentPhotos = true
                } label: {
                    Color.red
                        .overlay(Text("Get Photo"))
                }
                
                Button {
                    presentFiles = true
                } label: {
                    Color.yellow
                        .overlay(Text("Get File"))
                }
            }
            .foregroundColor(.primary)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
        }
        .ignoresSafeArea()
        .sheet(
            isPresented: $showHistorySheet,
            onDismiss: {},
            content: {
                HistorySheet(state: state, sheetHeight: $sheetHeight)
                    .presentationDetents([.fraction(0.3),.large])
                    .onAppear {
                        sheetHeight = UIScreen.main.bounds.height * 0.6
                    }
            }
        )
        .photosPicker(
            isPresented: $presentPhotos,
            selection: $state.imagesSelection,
            selectionBehavior: .continuousAndOrdered,
            matching: .images,
            preferredItemEncoding: .compatible
        )
        .fileImporter(
            isPresented: $presentFiles,
            allowedContentTypes: [.image]
        ) { result in
            switch result {
            case .success(let url):
                state.images.append(UIImage(contentsOfFile: url.path)!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct HistorySheet: View {
    @ObservedObject var state: PhotosState
    @Environment(\.dismiss) var dismiss
    @Binding var sheetHeight: CGFloat
    
    var body: some View {
        VStack {
            if sheetHeight <= UIScreen.main.bounds.height * 0.4 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(state.images.indices, id: \.self) { index in
                            Image(uiImage: state.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay {
                                    Image(systemName: "xmark.bin.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .onTapGesture {
                                            state.images.remove(at: index)
                                        }
                                }
                        }
                    }
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(state.images.indices, id: \.self) { index in
                        Image(uiImage: state.images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay {
                                Image(systemName: "xmark.bin.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        state.images.remove(at: index)
                                    }
                            }
                    }
                }
            }
        }
        .onChange(of: state.images) {
            if state.images.isEmpty {
                dismiss()
            }
        }
    }
}





struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        ImagePicker()
    }
}
