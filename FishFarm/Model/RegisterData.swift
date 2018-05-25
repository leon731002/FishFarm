//
//  RegisterData.swift
//  FishFarm
//
//  Created by Leon on 2018/5/25.
//  Copyright © 2018年 Leon. All rights reserved.
//

import Foundation
import UIKit

class RegisterData {
    static let sharedInstance = RegisterData()
    
    private var appCode = "fish_android"
    private var appKey = "a94502f9384c3f09725341220bfdc53cae37fafcce85d050bd"
    private var os = "iOS"
    private var osVersion = UIDevice.current.systemVersion
    private var serialNumber = UIDevice.current.identifierForVendor!.uuidString
    private var heightPixel = UIScreen.main.bounds.height
    private var widthPixel = UIScreen.main.bounds.width
    private var macAddress = ""
    private var pushNotificationId = ""
    
    public func setPushNotificationId(_ token: String) {
        self.pushNotificationId = token
    }
    
    public func getJsonString() -> String {
        var jsonString = "{"
        jsonString = jsonString + "\"appCode\": \"\(self.appCode)\","
        jsonString = jsonString + "\"appKey\": \"\(self.appKey)\","
        jsonString = jsonString + "\"serialNumber\": \"\(self.serialNumber)\","
        jsonString = jsonString + "\"os\": \"\(self.os)\","
        jsonString = jsonString + "\"osVersion\": \"\(self.osVersion)\","
        jsonString = jsonString + "\"heightPixel\": \"\(self.heightPixel)\","
        jsonString = jsonString + "\"widthPixel\": \"\(self.widthPixel)\","
        jsonString = jsonString + "\"macAddress\": \"\(self.macAddress)\","
        jsonString = jsonString + "\"pushNotificationId\": \"\(self.pushNotificationId)\""
        jsonString = jsonString + "}"
        print("jsonString:\(jsonString)")
        return jsonString
    }
    
}
