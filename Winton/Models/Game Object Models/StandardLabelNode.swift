//
//  StandardLabelNode.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit

class StandardLabelNode: SKLabelNode
{
    override init()
    {
        super.init()
    }
    
    init(fontSize: CGFloat, position: CGPoint, alignment: SKLabelHorizontalAlignmentMode, text: String, colour: UIColor)
    {
        super.init()
        
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        
        self.fontSize = fontSize
        self.fontColor = colour
        self.fontName = font.fontName
        
        self.position = position
        self.horizontalAlignmentMode = alignment
        self.text = text
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

