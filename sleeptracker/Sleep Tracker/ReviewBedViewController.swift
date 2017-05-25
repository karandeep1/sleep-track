
import UIKit

protocol BedViewDelegate {
    var startTimeInBed: Date? { get }
    var endTimeInBed: Date? { get }
}

class ReviewBedViewController: UIViewController {
    @IBOutlet weak var enterBedLabel: UILabel!
    @IBOutlet weak var exitBedLabel: UILabel!
    @IBOutlet weak var bedDurationLabel: UILabel!
    var delegate: BedViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func formatInterval(_ interval: TimeInterval) -> String {
            let hours = Int(interval / 3600)
            let hoursPlural = hours != 1 ? "s" : ""
            let minutes = Int((interval / 60).truncatingRemainder(dividingBy: 60))
            let minutesPlural = minutes != 1 ? "s" : ""
            let seconds  = Int(interval.truncatingRemainder(dividingBy: 60))
            let secondsPlural = seconds != 1 ? "s" : ""
            if hours > 0 {
                return "\(hours) hour\(hoursPlural) \(minutes) minute\(minutesPlural)"
            } else if minutes > 0 {
                return "\(minutes) minute\(minutesPlural)"
            } else {
                return "\(seconds) second\(secondsPlural)"
            }
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateStyle = DateFormatter.Style.none
        enterBedLabel.text = formatter.string(from: delegate.startTimeInBed!)
        exitBedLabel.text = formatter.string(from: delegate.endTimeInBed!)
        bedDurationLabel.text = formatInterval(delegate.endTimeInBed!.timeIntervalSince(delegate.startTimeInBed!))
    }

    @IBAction func discard(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to discard this? It will delete the current data.", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action: UIAlertAction!) -> Void in }
        let discardAction = UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive) { (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "discardBedReview", sender: self)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(discardAction)
        present(alertController, animated: true) { () -> Void in }
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "submitBedReview", sender: self)
    }
    
}
