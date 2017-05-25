

import UIKit
import HealthKit

class ViewController: UIViewController, SleepReviewResponder, BedViewDelegate {
    var defaults: UserDefaults!
    var inBed = false
    var asleep = false
    var startTimeInBed: Date?
    var startTimeAsleep: Date?
    var endTimeAsleep: Date?
    var endTimeInBed: Date?
    var healthKitStore: HKHealthStore?
    weak var healthkitErrorViewController: ErrorViewController!
    weak var missingHealthKitViewController: MissingHealthKitViewController!
    lazy var categoryType: HKObjectType = { HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) }()!
    
    @IBOutlet weak var timeInBedLabel: UILabel!
    @IBOutlet weak var timeAsleepLabel: UILabel!
    @IBOutlet weak var bedButton: UIButton!
    @IBOutlet weak var sleepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaults = UserDefaults.standard

        inBed = defaults.bool(forKey: "In Bed")
        asleep = defaults.bool(forKey: "Asleep")
        
        startTimeInBed = defaults.object(forKey: "Start In Bed") as! Date?
        startTimeAsleep = defaults.object(forKey: "Start Asleep") as! Date?
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showErrorIfInvalid), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        if HKHealthStore.isHealthDataAvailable() {
            healthKitStore = HKHealthStore()
            let sampleSet = NSSet(object: categoryType) as! Set<HKSampleType>
            let readSet = NSSet() as! Set<HKObjectType>
            healthKitStore?.requestAuthorization(toShare: sampleSet, read: readSet, completion: { (_, _) in
                self.showErrorIfInvalid()
            })
            
        } else {
            print("Sorry, healthkit is unavailable!")
            showErrorIfMissingHealthKit()
        }
        
        updateStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showErrorIfInvalid()
        showErrorIfMissingHealthKit()
    }
    
    func showErrorIfInvalid() {
        if healthKitStore?.authorizationStatus(for: categoryType) == HKAuthorizationStatus.sharingDenied {
            self.performSegue(withIdentifier: "errorSegue", sender: self)
        } else if healthkitErrorViewController != nil {
            healthkitErrorViewController.performSegue(withIdentifier: "returnFromError", sender: self)
        }
    }
    
    
    
    func showErrorIfMissingHealthKit() {
        if healthKitStore == nil {
            self.performSegue(withIdentifier: "missingSegue", sender: self)
        } else if missingHealthKitViewController != nil {
            missingHealthKitViewController.performSegue(withIdentifier: "returnFromError", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "errorSegue" {
            healthkitErrorViewController = segue.destination as! ErrorViewController
            healthkitErrorViewController.delegate = self
        } else if segue.identifier == "reviewSleepSegue" {
            let vc = segue.destination as! ReviewSleepViewController
            vc.delegate = self
        } else if segue.identifier == "reviewBedSegue" {
            let vc = segue.destination as! ReviewBedViewController
            vc.delegate = self
        } else if segue.identifier == "missingSegue" {
            missingHealthKitViewController = segue.destination as! MissingHealthKitViewController
            missingHealthKitViewController.delegate = self
        }
    }
    


    @IBAction func toggleInBed(_ sender: AnyObject) {
        if self.inBed {
            inBed = false
            endTimeInBed = Date()
            self.performSegue(withIdentifier: "reviewBedSegue", sender: self)
        } else {
            inBed = true
            startTimeInBed = Date()
        }
        updateStatus()
    }
    
    @IBAction func toggleSleeping(_ sender: AnyObject) {
        if self.asleep {
            asleep = false
            endTimeAsleep = Date()
            self.performSegue(withIdentifier: "reviewSleepSegue", sender: self)
        } else {
            asleep = true
            startTimeAsleep = Date()
        }
        updateStatus()
    }
    
    func saveSample(_ sample: HKCategorySample) {
        if healthKitStore?.authorizationStatus(for: categoryType) == HKAuthorizationStatus.sharingAuthorized {
            self.healthKitStore?.save(sample, withCompletion: { (_, _) in
                print("saved")
            })
        }
    }
    
    func updateStatus() {
        defaults.set(asleep, forKey: "Asleep")
        defaults.set(inBed, forKey: "In Bed")
        defaults.set(startTimeAsleep, forKey: "Start Asleep")
        defaults.set(startTimeInBed, forKey: "Start In Bed")
        
        timeAsleepLabel.text = asleep ? "Asleep" : "Awake"
        timeInBedLabel.text = inBed ? "In bed " : "Not in bed"
        sleepButton.setTitle(asleep ? "Wake up" : "Sleep", for: UIControlState())
        bedButton.setTitle(inBed ? "Get up" : "Get in bed", for: UIControlState())
        
    }
    
    
    @IBAction func returnFromError(_ segue: UIStoryboardSegue) {
        healthkitErrorViewController = nil
        missingHealthKitViewController = nil
    }
    
    @IBAction func returnFromSleepReview(_ segue: UIStoryboardSegue) {
        let sample = HKCategorySample(
            type: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.asleep.rawValue,
            start: startTimeAsleep!,
            end: endTimeAsleep!
        )
        saveSample(sample)
    }
    
    @IBAction func submitBedReview(_ segue: UIStoryboardSegue) {
        let sample = HKCategorySample(
            type: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            value: HKCategoryValueSleepAnalysis.inBed.rawValue,
            start: startTimeInBed!,
            end: endTimeInBed!
        )
        saveSample(sample)
    }
    
    @IBAction func discardReview(_ segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

