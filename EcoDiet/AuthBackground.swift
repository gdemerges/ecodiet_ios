import SwiftUI

struct AuthBackground: View {
    // Couleurs écologiques et naturelles (plus vertes et saturées)
    private let topColor = Color(red: 0.82, green: 0.93, blue: 0.85)      // Vert pâle plus saturé
    private let middleColor = Color(red: 0.78, green: 0.91, blue: 0.82)   // Vert clair plus saturé
    private let bottomColor = Color(red: 0.75, green: 0.88, blue: 0.80)   // Vert moyen plus saturé
    
    @State private var animateCircles = false
    @State private var animateAccent = false

    var body: some View {
        ZStack {
            // Gradient de fond principal (plus vert et visible)
            LinearGradient(
                colors: [topColor, middleColor, bottomColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Couche de texture subtile
            RadialGradient(
                colors: [
                    Color.white.opacity(0.15),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            
            // Cercles organiques flottants (style feuilles, bulles)
            GeometryReader { geometry in
                // Grand cercle vert nature (haut gauche) - plus saturé
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.3, green: 0.75, blue: 0.45).opacity(0.25),
                                Color(red: 0.2, green: 0.65, blue: 0.5).opacity(0.15)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 50)
                    .offset(
                        x: -120 + (animateCircles ? 20 : 0),
                        y: -240 + (animateCircles ? 15 : 0)
                    )
                
                // Cercle moyen vert menthe (droite) - plus saturé
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.35, green: 0.85, blue: 0.55).opacity(0.22),
                                Color(red: 0.3, green: 0.75, blue: 0.6).opacity(0.12)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 110
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 45)
                    .offset(
                        x: geometry.size.width - 80 + (animateCircles ? -15 : 0),
                        y: 180 + (animateCircles ? -10 : 0)
                    )
                
                // Petit cercle orange (accent culinaire, centre-gauche)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.15),
                                Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.08)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 40)
                    .offset(
                        x: 60 + (animateAccent ? 10 : 0),
                        y: geometry.size.height / 2 + (animateAccent ? -8 : 0)
                    )
                
                // Cercle bleu-vert eau (bas gauche)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.2, green: 0.7, blue: 0.7).opacity(0.15),
                                Color(red: 0.3, green: 0.75, blue: 0.8).opacity(0.08)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 42)
                    .offset(
                        x: -60 + (animateCircles ? 12 : 0),
                        y: geometry.size.height - 100 + (animateCircles ? 8 : 0)
                    )
                
                // Grand cercle vert pâle (centre-haut, ambiance)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.45, green: 0.82, blue: 0.5).opacity(0.12),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 210
                        )
                    )
                    .frame(width: 420, height: 420)
                    .blur(radius: 60)
                    .offset(
                        x: geometry.size.width / 2 - 50,
                        y: -80 + (animateAccent ? 15 : 0)
                    )
                
                // Cercle décoratif avec contour (style bulles) - vert
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.75, blue: 0.45).opacity(0.25),
                                Color(red: 0.2, green: 0.65, blue: 0.5).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 3)
                    .offset(
                        x: geometry.size.width - 180 + (animateCircles ? -10 : 0),
                        y: -100 + (animateCircles ? 12 : 0)
                    )
                
                // Petites bulles organiques décoratives
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(red: 0.85, green: 0.95, blue: 0.88).opacity(0.6))
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                        .offset(
                            x: CGFloat(80 + index * 120) + (animateAccent ? 5 : 0),
                            y: geometry.size.height - CGFloat(150 + index * 80) + (animateAccent ? CGFloat(index * 5) : 0)
                        )
                }
            }
        }
        .onAppear {
            // Animations continues douces pour créer un effet organique vivant
            withAnimation(
                .easeInOut(duration: 8.0)
                .repeatForever(autoreverses: true)
            ) {
                animateCircles = true
            }
            
            withAnimation(
                .easeInOut(duration: 6.5)
                .repeatForever(autoreverses: true)
            ) {
                animateAccent = true
            }
        }
    }
}

#Preview {
    AuthBackground()
}
