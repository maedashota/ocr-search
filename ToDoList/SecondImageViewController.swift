//
//  SecondImageViewController.swift
//  ToDoList
//
//  Created by k16102kk on 2018/12/11.
//  Copyright © 2018年 maya tominaga. All rights reserved.
//

import UIKit
import RealmSwift

class SecondImageViewController: UIViewController {
    
    @IBOutlet weak var naviBar: UINavigationItem!
    @IBOutlet weak var SecoundimageView: UIImageView!
    var selectedImg: String!
    var sIGazouId:String!
    
    //親のviewナンバー、Del処理で分岐させる、
    //ImageViewcont:0 Resultviewcont:1
    var viewNUM: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        SecoundimageView.contentMode = UIViewContentMode.scaleAspectFit
        //日付をナビゲーションバーに表示
        // デフォルトRealmを取得
        let realm = try! Realm()
        var result = realm.objects(Gazou.self)
        result = result.filter("id=='"+(sIGazouId)+"'")
        let f = DateFormatter()
        f.timeZone = TimeZone.current
        f.locale = Locale.current
        f.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let now = result[0].created
        let fStr = f.string(from: now)
        naviBar.title = fStr
        //受け取った画像パスを使って画像を読み込む
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath =  dir.appendingPathComponent(selectedImg)
            //読み込み
            print(filePath.absoluteString)
            let loadimage = UIImage(contentsOfFile: filePath.path)
            //表示
            if(loadimage != nil){
                // UIImageをUIImageViewのimageとして設定
                SecoundimageView.image = loadimage
            }else{
                print("画像を読み込めません")
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    //IMAGEViewがスワイプされたときの処理
    @IBAction func flickAction(_ sender: Any) {
    }
    
    @IBAction func addTags(_ sender: Any) {
        performSegue(withIdentifier: "toTagView",sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toTagView") {
            let tagVC: TagViewController = (segue.destination as? TagViewController)!
            //送るもの
            tagVC.tGazouId = sIGazouId
        }
    }
    //画像削除ボタン
    @IBAction func deleteBtn(_ sender: Any) {
        //アラートを表示して、削除ボタンを押されたら画像をデータベースと端末から削除する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "画像の削除", message: "削除しますか？", preferredStyle:  UIAlertControllerStyle.alert)
        // deleteボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.destructive, handler:{
            (action: UIAlertAction!) -> Void in
            // ボタンが押された時の処理を
            print("delete")
            //画像をデータベースと端末から削除
            self.gazouDelete()
            switch self.viewNUM{
            case 0://Imageviewcont
                //親ビューのコレクションビューを更新& back
                let parentVCa = self.presentingViewController as! ImageViewController
                parentVCa.reloadCollection()
                self.dismiss(animated: true, completion: nil)
                break
            case 1:
                let parentVCb = self.presentingViewController as! ResultViewController
                parentVCb.reloadCollection()
                self.dismiss(animated: true, completion: nil)
                break
            default:
                print("error")
            }
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gazouDelete(){
        //受け取った画像Idの画像を削除する
        let realm = try! Realm()
        var result = realm.objects(Gazou.self)
        result = result.filter("id=='"+(sIGazouId)+"'")
        if !result.isEmpty{
            let fileManager = FileManager.default
            if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
                let filePath =  dir.appendingPathComponent(result[0].path!)
                do{
                    try fileManager.removeItem(at: filePath)
                    //タグを消すプログラムは面倒なので未記述
                    try! realm.write {
                        realm.delete(result)
                    }
                }catch{
                    print("画像削除失敗")
                }
                
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
