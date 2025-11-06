import Foundation

struct SportsQuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
    
    var correctAnswer: String {
        answers[correctAnswerIndex]
    }
}

struct SportsQuizData {
    static let sportsQuestions: [SportsQuizQuestion] = [
        SportsQuizQuestion(
            question: "Quel est le meilleur moment pour consommer des protéines après l'effort ?",
            answers: [
                "Immédiatement après",
                "30 min à 2h après",
                "Le lendemain",
                "Ce n'est pas important"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Quelle quantité d'eau un sportif doit-il boire par jour ?",
            answers: [
                "1 litre",
                "1,5 litres",
                "2,5 à 3,5 litres",
                "5 litres"
            ],
            correctAnswerIndex: 2
        ),
        SportsQuizQuestion(
            question: "Quel nutriment est le carburant principal lors d'un effort intense ?",
            answers: [
                "Les protéines",
                "Les lipides",
                "Les glucides",
                "Les vitamines"
            ],
            correctAnswerIndex: 2
        ),
        SportsQuizQuestion(
            question: "Combien de grammes de protéines par kg de poids corporel pour un sportif ?",
            answers: [
                "0,5 à 0,8 g/kg",
                "1,2 à 2 g/kg",
                "3 à 4 g/kg",
                "5 g/kg"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Quel aliment est idéal avant une compétition ?",
            answers: [
                "Steak-frites",
                "Pâtes complètes",
                "Salade verte",
                "Fast-food"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Quand faut-il consommer des glucides rapides ?",
            answers: [
                "Au réveil",
                "Pendant/après l'effort",
                "Avant de dormir",
                "Jamais"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Quel aliment favorise la récupération musculaire ?",
            answers: [
                "Chips et sodas",
                "Banane et lait",
                "Café noir",
                "Gâteaux industriels"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Combien de temps avant l'effort faut-il manger un repas complet ?",
            answers: [
                "15 minutes",
                "1 heure",
                "2 à 3 heures",
                "Juste avant"
            ],
            correctAnswerIndex: 2
        ),
        SportsQuizQuestion(
            question: "Quel est le rôle principal des oméga-3 pour le sportif ?",
            answers: [
                "Augmenter la masse",
                "Anti-inflammatoire",
                "Énergie rapide",
                "Aucun effet"
            ],
            correctAnswerIndex: 1
        ),
        SportsQuizQuestion(
            question: "Quelle collation est idéale après un entraînement cardio ?",
            answers: [
                "Fruits secs et noix",
                "Pizza",
                "Alcool",
                "Rien du tout"
            ],
            correctAnswerIndex: 0
        )
    ]
}
