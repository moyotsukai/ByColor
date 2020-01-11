//
//  TableViewCell.swift
//  ByColor
//
//  Created by Owner on 2019/09/11.
//  Copyright © 2019 Owner. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var colorNamelabel: UILabel!
    
//    @IBOutlet weak var addPhotosToMyAlbum: UIButton!
//    @IBOutlet weak var changeName: UIButton!
//    @IBOutlet weak var removeAlbum: UIButton!
    
    weak var delegate: TableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.addPhotosToMyAlbum.addTarget(self, action: #selector(addPhotosToMyAlbumTapped(_:)), for: .touchUpInside)
//        self.changeName.addTarget(self, action: #selector(changeNameTapped(_:)), for: .touchUpInside)
//        self.removeAlbum.addTarget(self, action: #selector(removeAlbumTapped(_:)), for: .touchUpInside)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
//    @objc func addPhotosToMyAlbumTapped(_ sender: UIButton) {
//        // ask the delegate (in most case, its the view controller) to
//        // call the function 'subscribeButtonTappedFor' on itself.
//        delegate?.openAlbum(albumName: colorNamelabel.text ?? "")
//    }
    
//    @objc func removeAlbumTapped(_ sender: UIButton) {
//        delegate?.removeAction(_, tableView: UITableView, didSelectRowAt, indexPath: IndexPath)
//    }
    
//    @objc func changeNameTapped(_ sender: UIButton) {
//        delegate?.changeNameAction()
//
//    }
} //Class


// Only class object can conform to this protocol (struct/enum can't)
protocol TableViewCellDelegate: AnyObject {
//    func openAlbum(albumName: String)
//    func removeAction(tableView: String)
}


//remove: colorNamelabel.text ?? ""
