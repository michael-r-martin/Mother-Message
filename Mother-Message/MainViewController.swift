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
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
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
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        if let url = URL(string: "https://www.neurify.co.uk/mother-message-privacy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        if let url = URL(string: "https://apps.apple.com/app/id1615270805") {
            let promoText = "Send your mother a daily message with Mother Message 💜"
            
            let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
            
            present(activityVC, animated: true)
        }
        
    }
    
    func styleView() {
        messageBackgroundView.layer.cornerRadius = messageBackgroundView.bounds.height/8
        messageBackgroundView.layer.cornerCurve = .continuous
        
        sendButtonView.layer.cornerRadius = sendButtonView.bounds.height/2
        sendButtonView.layer.cornerCurve = .continuous
        
        shareButtonView.layer.cornerRadius = shareButtonView.bounds.height/2
        shareButtonView.layer.cornerCurve = .continuous
        
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
