//
//  ViewController.swift
//  ByColor
//
//  Created by Owner on 2019/07/10.
//  Copyright © 2019 Owner. All rights reserved.
//

import UIKit
import Photos
import DKImagePickerController

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate{
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var selectPhotos: UIButton!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var makeNewAlbum: UIButton!
    @IBOutlet weak var setting: UIButton!
    //    @IBOutlet weak var collectionView: UICollectionView!
    var request: PHAssetCollectionChangeRequest! // ユーザーへの許可のリクエスト
    var myAlert: UIAlertController! // アラート
    var myOKAction: UIAlertAction! // AlertのOKAction
    var myNOAction: UIAlertAction! // AlertのキャンセルAction
    var text: String! // アルバム名を保存するtext
    var myAlbum: [String] = [] //photoAlbumにあるアルバムの配列
    var photosToPresent: [UIImage] = [] //選択した写真を表示するための配列
    var photosToPresent2: [DKAsset] = []
    var deleteTarget: PHAssetCollection! //削除するアルバム
    
    
    override func viewDidAppear(_ animated: Bool) {

        updateData()
    } //viewDidAppear
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PhotoKitの使用をユーザーから許可を得る.
        PHPhotoLibrary.requestAuthorization { status -> Void in
            switch(status){
            case .authorized:
                print("Authorized")
            case .denied:
                print("Denied")
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        }
        //colorNameArray = saveData.object(forKey: "colorNameArray") as? [String] ?? [] // as?で後ろの型へ変換。しかしoptional型なので、nilになる可能性がある。??をつけることで空の時の値を入れる。
        
        //nibNameにファイル名
        //forCellReuseIdentifierに先程設定したxibファイルのidentityの名前
        table.register(UINib(nibName: "TableViewCell", bundle: nil),forCellReuseIdentifier:"TableViewCell")
        configureTableView()
        
        table.dataSource = self //TableViewのDataSourceメソッドはviewControllerクラスに書くという意味
        table.delegate = self //tableViewのdelegateメソッドはviewControllerクラスに書くという意味
        
        let list = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        for i in 0 ..< list.count {
            let item = list.object(at: i)
            myAlbum.append(item.localizedTitle!)
        }
        
        confirmAlbums(necessaryColor: "白")
        confirmAlbums(necessaryColor: "黒")
        confirmAlbums(necessaryColor: "赤")
        confirmAlbums(necessaryColor: "緑")
        confirmAlbums(necessaryColor: "青")
        confirmAlbums(necessaryColor: "黄")
        confirmAlbums(necessaryColor: "茶")
        
        updateData()
        
        self.selectPhotos.addTarget(self, action: #selector(self.selectPhotosTapped(_:)), for: .touchUpInside)
        self.makeNewAlbum.addTarget(self, action: #selector(self.makeNewAlbumTapped(_:)), for: .touchUpInside)
        selectPhotos.layer.cornerRadius = 5
        camera.layer.cornerRadius = 5
        makeNewAlbum.layer.cornerRadius = 5
        makeNewAlbum.titleLabel?.numberOfLines = 0
        makeNewAlbum.setTitle("Make a new album", for: .normal)
        setting.layer.cornerRadius = 5
        
    } //viewDidLoad
    
    
    func confirmAlbums(necessaryColor: String) {
        if !myAlbum.contains(necessaryColor) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: necessaryColor)
            }) { (isSuccess, error) in
                self.myAlbum.append(necessaryColor)
            }
        }else{
        }
    } //confirmAlbums
    
    func updateData() {
        //myAlbumを初期化
        myAlbum = []
        
        //アルバムの情報を持って来て更新
        // フォトアプリの中にあるアルバムを検索する.
        let list = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        // リストの中にあるオブジェクトに対して１つずつ呼び出す.
        for i in 0 ..< list.count {
            let item = list.object(at: i)
            // アルバムのタイトル名をコレクションする.
            myAlbum.append(item.localizedTitle!)
        }
        print(myAlbum)
        
        //tableをreload
        DispatchQueue.main.async {
            self.table.reloadData() //セルの情報更新を呼び出す
        }
        
    } //updateData
    
    //セルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAlbum.count //セル数をmyAlbumの数にする
    }
    
    //セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    } //この命令はtableViewへの設定なので、customCellでも普通のcellでも決めた高さにできる。
    
    //ID付きのセルを取得し、セル付属のtextLabelに文字を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor.white
        cell.colorNamelabel.text = myAlbum[indexPath.row] //セルにmyAlbumの名前を表示
        cell.delegate = self as TableViewCellDelegate
        // cell.setCell(myCustomDatas[indexPath.row])
        return cell
        
    } //tableView
    
    func configureTableView() {
        table.rowHeight = 50
    }
    
    
    @objc func makeNewAlbumTapped(_ sender: UIButton){
        
        myAlert = UIAlertController(title: "新規アルバム", message: "新しく作るアルバム名を入力します。", preferredStyle: .alert)
        
        myNOAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { action in
            print("cancel")
        }
        
        myOKAction = UIAlertAction(title: "OK", style: .default) { action in
            PHPhotoLibrary.shared().performChanges({
                
                // iOSのフォトアルバムにコレクション(アルバム)を追加する.
                self.request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.text)
                
            }, completionHandler: { (isSuccess, error) -> Void in
                if isSuccess {
                    print("Success!")
                    //     self.colorNameLabel.text = self.text
                    self.myAlbum.append(self.text)
                    //self.saveData.set(self.colorNameArray, forKey: "colorNameArray")
                    
                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
                    
                } else {
                    print("error occured")
                }
            })
        }
        
        myOKAction.isEnabled = false
        
        myAlert.addTextField { textField in
            // 編集が終わる(returnキーが押される)とメソッドが呼び出される.
            textField.addTarget(self, action: #selector(self.onTextEnter(sender:)), for: UIControl.Event.editingChanged)
        }
        
        myAlert.addAction(myNOAction)
        myAlert.addAction(myOKAction)

        present(myAlert, animated: true, completion: nil)
        
    } //makeNewAlbumTapped
    
    
    //TextFieldのTextの編集が終了した時に呼ばれるメソッド.
    @objc func onTextEnter(sender: UITextField){
        text = sender.text
        myOKAction.isEnabled = true
    }
    
    @objc func selectPhotosTapped(_ sender: UIButton) {
        
        photosToPresent2 = []
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 30
        
      //置き換え後
        //終わった後の動作
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in

            for asset in assets{

                asset.fetchFullScreenImage(completeBlock: { (image, info) in

                        self.photosToPresent2.append(asset)

                    if self.photosToPresent2.count == assets.count{
                        self.dismiss(animated: true, completion: nil)

                        if self.photosToPresent2.count >= 1 {
                            self.performSeguetoSecondView()
                        }else{
                        }
                    } //この処理をcompleteBlockの中にかく。
                }) //completeBlockの丸括弧の処理が終わるが終わる前に次に移ってしまう。
            }
        }
        
        
