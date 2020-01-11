//
//  SecondViewController.swift
//  ByColor
//
//  Created by Owner on 2019/11/06.
//  Copyright © 2019 Owner. All rights reserved.
//

import UIKit
import Photos
import DKImagePickerController

class SecondViewController: UIViewController {
    
    var tapPoint = CGPoint(x: 0, y: 0)
    var photosToPresent2: [DKAsset] = [] //選択した写真を表示するための配列、値を受け渡す場合は渡す側にも受ける側にも宣言を書く。
    //var Albums: [String] = []
    var index: Int = 0
    var toWhichAlbum: [String] = ["白", "黒", "赤", "緑", "青", "黄", "茶"]
    var R: Int = 0
    var G: Int = 0
    var B: Int = 0
    var A: Float = 1
    var imageSizeRatio: CGFloat!
    
    var selectedPhotosImageView = UIImageView() //photosToPresentに入っている写真を表示するためのUIImageView
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var RGBLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        
        RGBLabel.layer.cornerRadius = 5
        backButton.layer.cornerRadius = 5
        nextButton.layer.cornerRadius = 5
        doneButton.layer.cornerRadius = 5
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), for: .touchUpInside)
        self.nextButton.addTarget(self, action: #selector(self.nextButtonTapped(_:)), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(self.doneButtonTapped(_:)), for: .touchUpInside)
        doneButton.isHidden = true
        
        self.view.addSubview(selectedPhotosImageView)
        selectedPhotosImageView.isUserInteractionEnabled = true
        selectedPhotosImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(("getImageRGB:"))))
        //selectedPhotosImageView.image = photosToPresent[index]
        
        
        
    photosToPresent2[index].fetchFullScreenImage(completeBlock: { (image, info) in
        if let image = image {
            self.selectedPhotosImageView.image = image //これはcompleteBlock内に書く
            self.adjustImageView()
        }
        })
                
        if photosToPresent2.count == 1 {
            nextButton.isHidden = true
            backButton.isHidden = true
            doneButton.isHidden = false
        }
        
    } //viewDidLoad
    
    func adjustImageView() {
        let image = selectedPhotosImageView.image
        
        let imageSize = CGSize(width: image!.size.width, height: image!.size.height)
        selectedPhotosImageView.frame.size = CGSize(width: self.view.frame.size.width * 0.95, height: self.view.frame.size.height * 0.65)
        
        selectedPhotosImageView.contentMode = UIView.ContentMode.scaleAspectFit
        selectedPhotosImageView.image = image
        
        if imageSize.width > imageSize.height {
            //横長の場合
            selectedPhotosImageView.frame.size.height = imageSize.height/imageSize.width * selectedPhotosImageView.frame.width
            
            imageSizeRatio = imageSize.width/selectedPhotosImageView.frame.size.width //ここの分母分子逆にしない（viewが小さくなる分tapPointの距離は長くしないといけない）
        }else{
            //縦長の場合
            selectedPhotosImageView.frame.size.width = imageSize.width/imageSize.height * selectedPhotosImageView.frame.height
            imageSizeRatio = imageSize.width/selectedPhotosImageView.frame.size.width
        }
        selectedPhotosImageView.center = self.view.center //これの位置ここ
        
        print(imageSize)
        print(selectedPhotosImageView.frame.size)
    } //adjustImageView
    
    @IBAction func getImageRGB(_ sender: UITapGestureRecognizer) {
        //TapGestureRecogniserの編集画面でEnabledにするのを忘れない。
        
        guard selectedPhotosImageView.image != nil else {return}
        
        //タップした座標の取得
        tapPoint = sender.location(in: selectedPhotosImageView)
        //タッチして離した位置にしたい。
        print(" tapPoint: \(tapPoint)")
        
        let cgImage = selectedPhotosImageView.image?.cgImage!
        let pixelData = cgImage?.dataProvider!.data
        let data: UnsafePointer = CFDataGetBytePtr(pixelData)
        //1ピクセルのバイト数
        let bytesPerPixel = (cgImage?.bitsPerPixel)! / 8
        //1ラインのバイト数
        let bytesPerRow = (cgImage?.bytesPerRow)!
        print("bytesPerPixel=\(bytesPerPixel) bytesPerRow=\(bytesPerRow)")
        //タップした位置の座標にあたるアドレスを算出
        let pixelAd: Int = Int(tapPoint.y * imageSizeRatio) * bytesPerRow + Int(tapPoint.x * imageSizeRatio) * bytesPerPixel //ここでbytesPerRpwを補正
        //それぞれRGBAの値をとる
        let r = Int( CGFloat(data[pixelAd]))
        let g = Int( CGFloat(data[pixelAd+1]))
        let b = Int( CGFloat(data[pixelAd+2]))
        let a = CGFloat(Int( CGFloat(data[pixelAd+3])/CGFloat(255.0)*100)) / 100
        
        print([r,g,b,a])
        print("imageSizeRatio: \(String(describing: imageSizeRatio))")
        print("pixelAd: \(pixelAd)")
        
        //RGBLabelに結果を表示
        R = (Int(r))
        G = (Int(g))
        B = (Int(b))
        A = (Float(a))
        //        A = (Float(format: "%.1f", a))
        print([R,G,B,A])
        
        RGBLabel.text = "R: \(R) + G: \(G) + B: \(B) + A: \(A)" //後で消す
        
        RGBLabel.backgroundColor = UIColor.RGBAForLabel(red: r, green: g, blue: b, alpha: a)
        
        print("R+G+B, A: \(Int(r) + Int(g) + Int(b)), \(Float(a))")
        
        if Int(r) + Int(g) + Int(b) < 340 && Float(a) > 0.5 {
            RGBLabel.textColor = UIColor.RGBAForLabel(red: 225, green: 225, blue: 225, alpha: 1)
            
        }else{
            RGBLabel.textColor = UIColor.RGBAForLabel(red: 35, green: 35, blue: 35, alpha: 1)
        }
        
        classify()
        
    } //getImageRGB
    
    @objc func nextButtonTapped(_ sender: UIButton) {
        
        if index == photosToPresent2.count - 1 {
            print("nextMax")
        }else{
            index += 1
            photosToPresent2[index].fetchFullScreenImage(completeBlock: { (image, info) in
            if let image = image {
                self.selectedPhotosImageView.image = image
                self.adjustImageView()
            }
            })
            
            print("next+1")
            if index == photosToPresent2.count - 1 {
                nextButton.isHidden = true
                backButton.isHidden = true
                doneButton.isHidden = false
            }else{
            }
        }
        animateImageView()
    } //nextButtonTapped
    
    let animationDuration: TimeInterval = 0.2
    let switchingInterval: TimeInterval = 0.2
    
    func animateImageView() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.switchingInterval) {
                self.animateImageView()
            }
        }
        
        let transition = CATransition()
        transition.type = CATransitionType.fade
        
        selectedPhotosImageView.layer.add(transition, forKey: kCATransition)
        CATransaction.commit()
    } //animateImageView
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func classify() {
        
        var album: String
        
        if R >= 125 && G >= 125 && B >= 125 && abs(R-G) <= 20 && abs(R-B) <= 20 && abs(G-B) <= 20 {
            album = toWhichAlbum[0]
            RGBLabel.text = "白に追加されます。"
            
        }else if R < 125 && G < 125 && B < 125 && abs(R-G) <= 20 && abs(R-B) <= 20 && abs(G-B) <= 20 {
            album = toWhichAlbum[1]
            RGBLabel.text = "黒に追加されます。"
            
        }else if R > 130 && G > 30 && B > 30 && R-G >= 90 && R-B >= 60 {
            album = toWhichAlbum[2]
            RGBLabel.text = "赤に追加されます。"
            
        }else if R > 70 && G > 100 && B > 70 && G-R >= 30 && G-B >= 30 {
            album = toWhichAlbum[3]
            RGBLabel.text = "緑に追加されます。"
            
        }else if R > 10 && G > 50 && B > 140 && B-R >= 40 {
            album = toWhichAlbum[4]
            RGBLabel.text = "青に追加されます。"
            
        }else if R > 130 && G > 130 && R-B >= 60 && G-B >= 90 {
            album = toWhichAlbum[5]
            RGBLabel.text = "黄に追加されます。"
            
        }else if R < 170 && G < 100 && B < 10 && R-G <= 100 && R-B <= 30 {
            album = toWhichAlbum[6]
            RGBLabel.text = "茶に追加されます。"
            
        }else {
            album = "その他"
        }
        
        //アルバムを取得
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title=%@", album)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //let image = NSTemporaryDirectory().photosToPresent[0]
        
        if collection.firstObject != nil {
            //let fileURL = URL(fileURLWithPath: image) //
            
            //ファイルをアルバムに保存する
            PHPhotoLibrary.shared().performChanges({
//                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image!) //これを使わない
                let assetRequest = PHAssetChangeRequest(for: self.photosToPresent2[self.index].originalAsset!) //creationRequestにしないことで、毎回新たに写真を作らずに元々の画像に変更を加えるだけになる。
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection.firstObject!)
                
                albumChangeRequest?.addAssets([assetRequest] as NSFastEnumeration)
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
    } //classify
    
    @objc func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }//back
    
    
    
    
    
    /*
     MARK: - Navigation
     
     In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     Get the new view controller using segue.destination.
     Pass the selected object to the new view controller.
     }
     */
    
}

extension UIColor {
    class func RGBAForLabel(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}




