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
    
    //slider states
    @State private var isSeeking = false
    @State private var isVideoEnded = false
    @State private var progress: CGFloat = 0.0
    @State private var lastProgress: CGFloat = 0.0
    @GestureState private var isMoving = false

    var body: some View {
        let playerSize = CGSize(width: size.width, height: size.height / 3)

        ZStack(alignment: .topTrailing) {
            if let player = player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        showButtons.toggle()
                        startButtonsTimer()
                    }
                    .overlay(alignment: .bottom){
                        sliderView(videoSize: playerSize)
                            .alignmentGuide(.bottom) { _ in
                                return isFullScreen ? viewEdge.bottom + playerSize.height : 0
                            }
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
                            displayButtons()
                        }
                    }
                    .edgesIgnoringSafeArea(isFullScreen ? .all : [])
            }
        }
        .onAppear{
            player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1, preferredTimescale: 1), queue: .main) {time in
                if let currentVideo = player?.currentItem{
                    let totalDuration = currentVideo.duration.seconds
                    guard let currentDuration = player?.currentTime().seconds else {return}
                    let currentProgress = currentDuration / totalDuration
                    if !isSeeking {
                        progress = currentProgress
                        lastProgress = progress
                    }
                    if currentProgress == 1{
                        isVideoEnded = true
                        isPlaying = false
                    }
                }
            }
        }
        .frame(width: playerSize.width, height: isFullScreen ? size.height : playerSize.height)
    }

    @ViewBuilder func displayButtons() -> some View {
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
                    isFullScreen ? nil : buttonsTimeOut()
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

    func buttonsTimeOut() {
        startButtonsTimer()
    }
    
    @ViewBuilder func sliderView(videoSize: CGSize) -> some View {
        ZStack(alignment: .leading){
            Rectangle()
                .fill(.gray)
            Rectangle()
                .fill(.red)
                .frame(width: videoSize.width * progress)
            
        }.frame(height: 3)
            .overlay(alignment: .leading){
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: videoSize.width * progress)
                    .scaleEffect(showButtons || isMoving ? 1 : 0)
                    .gesture(
                        DragGesture()
                            .updating($isMoving) { _, out, _ in out = true}
                            .onChanged { value in
                                let x = value.translation.width
                                let newProgress = x / videoSize.width + lastProgress
                                self.progress = newProgress
                                isSeeking = true
                            }
                            .onEnded{ value in
                                lastProgress = progress
                                if let currentVideo = player?.currentItem{
                                    let totalDuration = currentVideo.duration.seconds
                                    player?.seek(to: CMTime(seconds: totalDuration * progress, preferredTimescale: 1))
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isSeeking = false
                                }
                            }
                    
                    )
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
