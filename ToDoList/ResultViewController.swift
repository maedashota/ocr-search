//
//  ResultViewController.swift
//  ToDoList
//
//  Created by k16102kk on 2018/12/10.
//  Copyright © 2018年 maya tominaga. All rights reserved.
//

import UIKit
import RealmSwift

class ResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    //KougiIdを取得
    var rKougiId: String!
    //検索配列を取得
    var searchStr: [String] = []
    //タグとOCRのどちらから検索するかどうかのフラグ
    var searchTag: BooleanLiteralType!
    var searchOcr: BooleanLiteralType!
    //表示する画像の配列番号を代入する配列
    var searchStrIndex: [Int] = []
    var results: Results<Gazou>!
    
    //画像表示ビューにわたす画像と画像タグ
    var toSecondPath: String!
    var toSecondIVGazouId:String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageCollectionView.delegate = self
        ImageCollectionView.dataSource = self
        //検索フラグをオンにする、前の画面から取得するならここ消す
        searchTag = true
        searchOcr = true
        //データベース取得し、KougiIdでふるいにかける
        kensaku()
        // Do any additional setup after loading the view.
    }
    
    //検索
    func kensaku(){
        //searchStrIndexを初期化　リロード時にエラー
        searchStrIndex.removeAll()
        //データベース取得し、KougiIdでふるいにかける
        let realm = try! Realm()
        results = realm.objects(Gazou.self).filter("kougiId == '" + rKougiId + "'")
        //登録日時でソート
        results = results.sorted(byKeyPath: "id", ascending: false)
        var donotSearchOcr: BooleanLiteralType = false
        if(results.count > 0){
            //配列ループ 画像を一枚ずつ調べていく
            for i in 0..<results.count{
                //OCR結果から検索
                if searchOcr{
                    for str in searchStr{
                        print(str)
                        if let indx = results[i].ocrStr?.range(of: str) {
                            searchStrIndex.append(i)
                            print("OCRから：見つかりました。 index:\(indx)")
                        } else {
                            //見つからなかった場合はSearchtagでも検索をする
                            donotSearchOcr = true
                            print("OCRから：見つかりませんでした")
                        }
                    }
                }else{
                    print("OCRFLG is false")
                }
                //タグから検索+見つからなかった場合検索する。
                if searchTag == true && donotSearchOcr == true{
                    //tagsを取得
                    for str in searchStr{
                        for tagstr in results[i].tags{
                            let tagsss: String = tagstr.tagStr!
                            if tagsss == str{
                                searchStrIndex.append(i)
                                print("Tagがヒットしました：\(tagstr)")
                            }else{
                                print("tag\(tagstr)は見つかりません")
                            }
                        }
                    }
                }else{
                    print("TagFLG is false")
                }
                donotSearchOcr = false
            }
            //重複を排除
            let orderedSet: NSOrderedSet = NSOrderedSet(array: searchStrIndex)
            searchStrIndex = orderedSet.array as! [Int]
        }
    }
    
    //cell内の画像やラベルを設定するFunc
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell =
            ImageCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        //パス設定
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath =  dir.appendingPathComponent(results[searchStrIndex[indexPath.row]].path!)
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
        print("var :results.count:　\(searchStrIndex.count)")
        return searchStrIndex.count;
    }
    //画像がタップされた場合の処理
    func collectionView(_ collection: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        //パスを投げて受け取ったヴューで読み込む
        toSecondPath = results[searchStrIndex[indexPath.row]].path!
        toSecondIVGazouId = results[searchStrIndex[indexPath.row]].id!
        if(toSecondPath != nil){
            performSegue(withIdentifier: "toSecondIVC",sender: nil)
        }
        /*
         let storyboard: UIStoryboard = self.storyboard!
         let collectionVC = storyboard.instantiateViewController(withIdentifier: "SecoundImageViewPage") as! ImageViewController
         self.navigationController?.pushViewController(collectionVC, animated: true)
         //collectionView.deselectRow(at: indexPath, animated: true)
         */
    }

    // 画面遷移のSegue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSecondIVC") {
            let secondIVC: SecondImageViewController = (segue.destination as? SecondImageViewController)!
            secondIVC.sIGazouId = toSecondIVGazouId
            secondIVC.selectedImg = toSecondPath
            secondIVC.viewNUM = 1
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Collectionviewの更新 外部からもアクセス
    func reloadCollection(){
        print("kensaku func now")
        kensaku()
        ImageCollectionView.reloadData()
    }
    
    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
