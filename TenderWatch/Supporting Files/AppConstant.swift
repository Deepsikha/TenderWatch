//
//  AppConstant.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import Foundation

let appDelegate = UIApplication.shared.delegate as! AppDelegate

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

extension UIButton{
  func cornerRedius()
  {
      self.layer.cornerRadius = self.frame.height/2
      self.layer.masksToBounds = true
  }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
extension Date {
    func getDifferenceBtnCurrentDate(date: String) -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let endDate: Date = dateFormatter.date(from: date)! as Date
        
        let components = NSCalendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: Date(), to: endDate as Date)
        
        return components
    }
}
extension UIView {
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}


func isValidEmail(strEmail : String) ->  Bool
{
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: strEmail)
}

func isValidNumber(_ data:String,length:Int?) -> Bool{
    let ns:NSString
    if let _ = length{
        ns = "[0-9]{\(length!)}" as NSString
    }else{
        ns = "[0-9]+"
    }
    let pr:NSPredicate = NSPredicate(format: "SELF MATCHES %@",ns)
    return pr.evaluate(with: data)
}

func isValidPassword(strPassword: String) -> Bool {

    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z0-9])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")  //8 char alphabet specialChar
    return passwordTest.evaluate(with: strPassword)
}

class AppConstant: NSObject {
    

}

class MessageManager {
    
    static func showAlert(_ title:String?, _ message: String) {
        if var topController = appDelegate.window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let alert = UIAlertController(title: "TenderWatch", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.view.backgroundColor = UIColor.white
            alert.view.layer.cornerRadius = 10.0
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ action in
                
            }))
            topController.present(alert, animated: false, completion: nil)
        }
    }
}


extension UIViewController {
    
    //Previous code
    
    var activityIndicatorTag: Int { return 999999 }
    
    func startActivityIndicator(
        _ style: UIActivityIndicatorViewStyle = .gray,
        location: CGPoint? = nil) {
        self.view.isUserInteractionEnabled = false

        //Set the position - defaults to `center` if no`location`
        
        //argument is provided
        
        let loc = location ?? self.view.center
        
        
        //Ensure the UI is updated from the main thread
        
        //in case this method is called from a closure
        
        DispatchQueue.main.async(execute: {
            
            //Create the activity indicator
            
            
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            
            activityIndicator.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.gray
            
            
            activityIndicator.tag = self.activityIndicatorTag
            //Set the location
            
            activityIndicator.center =  CGPoint(x:ScreenSize.SCREEN_WIDTH/2, y:ScreenSize.SCREEN_HEIGHT/2)
            activityIndicator.hidesWhenStopped = true
            //Start animating and add the view
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    func stopActivityIndicator() {
        
        //Again, we need to ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async(execute: {
            //Here we find the `UIActivityIndicatorView` and remove it from the view
            
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        })
    }
    
    
}

