//
//  MainView.swift
//  VideoPlayerTestTask
//
//  Created by Никита Иванов on 24.03.2024.
//

import SwiftUI
import AVKit



struct MainView: View {
    var size: CGSize
    var viewEdge: EdgeInsets
    @State private var player: AVPlayer? =
    {
        guard let path = Bundle.main.path(forResource: "video", ofType: "mp4") else {return nil}
        return AVPlayer(url: URL(filePath: path))
    }()
    
    
    var body: some View {
        VStack ( spacing: 0){
            let playerSize = CGSize(width: size.width, height: size.height / 3)
            if let player {
                VideoPlayer(player: player)
            }
            
        }
    
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
