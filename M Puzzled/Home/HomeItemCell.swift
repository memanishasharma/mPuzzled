//
//  HomeItemCell.swift
//  M Puzzled
//
//  Created by Manisha on 14/09/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import Foundation
import UIKit

class HomeItemCell: UITableViewCell {
	
	@IBOutlet var mainView: UIView!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var cardBg: UIView!
	@IBOutlet var iconImageView: UIImageView!
	
	func useMember(_ member:HomeItem) {
		nameLabel.text = member.title?.uppercased()
		nameLabel.font = UIFont(name: "Roboto-Light", size: 20)
		
	}
}
