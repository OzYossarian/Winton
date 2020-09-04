//
//  WelcomeScene.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import UIKit
import SpriteKit

class WelcomeHud: BaseHud
{
    private(set) var leftLabelNode: SKLabelNode!
    private(set) var rightLabelNode: SKLabelNode!
    
    override init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets)
    {
        super.init(size: size, safeSize: safeSize, insets: insets)
        
        let fontSize: CGFloat = Constants.MediumFont
        let positionOffset: CGFloat = 120
        
        let left = CGPoint(x: safeAreaCenterX - positionOffset, y: safeAreaCenterY)
        let right = CGPoint(x: safeAreaCenterX + positionOffset, y: safeAreaCenterY)
        
        leftLabelNode = standardLabelNode(fontSize: fontSize, position: left, alignment: SKLabelHorizontalAlignmentMode.center, text: "LEFT", colour: UIColor.black)
        rightLabelNode = standardLabelNode(fontSize: fontSize, position: right, alignment: SKLabelHorizontalAlignmentMode.center, text: "RIGHT", colour: UIColor.black)
        
        addChild(leftLabelNode)
        addChild(rightLabelNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

