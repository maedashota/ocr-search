//
//  ImageViewController.swift
//  ToDoList
//
//  Created by k16102kk on 2018/12/04.
//  Copyright © 2018年 maya tominaga. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ImageViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var ImageCollectionView: UICollectionView!
    @IBOutlet weak var naviBar: UINavigationItem!
    var results: Results<Gazou>!
    //講義一覧からKougiIdの値を受け取っているoneKougiId
    var oneKougiId: String!
    var kouginame: String!
    //画像表示ビューにわたす画像と画像タグ
    var toSecondPath: String!
    var toSecondIVGazouId:String!
    //picker
    var picker: UIImagePickerController! = UIImagePickerController()
    var pickerImage: Data!
    
    override func viewDidLoad() {
        ImageCollectionView.delegate = self
        ImageCollectionView.dataSource = self
        super.viewDidLoad()
        /*--debug--*/
        print("view:ImageViewController")
        print("var :oneKougiId:　\(oneKougiId)")
        // Do any additional setup after loading the view.
        //表示する画像の配列をRealmデータベースから検索する。
        // Realmのインスタンスを生成する
        do{
            let realm = try Realm()
            naviBar.title = kouginame
            //Gazouテーブルから同一のKougiIDのものだけを引っ張ってくる。
            results = realm.objects(Gazou.self)
            results = results.filter("kougiId == '" + oneKougiId + "'")
            //登録日時でソート
            results = results.sorted(byKeyPath: "id", ascending: false)
            //ImageCollectionView.reloadData()
        }catch{
            print("error1")
        }
        ////
    }
    //cell内の画像やラベルを設定するFunc
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell =
            ImageCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        
        let Labelname = testCell.contentView.viewWithTag(2) as! UILabel

        Labelname.text = results[indexPath.row].name
        //画像の読み込み
        //print(results[indexPath.row].kougiId)
        //パス設定
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath =  dir.appendingPathComponent(results[indexPath.row].path!)
            //読み込み
            print(filePath.absoluteString)
            let loadimage = UIImage(contentsOfFile: filePath.path)
            //表示
            if(loadimage != nil){
                // UIImageをUIImageViewのimageとして設定
                imageView.image = loadimage
            }else{
                print("画像を読み込めません")
            }
            
        }
        
        
        // Tag番号を使ってLabelのインスタンス生成
        //let label = testCell.contentView.viewWithTag(2) as! UILabel
        //label.text = photos[indexPath.row]
        
        return testCell
    }
    //よくわからないけど多分いる
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    //生成するCellを返すFunc
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        print("var :results.count:　\(results.count)")
        return results.count;
    }
    //画像がタップされた場合の処理
    func collectionView(_ collection: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        //パスを投げて受け取ったヴューで読み込む
        toSecondPath = results[indexPath.row].path!
        toSecondIVGazouId = results[indexPath.row].id!
        if(toSecondPath != nil){
            performSegue(withIdentifier: "toSecondImageVIew",sender: nil)
        }
        /*
        let storyboard: UIStoryboard = self.storyboard!
        let collectionVC = storyboard.instantiateViewController(withIdentifier: "SecoundImageViewPage") as! ImageViewController
        self.navigationController?.pushViewController(collectionVC, animated: true)
        //collectionView.deselectRow(at: indexPath, animated: true)
        */
    }

    @IBAction func inportimage(_ sender: Any) {
        performSegue(withIdentifier: "toPickerResultViewCont",sender: nil)
    }
    @IBAction func cameraStart(_ sender: Any) {
        // CameraViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toCameraViewController",sender: nil)
    }
    
    @IBAction func searchStart(_ sender: Any) {
        //searchViewへ遷移するSegue
        performSegue(withIdentifier: "toSearchview",sender: nil)
    }
    // 画面遷移のSegue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //Cameraへ遷移
        if (segue.identifier == "toCameraViewController") {
            let cameraVC: CameraViewController = (segue.destination as? CameraViewController)!
            // CameraViewControllerのtwoKougiIdにkougiIdを送る
            cameraVC.twoKougiId = oneKougiId
        }
        if (segue.identifier == "toSecondImageVIew") {
            let secondIVC: SecondImageViewController = (segue.destination as? SecondImageViewController)!
            secondIVC.sIGazouId = toSecondIVGazouId
            secondIVC.selectedImg = toSecondPath
            secondIVC.viewNUM = 0
        }
        if (segue.identifier == "toPickerResultViewCont") {
            let pickVC: PickerResultViewController = (segue.destination as? PickerResultViewController)!
            // ResultのtwoKougiIdにkougiIdを送る
            pickVC.forsKougiId = oneKougiId
        }
        if (segue.identifier == "toSearchview") {
            let searchVC: SearchViewController = (segue.destination as? SearchViewController)!
            // ResultのtwoKougiIdにkougiIdを送る
            searchVC.sKougiId = oneKougiId
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Collectionviewの更新 外部からもアクセス
    func reloadCollection(){
        do{
            let realm = try Realm()
            //Gazouテーブルから同一のKougiIDのものだけを引っ張ってくる。
            results = realm.objects(Gazou.self)
            results = results.filter("kougiId == '" + oneKougiId + "'")
            //登録日時でソート
            results = results.sorted(byKeyPath: "id", ascending: false)
            ImageCollectionView.reloadData()
        }catch{
            print("error1")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
