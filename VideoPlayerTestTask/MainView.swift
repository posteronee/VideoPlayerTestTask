import SwiftUI
import AVKit
// почти доделал режим fullscreen, нужно будет добавить перемотку ползунком и поправить архитектуру
struct MainView: View {
    var size: CGSize
    var viewEdge: EdgeInsets

    @State private var player: AVPlayer? = {
        guard let path = Bundle.main.path(forResource: "video", ofType: "mp4") else {
            return nil }
        return AVPlayer(url: URL(filePath: path))
    }()

    @State private var showButtons = false
    @State private var isPlaying = false
    @State private var timeOut: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            let playerSize = CGSize(width: size.width, height: size.height / 3)

            ZStack(alignment: .topTrailing) {
                if let player = player {
                    VideoPlayer(player: player)
                        .overlay(
                            Rectangle()
                                .fill(Color.black.opacity(0.3))
                                .opacity(showButtons ? 1 : 0)
                                .overlay{
                                    if showButtons{
                                        DisplayButtons()
                                    }
                                }
                        )
                        .onTapGesture {
                            showButtons.toggle()
                        }
                    
                }
            }
            .frame(width: playerSize.width, height: playerSize.height)
        }
    }

    @ViewBuilder func DisplayButtons() -> some View {
        HStack {
            Button(action: {
                if let player = player {
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    let newTime = currentTime - 10.0
                    let time = CMTime(value: Int64(newTime * 1000), timescale: 1000)
                    player.seek(to: time)
                }
            }) {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }

            Button(action: {
                switch isPlaying{
                    case true:
                        player?.pause()
                    case false:
                        player?.play()
                        ButtonsTimeOut()
                    
                }
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(20)
            }

            Button(action: {
                if let player = player {
                    let currentTime = CMTimeGetSeconds(player.currentTime())
                    let newTime = currentTime + 10.0
                    let time = CMTime(value: Int64(newTime * 1000), timescale: 1000)
                    player.seek(to: time)
                }
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    
            }        }
        .frame(maxWidth: .infinity)
        
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    print("fullscreen")
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(20)
            }
            Spacer()
        }
    }
    func ButtonsTimeOut() {
        if let timeOut{
            timeOut.cancel()
        }
        
        timeOut = DispatchWorkItem{
            showButtons = false
        }
        
        if let timeOut{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeOut)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
