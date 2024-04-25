import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    private var presenter: MovieQuizPresenter!
    var isAnsweringQuestion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        presenter = MovieQuizPresenter(viewController: self)
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
    }
    
    func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            presenter.resetQuestionIndex()
            presenter.restartGame()
        }

        alert.addAction(action)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
        imageView.layer.cornerRadius = 20
    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText, accessibilityIndicator: "Game results") { [weak self] in
            guard let self = self else { return }
            presenter.resetQuestionIndex()
            presenter.restartGame()
        }

        alertPresenter.show(in: self, model: model)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    
                    self.presenter.showNextQuestionOrResults()
                    imageView.layer.borderWidth = 0
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let text = "Вы ответили на \(presenter.correctAnswers) из 10, попробуйте еще раз!"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.currentQuestionIndex += 1
            presenter.restartGame()
        }
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            
//            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
//            guard let gamesCount = statisticService?.gamesCount,
//                  let bestGame = statisticService?.bestGame else {
//                return
//            }
//            let totalAccuracy = "\(String(format: "%.2f", statisticService!.totalAccuracy))%"
//            let message = """
//            Ваш результат: \(correctAnswers)/10
//            Количество сыгранных квизов: \(gamesCount)
//            Рекорд: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))
//            Средняя точность: \(totalAccuracy)
//            """
//            let viewModel = AlertModel(
//                title: "Этот раунд окончен!",
//                message: message,
//                buttonText: "Сыграть ещё раз", 
//                accessibilityIndicator: "Game results"
//            ) { [weak self] in
//                self?.imageView.layer.borderColor = UIColor.clear.cgColor
//                self?.presenter.resetQuestionIndex()
//                self?.correctAnswers = 0
//                self?.questionFactory?.requestNextQuestion()
//            }
//
//            alertPresent?.createAlert(model: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        
        if !isAnsweringQuestion {
            isAnsweringQuestion = true
            yesButton.isEnabled = false
            noButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isAnsweringQuestion = false
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
        if !isAnsweringQuestion {
            isAnsweringQuestion = true
            yesButton.isEnabled = false
            noButton.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isAnsweringQuestion = false
                self.yesButton.isEnabled = true
                self.noButton.isEnabled = true
            }
        }
    }
}
