import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresent: AlertProtocol?
    private var statisticService: StatisticService?
    var isAnsweringQuestion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)

        alertPresent = AlertPresenter(delegate: self)
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.layer.cornerRadius = 20
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            statisticService = StatisticServiceImplementation()

            showLoadingIndicator()
            questionFactory?.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }

        alertPresent?.createAlert(model: viewModel)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
                    image: UIImage(data: model.image) ?? UIImage(),
                    question: model.text,
                    questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
        imageView.layer.cornerRadius = 20
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        } 
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let gamesCount = statisticService?.gamesCount,
                  let bestGame = statisticService?.bestGame else {
                return
            }
            let totalAccuracy = "\(String(format: "%.2f", statisticService!.totalAccuracy))%"
            let message = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))
            Средняя точность: \(totalAccuracy)
            """
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз"
            ) { [weak self] in
                self?.imageView.layer.borderColor = UIColor.clear.cgColor
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }

            alertPresent?.createAlert(model: viewModel)
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            questionFactory?.requestNextQuestion()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
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
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
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
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
