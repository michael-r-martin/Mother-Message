//
//  MainViewController.swift
//  Mother-Message
//
//  Created by Michael Martin on 19/03/2022.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var motherMessageLabel: UILabel!
    @IBOutlet weak var todaysMessageLabel: UILabel!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButtonView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Variables
    var dailyMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dailyMessage = "This is sexy af"
    }
 
    // MARK: - IBActions
    @IBAction func sendButtonTapped(_ sender: Any) {
        let isOnboarded = UserDefaults.standard.bool(forKey: "UserIsOnboarded")
        
        sendMessageToWhatsapp()
        
//        if isOnboarded {
//            sendMessageToWhatsapp()
//        } else {
//            let prefVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preferences")
//        }
        
    }
    
    func sendMessageToWhatsapp() {
        guard let dailyMessage = dailyMessage else {
            return
        }
        
        let message = dailyMessage.addingPercentEncoding(withAllowedCharacters: (NSCharacterSet.urlQueryAllowed)) ?? "hey mother 💜"
        
        if let whatsappURL = URL(string: "whatsapp://send?phone=+447522657793&text=\(message)") {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
        }
    }
    

}
