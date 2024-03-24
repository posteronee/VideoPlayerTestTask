//
//  ContentView.swift
//  VideoPlayerTestTask
//
//  Created by Никита Иванов on 24.03.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader{ proxy in
            let size = proxy.size
            let viewEdge = proxy.safeAreaInsets
            MainView(size: size, viewEdge: viewEdge)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