//        //置き換え前
//        //終わった後の動作
//        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
//
//            for asset in assets{
//                //self.photosToPresent.append(asset.image!) //エラー
//                asset.fetchFullScreenImage(completeBlock: { (image, info) in
//                    if let image = image {
//                        self.photosToPresent.append(image)
//                    }
//
//                    if self.photosToPresent.count == assets.count{
//                        self.dismiss(animated: true, completion: nil)
//
//                        if self.photosToPresent.count >= 1 {
//                            self.performSeguetoSecondView()
//                        }else{
//                        }
//                    } //この処理をcompleteBlockの中にかく。
//                }) //completeBlockの丸括弧の処理が終わるが終わる前に次に移ってしまう。
//            }
//        }
        
        self.present(pickerController, animated: true) {}
        
    } //selectPhotosButtonTapped
    
    //使わない
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //
    //        //imageに選んだ画像を設定する
    //        let image = info[.originalImage] as? UIImage
    //
    //        // photosToPresent.append(UIImage(named: image))
    //
    //        //photoLibraryを閉じる
    //        self.dismiss(animated: true, completion: nil)
    //
    //        photosToPresent.append(image!) //!をつけるとアンラップ
    //
    //        performSeguetoSecondView()
    //
    //    } //imagePickerContrller
    

    func performSeguetoSecondView() {
        performSegue(withIdentifier: "toSecondView", sender: nil)
        print("segue presented")
    }
    
    //置き換え後
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondView" {
            let SecondViewController = segue.destination as! SecondViewController
            SecondViewController.photosToPresent2 = self.photosToPresent2
        }
    } //prepare
    
//    //置き換え前
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toSecondView" {
//            let SecondViewController = segue.destination as! SecondViewController
//            SecondViewController.photosToPresent = self.photosToPresent
//        }
//    } //prepare
    
    
    
    func openAlbum(albumName: String) {
        
        //アルバムを取得
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title=%@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if collection.firstObject != nil {
            
            let fileURL: URL = URL(fileURLWithPath: "") // ここに保存したい画像の場所が入る　例えば選択した画像を渡したいのであれば、それをここで指定
            
            //ファイルをアルバムに保存する
            PHPhotoLibrary.shared().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection.firstObject!)
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }) { (isSuccess, error) in
                if isSuccess {
                    // 保存成功
                } else {
                    // 保存失敗
                }
                
            }
            // 取得成功(->collection.firstObject)
            
        } else {
            // 取得失敗
        }
    } //openAlbum
    
    //アルバム名を変更
    func changeNameAction() {
        
    }
    
    //     func deleteDispensableAlbums() {
    //
    //            // フォトアプリの中にあるアルバムを検索する.
    //            let list = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
    //            // リストの中にあるオブジェクトに対して１つずつ呼び出す.
    //            for i in 0 ..< list.count {
    //                // 選択した名前と同じ名前のアルバムを取得.
    //                let item = list.object(at: i)
    //                if item.localizedTitle == "白" {
    //                    // 削除する対象のアルバムを代入する.
    //                    self.deleteTarget = item
    //                }
    //            }
    //
    //            // フォトライブラリに変更を要請する.
    //            PHPhotoLibrary.shared().performChanges({
    //                // 削除対象のアルバムを引数に渡す.
    //                PHAssetCollectionChangeRequest.deleteAssetCollections([self.deleteTarget] as NSFastEnumeration)
    //            }, completionHandler: nil)
    //
    //        updateData()
    //    }
    
    //    //アルバムを削除する
    //        func removeAction(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //            // フォトアプリの中にあるアルバムを検索する.
    //            let list = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
    //            // リストの中にあるオブジェクトに対して１つずつ呼び出す.
    //            for i in 0 ..< list.count {
    //                // 選択した名前と同じ名前のアルバムを取得.
    //                let item = list.object(at: i)
    //                if item.localizedTitle == myAlbum[indexPath.row] {
    //                    // 削除する対象のアルバムを代入する.
    //                    self.deleteTarget = item
    //                }
    //
    //                // フォトライブラリに変更を要請する.
    //                PHPhotoLibrary.shared().performChanges({
    //                    // 削除対象のアルバムを引数に渡す.
    //                    PHAssetCollectionChangeRequest.deleteAssetCollections([self.deleteTarget] as NSFastEnumeration)
    //                }, completionHandler: nil)
    //            }
    //
    //        } //removeActionw終わり
    
    
}



////<collectionView>
//extension ViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 3
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//
//        return cell
//    }
//}
////</collectionView>


