import UIKit
import RealmSwift


class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var realm: Realm!
    private var result: Results<Gazou>!
    //private var todoList: Results<Tag>!
    //gazouIdを取得
    var tGazouId: String!

    //private var token: NotificationToken!
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //RealmのTodoリストを取得し，更新を監視
        //realm = try! Realm()
        //todoList = realm.objects(Tag.self)
        //token = todoList.observe { [weak self] _ in
        //    self?.reload()
       // }
    }
    
    //deinit {
    //    token.invalidate()
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // デフォルトRealmを取得
        realm = try! Realm()
        result = realm.objects(Gazou.self)
        result = result.filter("id=='"+(tGazouId)+"'")
        //tableView.reloadData()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        // 新規Todo追加用のダイアログを表示
        let dlg = UIAlertController(title: "Tag追加", message: "", preferredStyle: .alert)
        dlg.addTextField(configurationHandler: nil)
        dlg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = dlg.textFields![0].text,
                !t.isEmpty {
                self.addTagItem(title: t)
            }
        }))
        present(dlg, animated: true)
    }
    
    // 追加
    func addTagItem(title: String) {
        //Tagインスタンス生成
        let tagS = Tag()
        tagS.tagStr = title
        //Tagsに新規タグを追加
        try! realm.write {
            result[0].tags.append(tagS)
        }
        self.reload()
        print(result[0])
    }
    
    // Todoを削除
    func deleteTodoItem(at index: Int) {
        print("delete:")
        print(index)
        try! realm.write {
            realm.delete(result[0].tags[index])
        }
        self.reload()
    }
    
    func reload() {
        tableView.reloadData()
    }
}

extension TagViewController{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c = 0
        if(result != nil){
            c = result[0].tags.count
        }
        print(c)
        return c
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagItem", for: indexPath)
        cell.textLabel?.text = result[0].tags[indexPath.row].tagStr
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        deleteTodoItem(at: indexPath.row)
    }
}

