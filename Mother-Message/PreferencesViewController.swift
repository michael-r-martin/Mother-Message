//
//  PreferencesViewController.swift
//  Mother-Message
//
//  Created by Michael Martin on 19/03/2022.
//

import UIKit

class PreferencesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var preferencesLabel: UILabel!
    @IBOutlet weak var preferencesStackView: UIStackView!
    @IBOutlet weak var addNumberButtonView: UIView!
    @IBOutlet weak var addNumberButton: UIButton!
    @IBOutlet weak var allowNotifsButtonView: UIView!
    @IBOutlet weak var allowNotifsButton: UIButton!
    @IBOutlet weak var addNumberView: UIView!
    @IBOutlet weak var addNumberInstructionLabel: UILabel!
    @IBOutlet weak var addNumberTextField: UITextField!
    
    @IBOutlet weak var saveNumberButtonView: UIView!
    @IBOutlet weak var saveNumberButton: UIButton!
    
    let notificationHelper = NotificationHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView()
        
        addNumberTextField.delegate = self
        
        notificationHelper.notifDelegate = self
    }
    
    @IBAction func addNumberTapped(_ sender: Any) {
        addNumberView.fadeIn(completion: nil)
        
        addNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func allowNotifsTapped(_ sender: Any) {
        notificationHelper.registerForPushNotifications()
    }
    
    @IBAction func saveNumberButtonPressed(_ sender: Any) {
        addNumberView.fadeOut(completion: nil)
        
        guard let number = addNumberTextField.text else {
            return
        }
        
        UserDefaults.standard.setValue(number, forKey: "MothersNumber")
        UserDefaults.standard.setValue(true, forKey: "UserIsOnboarded")
        
        addNumberTextField.resignFirstResponder()
        
        addNumberButtonView.layer.backgroundColor = CGColor(red: 140/255, green: 240/255, blue: 110/255, alpha: 1)
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        
        let notifContent = notificationHelper.createNotificationContent(title: "A new message is ready to send 💜", body: "Tap to make your mother smile", badge: 1, sound: .default)
        
        var notificationTimeComponents = DateComponents()
        notificationTimeComponents.hour = 17
        notificationTimeComponents.minute = 10
        notificationTimeComponents.second = 0
        
        notificationHelper.scheduleLocalNotification(notificationContent: notifContent, notificationDate: notificationTimeComponents, repeats: true, identifier: "DailyReminder")
    }
    
    
    func styleView() {
        backgroundView.layer.cornerRadius = backgroundView.bounds.height/8
        backgroundView.layer.cornerCurve = .continuous
        
        addNumberButtonView.layer.cornerRadius = addNumberButtonView.bounds.height/2
        addNumberButtonView.layer.cornerCurve = .continuous
        
        allowNotifsButtonView.layer.cornerRadius = allowNotifsButtonView.bounds.height/2
        allowNotifsButtonView.layer.cornerCurve = .continuous
        
        saveNumberButtonView.layer.cornerRadius = saveNumberButtonView.bounds.height/2
        saveNumberButtonView.layer.cornerCurve = .continuous
        
        addNumberView.alpha = 0
        
        let phoneNumberAdded = UserDefaults.standard.string(forKey: "MothersNumber")
        
        if phoneNumberAdded != nil {
            addNumberButtonView.layer.backgroundColor = CGColor(red: 140/255, green: 240/255, blue: 110/255, alpha: 1)
            addNumberButton.setTitle("Update mother's number 📱", for: .normal)
            addNumberButton.setTitleColor(.white, for: .normal)
        }
        
        notificationHelper.checkNotificationPermission()
    }
    

}

extension UIView {
    
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: ((_ done: Bool) -> Void)?) {
        
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
            self.alpha = 1.0
        } completion: { done in
            if done {
                completion?(true)
            }
        }
    }
    
    func fadeOut(duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: ((_ done: Bool) -> Void)?) {
        
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut) {
            self.alpha = 0.0
        } completion: { done in
            if done {
                completion?(true)
            }
        }
    }
    
}

protocol NotifDelegate {
    func notifsAuthorized()
}

extension PreferencesViewController: NotifDelegate {
    func notifsAuthorized() {
        allowNotifsButtonView.layer.backgroundColor = CGColor(red: 140/255, green: 240/255, blue: 110/255, alpha: 1)
        allowNotifsButton.setTitle("Notifications are allowed ✅", for: .normal)
        allowNotifsButton.setTitleColor(.white, for: .normal)
    }
    
    
}
