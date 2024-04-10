import UIKit

class AlertPresenter: AlertProtocol {
    private var currentQuestionIndex: Int
    private var correctAnswers: Int
    private var questionFactory: QuestionFactoryProtocol?
    weak var delegate: AlertPresentDelegate?
    
    init(currentQuestionIndex: Int, correctAnswers: Int, questionFactory: QuestionFactoryProtocol? = nil, delegate: AlertPresentDelegate? = nil) {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory = questionFactory
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            correctAnswers = 0
            currentQuestionIndex = 0
            
            questionFactory?.requestNextQuestion()
        }
        
        guard let delegate = delegate else {
            return
        }
        alert.addAction(action)
        
        delegate.presentAlert()
    }
}
