import SwiftUI

// MARK: - Feedback Overlay Modifier

/// Modificateur pour afficher un feedback visuel
struct FeedbackOverlayModifier: ViewModifier {
    @Binding var isShowing: Bool
    let type: FeedbackType
    let message: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if isShowing {
                    FeedbackOverlayView(type: type, message: message)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.spring(response: 0.3)) {
                                    isShowing = false
                                }
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isShowing)
    }
}

extension View {
    func feedbackOverlay(isShowing: Binding<Bool>, type: FeedbackType, message: String) -> some View {
        modifier(FeedbackOverlayModifier(isShowing: isShowing, type: type, message: message))
    }
}

// MARK: - Feedback Type

enum FeedbackType {
    case success
    case error
    case warning
    case info
    case favorite
    case added
    case removed

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .favorite: return "heart.fill"
        case .added: return "plus.circle.fill"
        case .removed: return "minus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success, .added: return .green
        case .error, .removed: return .red
        case .warning: return .orange
        case .info: return .blue
        case .favorite: return .pink
        }
    }
}

// MARK: - Feedback Overlay View

struct FeedbackOverlayView: View {
    let type: FeedbackType
    let message: String

    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Cercle de fond
                Circle()
                    .fill(type.color.opacity(0.15))
                    .frame(width: 80, height: 80)

                // Icone
                Image(systemName: type.icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(type.color)
                    .scaleEffect(iconScale)
            }

            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                iconScale = 1.0
            }

            // Feedback haptique
            let generator = UINotificationFeedbackGenerator()
            switch type {
            case .success, .added, .favorite:
                generator.notificationOccurred(.success)
            case .error, .removed:
                generator.notificationOccurred(.error)
            case .warning:
                generator.notificationOccurred(.warning)
            case .info:
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
    }
}

// MARK: - Bounce Animation Modifier

struct BounceAnimationModifier: ViewModifier {
    let trigger: Bool

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _, _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                    scale = 1.0
                }
            }
    }
}

extension View {
    func bounceAnimation(trigger: Bool) -> some View {
        modifier(BounceAnimationModifier(trigger: trigger))
    }
}

// MARK: - Shake Animation Modifier

struct ShakeAnimationModifier: ViewModifier {
    let trigger: Bool

    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, _ in
                withAnimation(.linear(duration: 0.05).repeatCount(5, autoreverses: true)) {
                    offset = 5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    offset = 0
                }
            }
    }
}

extension View {
    func shakeAnimation(trigger: Bool) -> some View {
        modifier(ShakeAnimationModifier(trigger: trigger))
    }
}

// MARK: - Pulse Animation Modifier

struct PulseAnimationModifier: ViewModifier {
    let isActive: Bool

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: isActive) { _, active in
                if active {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        scale = 1.05
                        opacity = 0.8
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            }
    }
}

extension View {
    func pulseAnimation(isActive: Bool) -> some View {
        modifier(PulseAnimationModifier(isActive: isActive))
    }
}

// MARK: - Success Checkmark Animation

struct SuccessCheckmarkView: View {
    @State private var checkProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 80, height: 80)

            Circle()
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 60, height: 60)

            Path { path in
                path.move(to: CGPoint(x: 20, y: 35))
                path.addLine(to: CGPoint(x: 28, y: 45))
                path.addLine(to: CGPoint(x: 45, y: 25))
            }
            .trim(from: 0, to: checkProgress)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 60, height: 60)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                checkProgress = 1.0
            }
        }
    }
}

// MARK: - Confetti Effect

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool

    @State private var particles: [ConfettiParticle] = []

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { _ in
                        ForEach(particles) { particle in
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .position(particle.position)
                                .opacity(particle.opacity)
                        }
                    }
                    .onAppear {
                        createParticles()
                        animateParticles()
                    }
                }
            }
    }

    private func createParticles() {
        particles = (0..<30).map { _ in
            ConfettiParticle(
                position: CGPoint(x: CGFloat.random(in: 100...300), y: -20),
                color: [Color.red, .green, .blue, .yellow, .orange, .pink, .purple].randomElement()!,
                size: CGFloat.random(in: 4...8),
                velocity: CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: 100...200)),
                opacity: 1.0
            )
        }
    }

    private func animateParticles() {
        for i in particles.indices {
            withAnimation(.easeOut(duration: 2.0)) {
                particles[i].position.y += particles[i].velocity.y * 3
                particles[i].position.x += particles[i].velocity.x
                particles[i].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isActive = false
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let velocity: CGPoint
    var opacity: Double
}

extension View {
    func confettiEffect(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}

#Preview("Success Feedback") {
    FeedbackOverlayView(type: .success, message: "Recette ajoutee aux favoris !")
}

#Preview("Checkmark") {
    SuccessCheckmarkView()
}
