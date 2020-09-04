//
//  RotationWheel.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class RotationWheel: SKSpriteNode
{
    private let rotationBase = SKTexture(imageNamed: "art.scnassets/RotationBase.png")
    private let rotationRight = SKTexture(imageNamed: "art.scnassets/RotationRight.png")
    private let rotationUpRight = SKTexture(imageNamed: "art.scnassets/RotationUpRight.png")
    private let rotationUpLeft = SKTexture(imageNamed: "art.scnassets/RotationUpLeft.png")
    private let rotationLeft = SKTexture(imageNamed: "art.scnassets/RotationLeft.png")
    private let rotationDownLeft = SKTexture(imageNamed: "art.scnassets/RotationDownLeft.png")
    private let rotationDownRight = SKTexture(imageNamed: "art.scnassets/RotationDownRight.png")
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showBase(location: CGPoint)
    {
        removeAllActions()
        texture = rotationBase
        position = location
        run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func showRotation(_ rotation: RotationController.Rotation)
    {
        var texture: SKTexture?
        switch rotation
        {
        case RotationController.Rotation.right:
            texture = rotationRight
        case RotationController.Rotation.upRight:
            texture = rotationUpRight
        case RotationController.Rotation.upLeft:
            texture = rotationUpLeft
        case RotationController.Rotation.left:
            texture = rotationLeft
        case RotationController.Rotation.downLeft:
            texture = rotationDownLeft
        case RotationController.Rotation.downRight:
            texture = rotationDownRight
        default:
            fatalError("Unrecognised rotation type.")
        }
        
        if texture != nil
        {
            let setTexture = SKAction.animate(with: [texture!], timePerFrame: 1)
            let wait = SKAction.wait(forDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let actions = [setTexture, wait, fadeOut]
            
            run(SKAction.sequence(actions))
        }
    }
    
    func fadeOut()
    {
        run(SKAction.fadeOut(withDuration: 0.2))
    }
}

