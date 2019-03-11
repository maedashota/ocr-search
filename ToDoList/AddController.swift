import UIKit
import RealmSwift
import Foundation
class AddController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        
        if (textField.text != nil) && textField.text != ""{
            //id作成用
            let f = DateFormatter()
            f.dateFormat = "yyyyMMddHHmmss"
            let now = Date()
            print(f.string(from: now))
            // オブジェクト作成
            let kougiCre = Kougi()
            kougiCre.id = f.string(from: now)
            kougiCre.name = textField.text!
            kougiCre.teacher = "---"
            
            //書き込み
            // (1)Realmのインスタンスを生成する
            let realm = try! Realm()
            // (2)書き込みトランザクション内でデータを追加する
            try! realm.write {
                realm.add(kougiCre)
                print("kougi Saved")
            }
            
            //todoList?.append(textField.text!)
            textField.text = ""
            textField.placeholder = "講義を追加…"
            
            let results = realm.objects(Kougi.self)
            print(results)
            //１つ追加したら戻る
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
