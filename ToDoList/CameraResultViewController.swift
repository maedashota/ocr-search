//
//  ImageViewController.swift
//  RealmSample
//
//  Created by k16045kk on 2018/11/06.
//  Copyright © 2018年 AIT. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyJSON

class CameraResultViewController: UIViewController{
    @IBOutlet weak var ImageView: UIImageView!
    //カメラビューから画像を取得　変換が必要
    var cameraImage: Data!
    //kougiid
    var thrKougiId: String!
    //OCR
    let session = URLSession.shared
    var googleAPIKey = "AIzaSyDM356z_eJ93y8LGQvAQr9YLFn2nbW5gGo"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    var labelResultsText:String = "Labels found: "
    //OCR変換時時間に表示するくるくるするやつ
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var saveb: UIBarButtonItem!
    @IBOutlet weak var cancelb: UIBarButtonItem!
    @IBOutlet weak var allcancelb: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*--debug--*/
        print("view:CameraResultViewController")
        print("var :therKougiId:　\(thrKougiId)")
 
        //画面遷移で取得した画像を表示
        ImageView.image = UIImage(data: cameraImage)
        
        //画面のくるくるを中央に配置し、止めたとき非表示にする設定
        spinner.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        //ボタン等表示
        saveb.isEnabled = true
        cancelb.isEnabled = true
        allcancelb.isEnabled = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //セーブボタンが押されたとき
    @IBAction func saveImage(_ sender: Any) {
    //ボタン非表示等操作させないために
        spinner.startAnimating()
        saveb.isEnabled = false
        cancelb.isEnabled = false
        allcancelb.isEnabled = false
    //OCR化
        // Base64 encode the image and create the request
        let picImage = UIImage(data: cameraImage)
        let binaryImageData = base64EncodeImage(picImage!)
        //スレッドへ、スレッドの中で画像保存やデータベース登録、のち画面遷移
        createRequest(with: binaryImageData)
    }
    @IBAction func cancelSaveImage(_ sender: Any) {
        //何もせずカメラビューへ戻る
        self.dismiss(animated: true, completion: nil)
    }
    func loadImage(){
    }
    @IBAction func cancelCamera(_ sender: Any) {
        // 何もせず2画面戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

//OCR
extension CameraResultViewController{
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(dataToParse)
            let errorObj: JSON = json["error"]
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get label annotations(注釈)
                let labelAnnotations: JSON = responses["textAnnotations"]
                let numLabels: Int = labelAnnotations.count
    
                var labels: Array<String> = []
                if numLabels > 0 {
                    
                    var labelResultsText:String = "L found: "
                    for index in 0..<1 {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    labelResultsText = labelResultsText.replacingOccurrences(of: "\n", with: "")
                    print(labelResultsText)
                    //画像保存
                    //保存する画像の名前を生成
                    let f = DateFormatter()
                    f.timeZone = TimeZone.current
                    f.locale = Locale.current
                    f.dateFormat = "yyyyMMddHHmmss"
                    let now = Date()
                    let fStr = f.string(from: now)
                    print(f.string(from: now))
                    // 保存処理
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fpath :String = "noteImage/" + fStr + ".jpg"
                        let savePath =  dir.appendingPathComponent(fpath)
                        do {
                            try self.cameraImage.write(to: savePath, options: .atomic)
                        } catch {
                            print("画像保存ができませんでした")
                        }
                        //データベースへ保存
                        do{
                            let realm = try Realm()
                            let touroku:Gazou = Gazou()
                            touroku.id = fStr
                            touroku.kougiId = self.thrKougiId
                            touroku.path = fpath
                            touroku.name = fStr
                            touroku.ocrStr = labelResultsText
                            print("labelResults:\(labelResultsText)")
                            // インサート実行
                            try! realm.write {
                                realm.add(touroku)
                            }
                            
                        }catch{
                            print("error")
                        }
                    }
                    //コレクションビューへ戻る
                    // 親VCを取り出し
                    let parentVC = self.presentingViewController?.presentingViewController as! ImageViewController
                    parentVC.reloadCollection()
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                }
            }
        })
    }
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

/// Networking
extension CameraResultViewController{
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
//                    [
//                        "type": "TEXT_DETECTION",
//                        "maxResults": 1
//                    ],
                    [
                        "type": "DOCUMENT_TEXT_DETECTION",
                        "maxResults": 1
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
