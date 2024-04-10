import UIKit

class AlertPresenter: AlertProtocol {
    weak var delegate: AlertPresentDelegate?
    private let movieQuizViewController: UIViewController
    
    init(delegate: AlertPresentDelegate? = nil, movieQuizViewController: UIViewController) {
        self.movieQuizViewController = movieQuizViewController
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
        }
        
        guard let delegate = delegate else {
            return
        }
        alert.addAction(action)
        
        movieQuizViewController.present(alert, animated: true, completion: nil)
        delegate.presentAlert()
    }
}
