//
//  NotificationHelper.swift
//  Mother-Message
//
//  Created by Michael Martin on 19/03/2022.
//

import Foundation
import UserNotifications
import NotificationCenter
import Firebase
import FirebaseMessaging
import FirebaseAnalytics

class NotificationHelper {
    
    // MARK: - Let Constants
    
    
    var notifDelegate: NotifDelegate?
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in
                    
                    self.checkNotificationPermission()
                    
                })
            
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func createNotificationContent(title: String, body: String, badge: Int, sound: UNNotificationSound) -> UNMutableNotificationContent {
        
        // Create Notification Content Instance
        let notificationContent = UNMutableNotificationContent()
        
        let badgeNumber = NSNumber(value: badge)
        
        // Establishing Notification Content
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.badge = badgeNumber
        notificationContent.sound = sound
        
        return notificationContent
    }
    
    func scheduleLocalNotification(notificationContent: UNMutableNotificationContent, notificationDate: DateComponents, repeats: Bool, identifier: String) {
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            
            if let error = error {
                print("Notification Error: ", error)
            }
            
        }
        
    }
    
    func sendPushNotification(to token: String, pushNotificationData: [String: Any]) {
        
        // Auth key is required server key for Cloud Messaging
        let authKey = "key=AAAAgR3U1Sw:APA91bFWbcZneFUuVfHsN4doAX1UT0bzYu8UXGkSIDWglPU8e2bD9fRmYseiYqzlDYVC1Vma0WDhiZCyzZijBtk8ocnQ_hzftRpFzIecUKc_nznHvlMOzOnjSyEPMxoY-J7aeAtjFQ3_"
        // URL is API request URL
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = URL(string: urlString)!
        
        // Create API request and set the fields
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: pushNotificationData, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
       
        // Receive a response from the API request to determine if it worked
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let jsonData = data else {return}
            
          do {
                let jsonDataDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            print(jsonDataDict as Any)
          } catch {
            print(error.localizedDescription)
          }
            
        }
        task.resume()
        
    }
    
    // Check Notification Permission
    func checkNotificationPermission() {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            
            switch settings.authorizationStatus {
            
            // Set defaults depending on user's choice
            case .authorized, .provisional:
                
                UserDefaults.standard.setValue(true, forKey: "NotificationsAreAuthorized")
                
                print("Notifications Allowed")
                DispatchQueue.main.async {
                    self.notifDelegate?.notifsAuthorized()
                }
                
            case .denied:
                
                UserDefaults.standard.setValue(false, forKey: "NotificationsAreAuthorized")
                
                print("Notifications Not Allowed")
                
            default:
                break
                
            }
        })
    }
    
}
