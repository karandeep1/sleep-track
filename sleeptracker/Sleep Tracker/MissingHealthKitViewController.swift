

import UIKit

class MissingHealthKitViewController: UIViewController {
    var delegate: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MissingHealthKitViewController.checkIfValid), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfValid()
    }

    @IBAction func openSupportSite(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://developer.apple.com/reference/healthkit")!)
    }
    
    func checkIfValid() {
        if delegate?.healthKitStore != nil {
            self.performSegue(withIdentifier: "returnFromError", sender: self)
        }
    }
}
