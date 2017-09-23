//
//  CustomColors.swift
//  M Puzzled
//
//  Created by Manisha on 03/08/17.
//  Copyright © 2017 Manisha. All rights reserved.
//

import UIKit

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}
extension UIColor {
	static func random() -> UIColor {
		return UIColor(red:   .random(),
		               green: .random(),
		               blue:  .random(),
		               alpha: 1.0)
	}
	struct FlatColor {
		
		struct materialColor{
			static let Turquoise = UIColor(netHex: "1abc9c")
			static let Emerland = UIColor(netHex: "2ecc71")
			static let Peterriver = UIColor(netHex: "3498db")
			static let Amethyst = UIColor(netHex: "9b59b6")
			static let Wetasphalt = UIColor(netHex: "34495e")
			static let GreenSea = UIColor(netHex: "16a085")
			static let Nephritis = UIColor(netHex: "27ae60")
			static let BelizeHole = UIColor(netHex: "2980b9")
			static let Wisteria = UIColor(netHex: "8e44ad")
			static let Midnightblue = UIColor(netHex: "2c3e50")
			static let SunFlower = UIColor(netHex: "f1c40f")
			static let Carrot = UIColor(netHex: "e67e22")
			static let Alizarin = UIColor(netHex: "e74c3c")
			static let Clouds = UIColor(netHex: "ecf0f1")
			static let Concrete = UIColor(netHex: "95a5a6")
			static let C1 = UIColor(netHex: "f39c12")
			static let C2 = UIColor(netHex: "d35400")
			static let C3 = UIColor(netHex: "c0392b")
			static let C4 = UIColor(netHex: "bdc3c7")
			static let C5 = UIColor(netHex: "7f8c8d")
			static let C6 = UIColor(netHex: "00b294")
			static let C7 = UIColor(netHex: "ff4343")
			
		}
		struct Red{
			
		}
		
		struct Pink{
			
		}
		
		struct Purple{
			
		}
		
		struct DeepPurple{
		
		}
		
		struct Indigo{
			
		}
		
		struct LightBlue{
		
		}
		
		struct Cyan{
			
		}
		
		struct Teal{
			
		}
		
		struct Green{
			
		}
		
		struct LightGreen{
		
		}
		
		struct Lime{
			
		}
		
		struct Yellow{
			
		}
		
		struct Amber{
			
		}
		
		struct Orange {
			
		}
		
		struct DeepOrange{
		
		}
		
		struct Brown{
			
		}
		
		struct Grey{
			
		}
		
		struct Blue{
			static let Blue50 = UIColor(netHex: "#2196F3")
			static let Blue100 = UIColor(netHex: "#E3F2FD")
			static let Blue200 = UIColor(netHex: "#BBDEFB")
			static let Blue300 = UIColor(netHex: "#90CAF9")
			static let Blue400 = UIColor(netHex: "#42A5F5")
			static let Blue500 = UIColor(netHex: "#2196F3")
			static let Blue600 = UIColor(netHex: "#1E885")
			static let Blue700 = UIColor(netHex: "#1976D2")
			static let Blue800 = UIColor(netHex: "#1565C0")
			static let Blue900 = UIColor(netHex: "#0D47A1")
			static let BlueA100 = UIColor(netHex: "#82B1FF")
			static let BlueA200 = UIColor(netHex: "#448AFF")
			static let BlueA400 = UIColor(netHex: "#2979FF")
			static let BlueA700 = UIColor(netHex: "#2962FF")
		}
		
		
		
		struct Violet {
			
		}
		
		struct Gray {
			
		}
	}
}
