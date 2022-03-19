//
//  MainViewController.swift
//  Mother-Message
//
//  Created by Michael Martin on 19/03/2022.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var motherMessageLabel: UILabel!
    @IBOutlet weak var todaysMessageLabel: UILabel!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var changePreferencesButtonView: UIView!
    
    // MARK: - Variables
    var dailyMessage: String?
    
    // MARK: - Instances
    let db = Firestore.firestore()
    let decoder = JSONDecoder()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        downloadDailyMessage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyMessage = "This is sexy af"
        
        styleView()
    }
 
    // MARK: - IBActions
    @IBAction func sendButtonTapped(_ sender: Any) {
        let isOnboarded = UserDefaults.standard.bool(forKey: "UserIsOnboarded")
        
        if isOnboarded {
            sendMessageToWhatsapp()
        } else {
            let prefVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preferences")
            prefVC.modalPresentationStyle = .overFullScreen
            prefVC.modalTransitionStyle = .coverVertical
            present(prefVC, animated: true)
        }
        
    }
    
    @IBAction func changePreferencesTapped(_ sender: Any) {
        let prefVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preferences")
        prefVC.modalPresentationStyle = .overFullScreen
        prefVC.modalTransitionStyle = .coverVertical
        present(prefVC, animated: true)
    }
    
    func styleView() {
        messageBackgroundView.layer.cornerRadius = messageBackgroundView.bounds.height/8
        messageBackgroundView.layer.cornerCurve = .continuous
//        messageBackgroundView.layer.borderWidth = 2
//        messageBackgroundView.layer.borderColor = CGColor(red: 184/255, green: 70/255, blue: 246/255, alpha: 1)
        
        sendButtonView.layer.cornerRadius = sendButtonView.bounds.height/2
        sendButtonView.layer.cornerCurve = .continuous
        
        changePreferencesButtonView.layer.cornerRadius = changePreferencesButtonView.bounds.height/2.4
        changePreferencesButtonView.layer.cornerCurve = .continuous
    }
    
    func sendMessageToWhatsapp() {
        guard let dailyMessage = dailyMessage else {
            return
        }
        
        let mothersNumber = UserDefaults.standard.string(forKey: "MothersNumber") ?? ""
        
        let message = dailyMessage.addingPercentEncoding(withAllowedCharacters: (NSCharacterSet.urlQueryAllowed)) ?? "💜"
        
        if let whatsappURL = URL(string: "whatsapp://send?phone=\(mothersNumber)&text=\(message)") {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
        }
    }
    
    func downloadDailyMessage() {
        
        db.collection("dailyMessages").document("dailyMessage").getDocument { snapshot, error in
            if let error = error {
                print("error", error.localizedDescription)
                return
            }
            
            guard let document = snapshot?.data() else {
                print("error: \(#line)")
                return
            }
            
            self.parseDailyMessage(message: document)
        }
        
    }
    
    func parseDailyMessage(message: [String: Any]) {
        
        do {
            let convertedJSON = try JSONSerialization.data(withJSONObject: message, options: [])
            let parsedJSON = try decoder.decode(DailyMessage.self, from: convertedJSON)
            dailyMessage = parsedJSON.messageText
            messageTextView.text = parsedJSON.messageText
        } catch {
            print("error parsing")
        }
        
    }
    
}

struct DailyMessage: Codable {
    var messageText: String?
}
