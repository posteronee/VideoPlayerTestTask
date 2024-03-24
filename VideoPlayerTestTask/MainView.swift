import SwiftUI
import AVKit

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

    var body: some View {
        VStack(spacing: 0) {
            let playerSize = CGSize(width: size.width, height: size.height / 3)

            ZStack {
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

    @ViewBuilder
    func DisplayButtons() -> some View {
        HStack {
            Button(action: {
                print("backward")
            }) {
                Image(systemName: "backward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }

            Button(action: {
                print("Play")
            }) {
                Image(systemName: "play.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }

            Button(action: {
                print("forward")
            }) {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
            
            Button(action: {
                print("fullscreen")
            }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
