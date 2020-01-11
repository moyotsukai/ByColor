//
//  CameraViewController.swift
//  ByColor
//
//  Created by Owner on 2019/12/23.
//  Copyright © 2019 Owner. All rights reserved.
//

import UIKit
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var table: UITableView!
    @IBOutlet var guidingLabel: UILabel!
    var myAlbum: [String] = [] //photoAlbumにあるアルバムの配列

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self //TableViewのDataSourceメソッドはviewControllerクラスに書くという意味
        table.delegate = self //tableViewのdelegateメソッドはviewControllerクラスに書くという意味

        let list = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)

        for i in 0 ..< list.count {
            let item = list.object(at: i)
            myAlbum.append(item.localizedTitle!)
        }
        
        guidingLabel.layer.cornerRadius = 5
        backButton.layer.cornerRadius = 5
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
        
    } //viewDidLoad
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAlbum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor.white
        cell.colorNamelabel.text = myAlbum[indexPath.row] //セルにmyAlbumの名前を表示
        cell.delegate = self as? TableViewCellDelegate
        // cell.setCell(myCustomDatas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func cameraShoot() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
            
        }else{
            print("カメラを起動できません。")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let image = info[.editedImage] as? UIImage
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
