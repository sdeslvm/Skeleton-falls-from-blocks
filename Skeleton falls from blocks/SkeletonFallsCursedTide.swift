import Foundation
import SwiftUI

struct SkeletonFallsEntryScreen: View {
    @StateObject private var loader: SkeletonFallsWebLoader

    init(loader: SkeletonFallsWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            SkeletonFallsWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                SkeletonFallsProgressIndicator(value: percent)
            case .failure(let err):
                SkeletonFallsErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                SkeletonFallsOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct SkeletonFallsProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            SkeletonFallsLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct SkeletonFallsErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct SkeletonFallsOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
