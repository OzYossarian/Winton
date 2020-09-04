//
//  BaseHud.swift
//  Winton
//
//  Created by Alex Teague on 04/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit

class BaseHud: SKScene
{
    private(set) var safeAreaSize: CGSize!
    private(set) var safeAreaInsets: UIEdgeInsets!
    
    var trueCenterX: CGFloat
    {
        get { return self.size.width/2 }
    }
    
    var trueCenterY: CGFloat
    {
        get { return self.size.height/2 }
    }
    
    var trueCenter: CGPoint
    {
        get { return CGPoint(x: trueCenterX, y: trueCenterY) }
    }
    
    var safeAreaCenter: CGPoint
    {
        get { return CGPoint(x: safeAreaCenterX, y: safeAreaCenterY) }
    }
    
    var safeAreaCenterX: CGFloat
    {
        get { return safeAreaInsets.left + safeAreaSize.width/2 }
    }
    
    var safeAreaCenterY: CGFloat
    {
        get { return safeAreaInsets.bottom + safeAreaSize.height/2 }
    }
    
    var safeAreaTop: CGFloat
    {
        get { return safeAreaInsets.bottom + safeAreaSize.height }
    }
    
    var safeAreaLeft: CGFloat
    {
        get { return safeAreaInsets.left }
    }
    
    var safeAreaBottom: CGFloat
    {
        get { return safeAreaInsets.bottom }
    }
    
    var safeAreaRight: CGFloat
    {
        get { return safeAreaInsets.left + safeAreaSize.width }
    }
    
    init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets)
    {
        super.init(size: size)
        
        safeAreaSize = safeSize
        safeAreaInsets = insets
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func standardLabelNode(fontSize: CGFloat, position: CGPoint, alignment: SKLabelHorizontalAlignmentMode, text: String, colour: UIColor) -> SKLabelNode
    {
//        let node = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        let node = SKLabelNode(fontNamed: "Chalkduster")
//        let node = SKLabelNode(fontNamed: "Zapfino")
        
        node.fontSize = fontSize
        node.fontColor = colour
        
        node.position = position
        node.horizontalAlignmentMode = alignment
        node.text = text
        
        return node
    }
}
