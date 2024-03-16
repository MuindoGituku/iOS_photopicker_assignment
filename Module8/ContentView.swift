//
//  ContentView.swift
//  Module8
//
//  Created by Cenk Bilgen on 2024-03-08.
//

import SwiftUI

class NumberModel: ObservableObject {
    @Published var n = 5
}

enum SheetColor: Int, Identifiable {
    case r = 100, g = 200, b = 300

    var id: Int {
        rawValue
    }
}

struct ContentView: View {
    @StateObject var model = NumberModel()

    // @State var presentSheet = false

    @State var presentColor: SheetColor? = nil

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button(action: {
                // presentSheet = false
                presentColor = .g
            }, label: {
                Text("Say Hello in Green")
                    .padding()
            })
            .border(.blue)
        }
        .padding()
        .fullScreenCover(item: $presentColor) { colorValue in
            switch colorValue {
                case .g:
                    SheetView(color: .green)
                case .r:
                    SheetView(color: .red)
                default:
                    SheetView(color: .gray)
            }

        }
//        .fullScreenCover(isPresented: $presentSheet) {
//            SheetView(color: .yellow)
//        }
//        .environmentObject(model)
    }

    struct SheetView: View {
        // @Binding var presentSheet: Bool
        @Environment(\.dismiss) var dismiss
        let color: Color

        var body: some View {
            color
                .overlay(Text("Hello Word"))
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                    // presentSheet = false
                }
        }
    }
}

#Preview {
    ContentView()
}
