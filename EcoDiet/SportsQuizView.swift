import SwiftUI

struct SportsQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    @State private var isAnswerCorrect = false
    @State private var quizCompleted = false
    @State private var animateQuestion = false
    
    let questions: [SportsQuizQuestion]
    
    init() {
        // Prendre 5 questions aléatoires
        self.questions = SportsQuizData.sportsQuestions.shuffled().prefix(5).map { $0 }
    }
    
    private var currentQuestion: SportsQuizQuestion {
        questions[currentQuestionIndex]
    }
    
    private var progress: Double {
        Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            if quizCompleted {
                resultsView
            } else {
                quizView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Quiz Sport")
                    .font(.headline)
            }
        }
        .onAppear {
            animateQuestion = true
        }
    }
    
    private var quizView: some View {
        VStack(spacing: 24) {
            // Barre de progression
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(score) point\(score > 1 ? "s" : "")")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            Spacer()
            
            // Question
            VStack(spacing: 32) {
                Text(currentQuestion.question)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(animateQuestion ? 1 : 0)
                    .offset(y: animateQuestion ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateQuestion)
                
                // Grille de réponses 2x2
                VStack(spacing: 16) {
                    ForEach(0..<2) { row in
                        HStack(spacing: 16) {
                            ForEach(0..<2) { col in
                                let index = row * 2 + col
                                if index < currentQuestion.answers.count {
                                    answerButton(for: index)
                                        .opacity(animateQuestion ? 1 : 0)
                                        .scaleEffect(animateQuestion ? 1 : 0.8)
                                        .animation(
                                            .spring(response: 0.6, dampingFraction: 0.8)
                                                .delay(Double(index) * 0.1 + 0.2),
                                            value: animateQuestion
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            if showingResult {
                resultFeedback
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func answerButton(for index: Int) -> some View {
        Button {
            selectAnswer(index)
        } label: {
            Text(currentQuestion.answers[index])
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(textColor(for: index))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(backgroundColor(for: index))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(borderColor(for: index), lineWidth: 2)
                )
                .shadow(
                    color: shadowColor(for: index),
                    radius: selectedAnswer == index ? 12 : 8,
                    x: 0,
                    y: selectedAnswer == index ? 8 : 4
                )
                .scaleEffect(selectedAnswer == index ? 0.95 : 1.0)
        }
        .disabled(showingResult)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func textColor(for index: Int) -> Color {
        guard showingResult, let selected = selectedAnswer else {
            return .primary
        }
        
        if index == currentQuestion.correctAnswerIndex {
            return .white
        } else if index == selected {
            return .white
        }
        return .primary
    }
    
    private func backgroundColor(for index: Int) -> AnyShapeStyle {
        guard showingResult, let selected = selectedAnswer else {
            return AnyShapeStyle(.thinMaterial)
        }
        
        if index == currentQuestion.correctAnswerIndex {
            return AnyShapeStyle(.orange)
        } else if index == selected {
            return AnyShapeStyle(.red)
        }
        return AnyShapeStyle(.thinMaterial)
    }
    
    private func borderColor(for index: Int) -> Color {
        guard showingResult, let selected = selectedAnswer else {
            return Color.white.opacity(0.2)
        }
        
        if index == currentQuestion.correctAnswerIndex {
            return .orange.opacity(0.5)
        } else if index == selected {
            return .red.opacity(0.5)
        }
        return Color.white.opacity(0.2)
    }
    
    private func shadowColor(for index: Int) -> Color {
        guard showingResult, let selected = selectedAnswer else {
            return Color.black.opacity(0.1)
        }
        
        if index == currentQuestion.correctAnswerIndex {
            return .orange.opacity(0.3)
        } else if index == selected {
            return .red.opacity(0.3)
        }
        return Color.black.opacity(0.1)
    }
    
    private var resultFeedback: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(isAnswerCorrect ? .orange : .red)
                
                Text(isAnswerCorrect ? "Bravo !" : "Dommage !")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isAnswerCorrect ? .orange : .red)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isAnswerCorrect ? Color.orange.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 2)
            )
            
            Button {
                nextQuestion()
            } label: {
                Text(currentQuestionIndex < questions.count - 1 ? "Question suivante" : "Voir les résultats")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: scoreIcon)
                    .font(.system(size: 80, weight: .semibold))
                    .foregroundStyle(scoreColor)
                    .scaleEffect(animateQuestion ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: animateQuestion)
                
                Text(scoreTitle)
                    .font(.largeTitle.weight(.bold))
                    .opacity(animateQuestion ? 1 : 0)
                    .offset(y: animateQuestion ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateQuestion)
                
                Text("Vous avez obtenu")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .opacity(animateQuestion ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.5), value: animateQuestion)
                
                HStack(spacing: 8) {
                    Text("\(score)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(scoreColor)
                    Text("/")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("\(questions.count)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .opacity(animateQuestion ? 1 : 0)
                .scaleEffect(animateQuestion ? 1 : 0.5)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.6), value: animateQuestion)
                
                Text(scoreMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .opacity(animateQuestion ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.8), value: animateQuestion)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    restartQuiz()
                } label: {
                    Text("Recommencer")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    dismiss()
                } label: {
                    Text("Retour à l'accueil")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .opacity(animateQuestion ? 1 : 0)
            .offset(y: animateQuestion ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: animateQuestion)
        }
    }
    
    private var scoreIcon: String {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 { return "trophy.fill" }
        if percentage >= 0.6 { return "figure.run" }
        if percentage >= 0.4 { return "figure.walk" }
        return "arrow.clockwise"
    }
    
    private var scoreColor: LinearGradient {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if percentage >= 0.6 {
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var scoreTitle: String {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 { return "Champion !" }
        if percentage >= 0.6 { return "Très bien !" }
        if percentage >= 0.4 { return "Pas mal !" }
        return "Continuez !"
    }
    
    private var scoreMessage: String {
        let percentage = Double(score) / Double(questions.count)
        if percentage >= 0.8 {
            return "Vous maîtrisez parfaitement la nutrition sportive ! Vous êtes prêt à performer ! 🏆"
        }
        if percentage >= 0.6 {
            return "Vous avez de solides bases en nutrition sportive. Vous êtes sur la bonne voie ! 💪"
        }
        if percentage >= 0.4 {
            return "Vous connaissez quelques principes. Continuez à vous informer pour optimiser vos performances ! 🏃"
        }
        return "L'alimentation sportive a encore quelques secrets pour vous. Chaque apprentissage compte ! ⚡"
    }
    
    private func selectAnswer(_ index: Int) {
        guard selectedAnswer == nil else { return }
        
        selectedAnswer = index
        isAnswerCorrect = index == currentQuestion.correctAnswerIndex
        
        if isAnswerCorrect {
            score += 1
        }
        
        // Vibration haptique
        let generator = UIImpactFeedbackGenerator(style: isAnswerCorrect ? .medium : .light)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showingResult = true
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                showingResult = false
                animateQuestion = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                selectedAnswer = nil
                currentQuestionIndex += 1
                
                withAnimation {
                    animateQuestion = true
                }
            }
        } else {
            withAnimation {
                quizCompleted = true
                animateQuestion = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    animateQuestion = true
                }
            }
        }
    }
    
    private func restartQuiz() {
        withAnimation {
            animateQuestion = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentQuestionIndex = 0
            score = 0
            selectedAnswer = nil
            showingResult = false
            quizCompleted = false
            
            withAnimation {
                animateQuestion = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SportsQuizView()
    }
}
