import UIKit

final class AlertPresenter: AlertProtocol {
    
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    func createAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
            alert.view.accessibilityIdentifier = model.accessibilityIndicator

        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert,animated: true, completion: nil)
    }
}
