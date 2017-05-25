

import UIKit
import HealthKit

class ErrorViewController: UIViewController {
    var delegate: ViewController?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorViewController.checkIfValid), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfValid()
    }
    
    func checkIfValid() {
        if delegate?.healthKitStore?.authorizationStatus(for: (delegate?.categoryType)!) == HKAuthorizationStatus.sharingAuthorized {
            self.performSegue(withIdentifier: "returnFromError", sender: self)
        }
    }
}
