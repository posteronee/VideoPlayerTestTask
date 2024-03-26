import SwiftUI
import AVKit

struct MainView: View {
    var size: CGSize
    var viewEdge: EdgeInsets

    @State private var player: AVPlayer? = {
        guard let path = Bundle.main.path(forResource: "video", ofType: "mp4") else {
            return nil }
        return AVPlayer(url: URL(fileURLWithPath: path))
    }()

    @State private var showButtons = false
    @State private var isPlaying = false
    @State private var isFullScreen = false
    @State private var buttonsTimer: Timer?

    var body: some View {
        let playerSize = CGSize(width: size.width, height: size.height / 3)

        ZStack(alignment: .topTrailing) {
            if let player = player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        showButtons.toggle()
                        startButtonsTimer()
                    }
                    .edgesIgnoringSafeArea(isFullScreen ? .all : [])
                    .onDisappear {
                        player.pause()
                    }
                    .onAppear {
                        if isPlaying && isFullScreen {
                            player.play()
                        }
                    }

                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .opacity((showButtons || !isPlaying) ? 1 : 0)
                    .overlay {
                        if showButtons || !isPlaying {
                            DisplayButtons()
                        }
                    }
                    .edgesIgnoringSafeArea(isFullScreen ? .all : [])
            }
        }
        .frame(width: playerSize.width, height: isFullScreen ? size.height : playerSize.height)
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
                switch isPlaying {
                case true:
                    player?.pause()
                case false:
                    player?.play()
                    isFullScreen ? nil : ButtonsTimeOut()
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
            }
        }
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isFullScreen.toggle()
                    if isPlaying && isFullScreen {
                        player?.play()
                    } else if !isPlaying && !isFullScreen {
                        player?.pause()
                    }
                }) {
                    Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(20)
            }
            Spacer()
            .frame(maxWidth: .infinity)
        }
    }

    func startButtonsTimer() {
        buttonsTimer?.invalidate()
        buttonsTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            showButtons = false
        }
    }

    func ButtonsTimeOut() {
        startButtonsTimer()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
