//
//  Item.swift
//  NoteSample2
//
//  Created by k16045kk on 2018/11/14.
//  Copyright © 2018年 saito. All rights reserved.
//

import Foundation
import RealmSwift

//データベースの構成
//idの決め方
//現在時刻（Date関数)から取ってくる
//2018/11/14 16:00:33   ->  20181114160033
//                          YYYYMMDDHHmmss
class Kougi: Object{
    // id 主キー
    @objc dynamic var id: String? = nil
    // 講義名
    @objc dynamic var name: String? = "-"
    // 講師名
    @objc dynamic var teacher: String? = "--"
    // 登録日時
    @objc dynamic var created = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Gazou: Object{
    // id
    @objc dynamic var id: String? = nil
    // Kougiテーブルのid
    @objc dynamic var kougiId: String? = nil
    // 画像へのPathー＞　"noteImage/xxx.jpg"
    @objc dynamic var path: String? = nil
    // 表示名
    @objc dynamic var name: String? = "-"
    // 登録日時
    @objc dynamic var created = Date()
    //OCRをかけた分
    @objc dynamic var ocrStr: String? = "---"
    
    let tags = List<Tag>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
class Tag: Object{
    @objc dynamic var tagStr: String? = ""
}



