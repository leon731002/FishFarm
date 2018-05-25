//
//  WebViewController.swift
//  FishFarm
//
//  Created by Leon on 2018/5/22.
//  Copyright © 2018年 Leon. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

protocol WebViewErrorDelegate {
    func showErrorAlertAndBackToSetting(_ reason: String)
}

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    var delegate: WebViewErrorDelegate?
    var urlString: String = ""
    @IBOutlet weak var errorLabel: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initWebView()
        CommonTool.sharedInstance.addSubViewToFullScreen(self.webView, superView: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadUrl()
    }
    
    //MARK: - Public Functions
    public func loadUrl() {
        DispatchQueue.main.async {
            HUD.allowsInteraction = false
            HUD.show(.progress)
        }
        
        if let myURL = URL(string: self.urlString) {
            let myRequest = URLRequest(url: myURL)
            self.webView.load(myRequest)
            
        }
        else {
            DispatchQueue.main.async {
                self.loadDataFinish(false)
                self.someErrorHappened(GetString.sharedInstance.getString("SettingViewController0003"))
            }
        }
    }
    
    //MARK: - Private Function
    private func initUIString() {
        self.errorLabel.text = GetString.sharedInstance.getString("SettingViewController0007")
    }
    
    private func someErrorHappened(_ reason: String) {
        if self.delegate != nil {
            self.delegate!.showErrorAlertAndBackToSetting(reason)
        }
    }
    
    private func loadDataFinish(_ success: Bool) {
        if HUD.isVisible {
            HUD.hide()
            HUD.allowsInteraction = true
        }
        if success {
            self.webView.isHidden = false
        }
        else {
            self.webView.isHidden = true
            self.someErrorHappened(GetString.sharedInstance.getString("SettingViewController0007"))
        }
        
    }
    
    private func initWebView() {
        let configuration = WKWebViewConfiguration()
        if #available(iOS 9.0, *) {
            configuration.allowsAirPlayForMediaPlayback = true
        } else {
            // Fallback on earlier versions
        }
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 9.0, *) {
            configuration.allowsPictureInPictureMediaPlayback = true
        } else {
            // Fallback on earlier versions
        }
        
        let preference = WKPreferences()
        preference.javaScriptEnabled = true
        preference.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.preferences = preference
        self.webView = WKWebView(frame: self.view.frame, configuration: configuration)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.isHidden = true
    }
    
    //MARK: - WKWebView Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async(execute: {
            self.loadDataFinish(false)
        });
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async(execute: {
            self.loadDataFinish(true)
        });
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async(execute: {
            self.loadDataFinish(false)
        });
        
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        }
        else
        {
            completionHandler(.performDefaultHandling, nil)
        }
    }

}
