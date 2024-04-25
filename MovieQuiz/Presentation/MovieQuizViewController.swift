import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet internal weak var imageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
            let message = presenter.makeResultsMessage()
            
            let alert = UIAlertController(
                title: result.title,
                message: message,
                preferredStyle: .alert)
                
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    presenter.resetQuestionIndex()
                    presenter.restartGame()
            }
        alert.view.accessibilityIdentifier = "Game results"
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        }
    
    func clearBorder() {
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    
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
