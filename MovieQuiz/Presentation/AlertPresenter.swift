import UIKit

final class AlertPresenter: AlertProtocol {
    
    weak var delegate: AlertPresentDelegate?
    
    init(delegate: AlertPresentDelegate? = nil) {
        self.delegate = delegate
    }
    
    func createAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        guard let delegate = delegate else {
            return
        }
        alert.addAction(action)
        
        delegate.showAlert(alert: alert)
    }
}
