//
//  ViewController.swift
//  FishFarm
//
//  Created by Leon on 2018/5/20.
//  Copyright © 2018年 Leon. All rights reserved.
//

import UIKit
import PKHUD

class SettingViewController: UIViewController, UITextFieldDelegate, ReachabilityManagerDelegate, UIViewKeyboardDelegate, WebViewErrorDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var ipTitleLabel: UILabel!
    @IBOutlet weak var bottomConstraintOfContentView: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView_Keyboard!
    private let bottomOfContentView: CGFloat = 0
    
    /*
     *description: start to monitor the network status and keyboard event while view init.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ReachabilityManager.sharedInstance.registerListener(observer: self)
        contentView.delegate = self
        self.initUIString()
        CommonTool.sharedInstance.clipButtonCorner(self.saveButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.autoConnectAnExistingServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            HUD.allowsInteraction = false
            HUD.show(.progress)
        }
        self.checkIfServerIsAvailable(self.ipTextField.text!) {
            (connected: Bool) in
            DispatchQueue.main.async {
                HUD.hide()
                HUD.allowsInteraction = true
            }
            if connected {
                SharedPreferenceManager.sharedInstance.saveValueForKey(.ip, value: self.ipTextField.text!)
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                if let webView = storyBoard.instantiateViewController(withIdentifier: "WebView") as? WebViewController {
                    webView.urlString = HttpRequestFactory.sharedInstance.getLoginUrlString(self.ipTextField.text!)
                    webView.delegate = self
                    self.present(webView, animated: true, completion: nil)
                }
            }
            else {
                self.showErrorMessage(GetString.sharedInstance.getString("SettingViewController0003"))
            }
        }
    }
    
    //MARK: - Private Functions
    private func autoConnectAnExistingServer() {
        let ip = SharedPreferenceManager.sharedInstance.getValueByKey(.ip)
        if ip != "" {
            DispatchQueue.main.async {
                self.ipTextField.text = ip
            }
            
            self.connectAction(UIButton())
        }
    }
    private func initUIString() {
        self.ipTitleLabel.text = GetString.sharedInstance.getString("SettingViewController0001")
        self.saveButton.setTitle(GetString.sharedInstance.getString("SettingViewController0002"), for: UIControlState())
    }
    
    private func checkIfServerIsAvailable(_ serverIP: String, completion: @escaping (Bool) -> Void) {
        HttpRequestFactory.sharedInstance.sendHttpRequest(serverIP: serverIP, requestType: .register, querySource: RegisterData.sharedInstance.getJsonString()) {
            (result: Any) in
            if let connected = result as? Bool {
                completion(connected)
            }
            else {
                completion(false)
            }
        }
    }
    
    private func clearIPSetting() {
        SharedPreferenceManager.sharedInstance.saveValueForKey(.ip, value: "")
        DispatchQueue.main.async {
            self.ipTextField.text = ""
        }
        
    }
    
    private func showErrorMessage(_ reason: String) {
        
        if let _ = self.presentedViewController {
            self.dimissAllTopView() {
                CommonTool.sharedInstance.showAlertView("", msg: reason, viewController: self, cancelTitle: GetString.sharedInstance.getString("SettingViewController0004"), buttonTitles: nil) {
                    (action: UIAlertAction) in
                    self.clearIPSetting()
                }
            }
        }
        else {
            CommonTool.sharedInstance.showAlertView("", msg: reason, viewController: self, cancelTitle: GetString.sharedInstance.getString("SettingViewController0004"), buttonTitles: nil) {
                (action: UIAlertAction) in
                self.clearIPSetting()
            }
        }
    }
    
    private func dimissAllTopView(completion: @escaping () -> ()) {
        if let topView = self.presentedViewController {
            DispatchQueue.main.async {
                topView.dismiss(animated: true, completion: {
                    self.dimissAllTopView(completion: completion)
                })
            }
        }
        else {
            completion()
        }
    }
    
    //MARK: - Keyboard Events Handling
    func keyboardHeightChanged(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.bottomConstraintOfContentView.constant = self.bottomOfContentView + (height / 2)
            self.view.updateConstraints()
        }
    }
    
    //MARK: - TextField Delegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return false
        }
        self.view.endEditing(true)
        return true
    }
    
    //MARK: - WebViewErrorDelegate
    func showErrorAlertAndBackToSetting(_ reason: String) {
        
    }
    
    //MARK: ReachabilityManagerDelegate
    func networkAvailable() {
        
    }
    
    func networkUnavailable() {
        self.showErrorMessage(GetString.sharedInstance.getString("SettingViewController0005"))
    }
    
    func hostAvailable() {
    }
    
    func hostUnavailable() {
    }
}

