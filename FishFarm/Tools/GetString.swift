//
//  GetString.swift
//  VoteApp
//
//  Created by Leon on 2016/12/13.
//  Copyright © 2016年 KPMG. All rights reserved.
//

import Foundation

class GetString {
    static let stringTableFileName = "StringTable.plist"
    static let sharedInstance = GetString()
    
    //MARK: - Public Functions
    /*
     *Description: 取得對應的多國語系
     *Parameters: key為UI顯示文字的唯一代碼
     *Return: app依照手機語系要顯示的文字內容
     */
    public func getString(_ key: String) -> String {
        let string = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        return string
    }
    
}
