import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answers: [String]
    let correctAnswerIndex: Int
    
    var correctAnswer: String {
        answers[correctAnswerIndex]
    }
}

struct QuizData {
    static let ecoQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "Quel est le mode de production agricole le plus écologique ?",
            answers: [
                "Agriculture intensive",
                "Agriculture biologique",
                "Monoculture industrielle",
                "Agriculture conventionnelle"
            ],
            correctAnswerIndex: 1
        ),
        QuizQuestion(
            question: "Quelle protéine a la plus faible empreinte carbone ?",
            answers: [
                "Bœuf",
                "Poulet",
                "Lentilles",
                "Porc"
            ],
            correctAnswerIndex: 2
        ),
        QuizQuestion(
            question: "Quel fruit génère le moins de CO2 en hiver en France ?",
            answers: [
                "Fraises importées",
                "Mangues du Brésil",
                "Pommes locales",
                "Ananas d'Afrique"
            ],
            correctAnswerIndex: 2
        ),
        QuizQuestion(
            question: "Quelle est la meilleure façon de réduire le gaspillage alimentaire ?",
            answers: [
                "Acheter en grande quantité",
                "Planifier ses repas",
                "Jeter les restes",
                "Ignorer les dates de péremption"
            ],
            correctAnswerIndex: 1
        ),
        QuizQuestion(
            question: "Quel emballage est le plus écologique ?",
            answers: [
                "Plastique jetable",
                "Aluminium",
                "Verre réutilisable",
                "Polystyrène"
            ],
            correctAnswerIndex: 2
        ),
        QuizQuestion(
            question: "Combien de litres d'eau faut-il pour produire 1kg de bœuf ?",
            answers: [
                "100 litres",
                "500 litres",
                "1 500 litres",
                "15 000 litres"
            ],
            correctAnswerIndex: 3
        ),
        QuizQuestion(
            question: "Quel type d'alimentation réduit le plus l'empreinte carbone ?",
            answers: [
                "Carnivore",
                "Végétarien/végétalien",
                "Pescatarien",
                "Flexitarien"
            ],
            correctAnswerIndex: 1
        ),
        QuizQuestion(
            question: "Quel est l'impact des produits de saison ?",
            answers: [
                "Plus chers",
                "Moins de goût",
                "Moins de transport",
                "Aucune différence"
            ],
            correctAnswerIndex: 2
        )
    ]
}
