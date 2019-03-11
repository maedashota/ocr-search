import UIKit
////
import RealmSwift
////


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var results: Results<Kougi>!
    var toIVCkougiId: String!
    var toKouginame: String!
    
    //＋ボタンを押されたとき
    @IBAction func addPressed(_ sender: Any) {
        // 新規kougi追加用のダイアログを表示
        let dlg = UIAlertController(title: "講義追加", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                self.addKougiItem(title: t)
            }
        }))
        present(dlg, animated: true)
    }
    // 追加
    func addKougiItem(title: String) {
        if title != ""{
            //id作成用
            let f = DateFormatter()
            f.dateFormat = "yyyyMMddHHmmss"
            let now = Date()
            print(f.string(from: now))
            // オブジェクト作成
            let kougiCre = Kougi()
            kougiCre.id = f.string(from: now)
            kougiCre.name = title
            kougiCre.teacher = "---"
            
            //書き込み
            // (1)Realmのインスタンスを生成する
            let realm = try! Realm()
            // (2)書き込みトランザクション内でデータを追加する
            try! realm.write {
                realm.add(kougiCre)
                print("kougi Saved")
            }
            
            let results = realm.objects(Kougi.self)
            print(results)
            todoTableView.reloadData()
        }
    }
    
    
    
    
    //セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count::::::\(results.count)")
        return results.count
    }
    //セルに値を設定するデータソースメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let nameResults = results[indexPath.row]
        cell.textLabel?.text = nameResults.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //アラートを表示して、削除ボタンを押されたら画像をデータベースと端末から削除する
            // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
            let alert: UIAlertController = UIAlertController(title: "講義と画像の削除", message: "関連する画像を全て削除しますか？", preferredStyle:  UIAlertControllerStyle.alert)
            // deleteボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertActionStyle.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                // ボタンが押された時の処理を
                print("delete")
                //画像をデータベースと端末から削除
                self.kougiDelete(indx: indexPath.row)
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            //todoList?.remove(at: indexPath.row)
        }
    }
    func kougiDelete(indx: Int){
        //kougiIDで削除する講義の画像を全部取得する。
        let realm = try! Realm()
        var gazouresult = realm.objects(Gazou.self)
        gazouresult = gazouresult.filter("kougiId=='"+(results[indx].id!)+"'")
        //画像が存在したら
        if !gazouresult.isEmpty{
            //画像削除＋Gazouテーブル削除ß
            let fileManager = FileManager.default
            if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
                for cnt in 0..<gazouresult.count{
                    let filePath =  dir.appendingPathComponent(gazouresult[cnt].path!)
                    do{
                        try fileManager.removeItem(at: filePath)
                        //タグを消すプログラムは面倒なので未記述
                    }catch{
                        print("\(String(describing: gazouresult[cnt].id))---画像削除失敗")
                    }
                }
                //gazouresult一括削除
                try! realm.write {
                    realm.delete(gazouresult)
                }
            }
        }
        //Kougitable削除
        try! realm.write {
            realm.delete(results[indx])
            print("Kougi削除")
        }
        todoTableView.reloadData()
    }
    @IBOutlet var todoTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        ////
        // (1)Realmのインスタンスを生成する
        do{
            let realm = try Realm()
            results = realm.objects(Kougi.self)
            print(results)
            todoTableView.reloadData()
        }catch{
            print("error1")
        }
        ////
        //画像を保存するフォルダがなかったら作成する。/noteImage
        //ドキュメントフォルダまでのパス取得
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            //ドキュメントフォルダまでパスにフォルダのパスも追加
            let filePath =  dir.appendingPathComponent("noteImage")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    //directory作成
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("directoryをDocuments内に作成できませんでした")
                }
            }else{
                print("directoryは作成できませんでした")
            }
            print("作成されました ー＞ \(filePath)")
        }
    }
    //Cellが選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //resultsのindexpathから講義IDを読み込む
        let kougiIdResults = results[indexPath.row]
        toIVCkougiId = kougiIdResults.id
        toKouginame = kougiIdResults.name
        if toIVCkougiId != nil {
            // ImageViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toImageViewController",sender: nil)
        }
        /*
        let storyboard: UIStoryboard = self.storyboard!
        let imageVC = storyboard.instantiateViewController(withIdentifier: "ImageViewPage") as! ImageViewController
        self.navigationController?.pushViewController(imageVC, animated: true)
        table.deselectRow(at: indexPath, animated: true)
        */
    }
    
    // 画面遷移のSegue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toImageViewController") {
            let ImageVC: ImageViewController = (segue.destination as? ImageViewController)!
            // ImageViewControllerのoneKougiId変数に選択されたkougiIDを設定する
            ImageVC.oneKougiId = toIVCkougiId
            ImageVC.kouginame = toKouginame
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //画面表示時に更新
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        todoTableView.reloadData()
    }
    
}

