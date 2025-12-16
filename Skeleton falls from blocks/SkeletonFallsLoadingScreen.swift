import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

// MARK: - Interactive Blocks Scene

struct InteractiveBlocksView: View {
    private struct Block: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var speed: CGFloat
        var color: Color
        var scale: CGFloat = 1.0
    }

    @State private var blocks: [Block] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                ZStack {
                    ForEach(blocks.indices, id: \.self) { index in
                        let block = blocks[index]
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(block.color)
                            .frame(width: max(18, geo.size.width * 0.06), height: max(18, geo.size.width * 0.06))
                            .scaleEffect(block.scale)
                            .shadow(color: block.color.opacity(0.35), radius: 6, x: 0, y: 4)
                            .position(x: block.x * geo.size.width, y: block.y * geo.size.height)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                                    blocks[index].scale = 1.25
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                    withAnimation(.easeOut(duration: 0.18)) {
                                        blocks[index].scale = 1.0
                                        blocks[index].y = -0.1
                                        blocks[index].x = CGFloat.random(in: 0.1...0.9)
                                        blocks[index].speed = CGFloat.random(in: 0.08...0.16)
                                    }
                                }
                            }
                    }

                    Text("💀")
                        .font(.system(size: max(28, geo.size.width * 0.08)))
                        .shadow(radius: 2)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.25)
                        .opacity(0.9)
                }
                .onChange(of: context.date) { _ in
                    updateBlocks()
                }
                .onAppear {
                    if blocks.isEmpty {
                        seedBlocks()
                    }
                }
            }
        }
        .allowsHitTesting(true)
    }

    private func seedBlocks() {
        let baseColors: [Color] = [
            Color(hex: "#22D3EE"),
            Color(hex: "#6366F1"),
            Color(hex: "#A855F7"),
            Color(hex: "#F472B6")
        ]
        blocks = (0..<10).map { _ in
            Block(
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: -0.2...0.9),
                speed: CGFloat.random(in: 0.08...0.16),
                color: baseColors.randomElement()!.opacity(0.9)
            )
        }
    }

    private func updateBlocks() {
        guard !blocks.isEmpty else { return }
        for i in blocks.indices {
            var b = blocks[i]
            b.y += b.speed
            if b.y > 1.1 {
                b.y = -0.1
                b.x = CGFloat.random(in: 0.1...0.9)
                b.speed = CGFloat.random(in: 0.08...0.16)
            }
            blocks[i] = b
        }
    }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct SkeletonFallsLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var shimmer: Double = 0
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Night-styled gradient background (calmer palette)
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0B0F1A"),
                        Color(hex: "#111827"),
                        Color(hex: "#1F2937"),
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: max(geo.size.width, geo.size.height)
                )
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.05),
                            Color.clear,
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.screen)
                    .opacity(0.7)
                    .mask(
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.6), Color.white.opacity(0.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .offset(x: CGFloat(shimmer))
                    )
                    .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: shimmer)
                )
                .onAppear { shimmer = Double(geo.size.width * 2) }

                // Interactive falling blocks scene
                InteractiveBlocksView()

                // English text only
                VStack(spacing: 8) {
                    Text("Skeleton Falls")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 1)

                    Text("Loading… \(progressPercentage)%")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    Text("Tap falling blocks!")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.25), Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .cornerRadius(14)
            }
        }
    }
}

// MARK: - Фоновые представления

struct SkeletonFallsBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#0B0F1A"),
                Color(hex: "#0F172A"),
                Color(hex: "#111827"),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Circular Spinner

private struct SkeletonFallsCircularSpinner: View {
    let progress: Double
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 10)

            // Progress ring
            Circle()
                .trim(from: 0, to: max(0.02, min(1.0, progress)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#22D3EE"), // cyan
                            Color(hex: "#6366F1"), // indigo
                            Color(hex: "#A855F7"), // purple
                            Color(hex: "#F472B6"), // pink
                        ]),
                        center: .center,
                        angle: .degrees(rotation)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(hex: "#22D3EE").opacity(0.35), radius: 8)
                .animation(.easeInOut(duration: 0.25), value: progress)

            // Rotating highlight arc
            Circle()
                .trim(from: 0.0, to: 0.12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation))
                .rotationEffect(.degrees(-90))
                .blendMode(.screen)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Previews

#if canImport(SwiftUI)
import SwiftUI
#endif

// Use availability to keep using the modern #Preview API on iOS 17+ and provide a fallback for older versions
@available(iOS 17.0, *)
#Preview("Vertical") {
    SkeletonFallsLoadingOverlay(progress: 0.2)
}

@available(iOS 17.0, *)
#Preview("Horizontal", traits: .landscapeRight) {
    SkeletonFallsLoadingOverlay(progress: 0.2)
}

// Fallback previews for iOS < 17
struct SkeletonFallsLoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SkeletonFallsLoadingOverlay(progress: 0.2)
                .previewDisplayName("Vertical (Legacy)")

            SkeletonFallsLoadingOverlay(progress: 0.2)
                .previewDisplayName("Horizontal (Legacy)")
                .previewLayout(.fixed(width: 812, height: 375)) // Simulate landscape on older previews
        }
    }
}
