//
//  HttpRequestFactory.swift
//  Event
//
//  Created by Leon on 2015/10/26.
//  Copyright © 2015年 KPMG. All rights reserved.
//

import UIKit

enum HTTP_REQUEST_TYPE: String {
    case login                      = "/mobile/sensor"
    case register                   = "/device/signageregister"
}

class HttpRequestFactory {
    static let sharedInstance = HttpRequestFactory()
    static let HTTP_TIMEOUT: Double = 60
    static let HTTP_UNKONW_FAIL_CODE: Int = -9876
    static let HTTP_UNKONWSERVER_FAIL_CODE: Int = -12345
    static let PROTOCOL_STRING: String = "http://"
    static let PORT_STRING: String = ":10240"
    
    private let serverCommandVersion = "2"
    var web: String = ""
    var connectWithDeviceName: String = ""
    
    //MARK: - Public Functions
    func sendHttpRequest(serverIP: String, requestType: HTTP_REQUEST_TYPE, querySource:Any, completion: @escaping (Any) -> Void) {
        
        if self.web == "" && serverIP == "" {
            completion(HttpRequestFactory.HTTP_UNKONWSERVER_FAIL_CODE)
            return
        }
        if requestType == .register {
            if let jsonString = querySource as? String {
                self.sendRegisterActionRequest(serverIP: serverIP, jsonString: jsonString) {
                    (result: Bool) in
                    completion(result)
                }
            }
        }
    }
    
    func getLoginUrlString(_ serverIP: String) -> String {
        return HttpRequestFactory.PROTOCOL_STRING + serverIP + HttpRequestFactory.PORT_STRING + HTTP_REQUEST_TYPE.login.rawValue
    }
    
    //MARK: - Private Functions
    /*
     * description: log in 
     */
    private func sendRegisterActionRequest(serverIP: String, jsonString: String, completion: @escaping(_ result: Bool) -> Void) {
        let request = self.getRequestForGet(serverIP: serverIP, url: "\(HTTP_REQUEST_TYPE.register.rawValue)?json=\(jsonString)")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = HttpRequestFactory.HTTP_TIMEOUT
        let session = URLSession(configuration: sessionConfig)
        print("Send Register request:\(request)")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (responseJson, response, error) in
            if (error != nil) {
                print("Send Register error:\(error!.localizedDescription)")
                completion(false)
                return
            }
            else {
                if responseJson != nil && responseJson!.count > 0 {
                    print("\(serverIP) Send Register resp string:\(String(describing: NSString(data:responseJson!, encoding:String.Encoding.utf8.rawValue)))")
                    
                    if let jsonResult = (try? JSONSerialization.jsonObject(with: responseJson!, options:JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary {
                        if let value = jsonResult["result"] as? Bool {
                            completion(value)
                            return
                        }
                    }
                }
            }
            completion(false)
            return
        })
        task.resume()
    }
    
    private func getRequestForPost(serverIP: String, url: String, postString: NSString) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: serverIP + url)! as URL)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        if postString != "" {
            request.httpBody = postString.data(using: String.Encoding.utf8.rawValue)
        }
        
        return request
    }
    
    private func getRequestForGet(serverIP: String, url: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: HttpRequestFactory.PROTOCOL_STRING + serverIP + HttpRequestFactory.PORT_STRING + url)! as URL)
        request.httpMethod = "GET"
        return request
    }
}
