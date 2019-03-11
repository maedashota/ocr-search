//
//  SearchViewController.swift
//  ToDoList
//
//  Created by k16102kk on 2018/12/10.
//  Copyright © 2018年 maya tominaga. All rights reserved.
//

import UIKit
import Foundation

class SearchViewController: UIViewController {
    //KougiIDを受け取る
    var sKougiId:String!
    @IBOutlet weak var searchTextBox: UITextField!
    //検索文字列を入れる
    var searchText: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func searchbtn(_ sender: Any) {
        //検索配列を初期化
        searchText.removeAll()
        //Textboxから検索文字列を取得し、空白で区切って配列に代入
        var textBoxText:String! = searchTextBox.text!
        //1:全角スペースを半角スペースに置換　2:前後のスペース削除　3:2つ以上続く半角スペースを1つに置換 4:配列に分割
        textBoxText = textBoxText.replacingOccurrences(of:"　", with: " ")
        textBoxText = textBoxText.trimmingCharacters(in: .whitespaces)
        textBoxText = textBoxText.replacingOccurrences(of: " {2,}", with: "", options: .regularExpression);
        searchText = textBoxText.components(separatedBy:CharacterSet.whitespaces)
        
        //最後に結果画面へ遷移
        //searchViewへ遷移するSegue
        performSegue(withIdentifier: "toResultView",sender: nil)
    }
    // 画面遷移のSegue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toResultView") {
            let resultVC: ResultViewController = (segue.destination as? ResultViewController)!
            //送るもの
            resultVC.rKougiId = sKougiId
            resultVC.searchStr.removeAll()
            resultVC.searchStr.append(contentsOf: searchText)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backbtn(_ sender: Any) {
        //親ビューのコレクションビューを更新& back
        let parentVCa = self.presentingViewController as! ImageViewController
        parentVCa.reloadCollection()
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
