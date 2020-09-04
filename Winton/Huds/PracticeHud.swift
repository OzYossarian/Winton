//
//  PracticeHud.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import UIKit
import SpriteKit

class PracticeHud: InvertibleHud
{
    private(set) var labelNode: SKLabelNode!
    var rotationWheel: RotationWheel!
    
    override init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets, hand: InversionController.Handedness, inversionControl: InversionController)
    {
        super.init(size: size, safeSize: safeSize, insets: insets, hand: hand, inversionControl: inversionControl)
        
        initialiseScene()
    }
    
    private func initialiseScene()
    {
        initialiseStartLabel()
        
        let texture = SKTexture(imageNamed: "art.scnassets/RotationBase.png")
        rotationWheel = RotationWheel(texture: texture, color: UIColor.white, size: texture.size())
        addChild(rotationWheel)
    }
    
    private func initialiseStartLabel()
    {
        let position = CGPoint(x: safeAreaLeft + 14, y: safeAreaTop - 46)
        labelNode = standardLabelNode(fontSize: Constants.MediumFont, position: position, alignment: SKLabelHorizontalAlignmentMode.left, text: "PLAY", colour: UIColor.black)
        labelNode.alpha = 0
        addChild(labelNode)
        
        if handedness != InversionController.Handedness.right
        {
            inversionController.flipLabelNode(node: labelNode, sceneSize: self.size)
        }
    }
    
    override func invert(hand: InversionController.Handedness)
    {
        super.invert(hand: hand)
        inversionController.flipLabelNode(node: labelNode, sceneSize: self.size)
    }
    
    func fadeInLabel()
    {
        labelNode.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

