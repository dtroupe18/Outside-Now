//
//  NotificationsViewController.swift
//  Outside Now
//
//  Created by Dave on 3/6/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var freqView: UIView!
    @IBOutlet weak var freqLabel: UILabel!
    @IBOutlet weak var freqTextField: UITextField!
    @IBOutlet weak var freqDone: UIButton!
    @IBOutlet weak var freqCancel: UIButton!
    @IBOutlet weak var freqPicker: UIPickerView!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeDone: UIButton!
    @IBOutlet weak var timeCancel: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let frequencyChoices = ["Daily", "Weekdays", "Weekends"]
    var selectedFrequency: String?
    var selectedTimeDate: Date?
    let userDefaults = UserDefaults.standard
    
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Check and see if the user has an existing notification
        //
        if let notificationDate = userDefaults.object(forKey: "notificationDate") as? Date {
            notificationSwitch.isOn = true
            timeTextField.text = getFormattedTime(date: notificationDate)
            
            if let frequency = userDefaults.string(forKey: "notificationFrequency") {
                freqTextField.text = frequency
            }
        } else {
            notificationSwitch.isOn = false
            timeTextField.text = ""
            freqTextField.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freqTextField.delegate = self
        timeTextField.delegate = self
        
        freqPicker.dataSource = self
        freqPicker.delegate = self
        
        freqPicker.layer.borderWidth = 1
        freqPicker.layer.cornerRadius = 8
        freqPicker.layer.borderColor = UIColor.white.cgColor
        
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        timePicker.layer.borderWidth = 1
        timePicker.layer.cornerRadius = 8
        timePicker.layer.borderColor = UIColor.white.cgColor
        // timePicker.addTarget(self, action: #selector(self.timePickerChanged(sender:)), for: .valueChanged)
        self.timePicker.datePickerMode = .time
        
        
        center.requestAuthorization(options: options, completionHandler: { (granted, error) in
            if !granted {
                // Show alert telling the user they can change this in settings
                //
                self.showAlert(title: "Notifications Denied", message: "You can update your notification preferences in settings at any time.")
            }
        })
        
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func doneTimePicker(_ sender: Any) {
        // Format the time and display it
        //
        selectedTimeDate = timePicker.date
        timeTextField.text = getFormattedTime(date: timePicker.date)
        timeView.isHidden = true
    }
    
    @IBAction func cancelTimePicker(_ sender: Any) {
        view.endEditing(true)
        timeView.isHidden = true
    }
    
    @IBAction func doneFreqPicker(_ sender: Any) {
        freqTextField.text = selectedFrequency
        freqView.isHidden = true
    }
    
    @IBAction func cancelFreqPicker(_ sender: Any) {
        view.endEditing(true)
        freqView.isHidden = true
    }
    
    // Marker: UIPicker Delegate
    //
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencyChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: frequencyChoices[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Updated the value stored for the user's selection
        //
        selectedFrequency = frequencyChoices[row]
    }
    
    // Marker: UITextView Delegate
    //
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == freqTextField {
            freqView.isHidden = false
            textField.endEditing(true)
        } else if textField == timeTextField {
            timeView.isHidden = false
            textField.endEditing(true)
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        // Check to see if notifications are authorized
        //
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                self.saveNotificationRequest()
            } else {
                // Tell the user they must enable notifications first
                //
                self.showAlert(title: "Access Denied", message: "You have not allowed Outisde Now to send you notifications. Please allow notifications in settings before continuing.")
            }
        })
        
    }
    
    func saveNotificationRequest() {
        if let time = selectedTimeDate, let freq = selectedFrequency, notificationSwitch.isOn {
            userDefaults.set(time, forKey: "notificationDate")
            userDefaults.set(freq, forKey: "notificationFrequency")
            let timeString = getFormattedTime(date: time)
            showAlert(title: "Notification Saved", message: "Your weather notification with \(freq) frequency at \(timeString) has been set")
        } else if selectedTimeDate == nil {
            timeTextField.layer.borderWidth = 2
            timeTextField.layer.borderColor = UIColor.red.cgColor
            timeTextField.layer.cornerRadius = 8
        } else if selectedFrequency == nil {
            freqTextField.layer.borderWidth = 2
            freqTextField.layer.borderColor = UIColor.red.cgColor
            freqTextField.layer.cornerRadius = 8
        } else if !notificationSwitch.isOn {
            notificationSwitch.layer.borderWidth = 2
            notificationSwitch.layer.borderColor = UIColor.red.cgColor
            notificationSwitch.layer.cornerRadius = 8
        }
    }
    
    @IBAction func switchFlipped(_ sender: UISwitch) {
        print("switch flipped")
    }
    
    // Marker: Utility Functions
    //
    func getFormattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
