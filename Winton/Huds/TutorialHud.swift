//
//  TutorialHud.swift
//  Winton
//
//  Created by Alex Teague on 02/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit

class TutorialHud: PracticeHud
{
    private var swipeDemoNode: SKSpriteNode!
    private var swipeStartPosition: CGPoint!
    private let swipeLength: Double = 75
    private let swipeDuration: Double = 0.6
    private let waitBetweenSwipes: Double = 0.5
    private let rotationWheelOffset: CGPoint = CGPoint(x: -10, y: 30)
    
    private var rotationQueue: RotationQueue<RotationController.Rotation>!
    var rotationDelegate: RotationDemoDelegate?
    
    override init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets, hand: InversionController.Handedness, inversionControl: InversionController)
    {   
        super.init(size: size, safeSize: safeSize, insets: insets, hand: hand, inversionControl: inversionControl)
        
        configureLabelNode()
        initialiseSwipeDemoNode()
        configurePositions()
        
        rotationQueue = RotationQueue<RotationController.Rotation>(size: nil, rotationMethod: simulateRotation)
    }
    
    private func configureLabelNode()
    {
        labelNode.text = "SKIP"
        if SessionInfo.TutorialCompleted
        {
            let wait = SKAction.wait(forDuration: 2)
            let fadeIn = SKAction.fadeIn(withDuration: 1)
            labelNode.run(SKAction.sequence([wait, fadeIn]))
        }
        else
        {
            labelNode.alpha = 0
        }
    }
    
    private func initialiseSwipeDemoNode()
    {
        let swiperSelector = arc4random_uniform(2)
        let swiper = swiperSelector == 0 ? "HandOne" : "HandTwo"
        swipeDemoNode = SKSpriteNode(imageNamed: "art.scnassets/\(swiper).png")
        swipeDemoNode.alpha = 0
        addChild(swipeDemoNode)
    }
    
    private func configurePositions()
    {
        var position = CGPoint(x: safeAreaRight - 125, y: safeAreaBottom + 75)
        if handedness != InversionController.Handedness.right
        {
            position = inversionController.flipCGPoint(position, sceneSize: self.size)
        }
        swipeStartPosition = position
        swipeDemoNode.position = swipeStartPosition
    }
    
    func simulateRotations(_ rotations: [RotationController.Rotation])
    {
        rotationQueue.enqueue(rotations)
    }
    
    private func simulateRotation(rotation: RotationController.Rotation, completion: @escaping () -> Void)
    {
        prepareSwipe(completion: {
            self.swipe(direction: rotation, completion: completion)
            })
    }
    
    private func prepareSwipe(completion: @escaping () -> Void)
    {
        let wait = SKAction.wait(forDuration: 0.2)
        let hover = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        let press = SKAction.fadeAlpha(to: 1, duration: 0)
        
        let firstActions = SKAction.sequence([wait, hover, press])
        let rotationWheelPosition = CGPoint(x: swipeStartPosition.x + rotationWheelOffset.x, y: swipeStartPosition.y + rotationWheelOffset.y)
        
        swipeDemoNode.run(firstActions, completion: {
            DispatchQueue.global().async {
                self.rotationWheel.showBase(location: rotationWheelPosition)
                completion()
            }
        })
    }
    
    private func swipe(direction: RotationController.Rotation, completion: @escaping () -> Void)
    {
        let translation = getTranslation(direction: direction)
        let newPosition = CGPoint(x: swipeStartPosition.x + translation.x, y: swipeStartPosition.y + translation.y)
        let swipe = SKAction.move(to: newPosition, duration: swipeDuration)
        
        let wait = SKAction.wait(forDuration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        let reset = SKAction.move(to: swipeStartPosition, duration: 0)
        let waitBeforeNextSwipe = SKAction.wait(forDuration: waitBetweenSwipes)
        let finalActions = SKAction.sequence([wait, fade, reset, waitBeforeNextSwipe])
        
        swipeDemoNode.run(swipe, completion: {
            DispatchQueue.global().async {
                self.rotationDelegate?.demonstrateRotation(direction)
                self.swipeDemoNode.run(finalActions, completion: completion)
            }
        })
    }
    
    private func getTranslation(direction: RotationController.Rotation) -> CGPoint
    {
        switch direction
        {
        case RotationController.Rotation.right:
            return CGPoint(x: swipeLength, y: 0)
        case RotationController.Rotation.upRight:
            let x = swipeLength * cos(Double.pi/3)
            let y = swipeLength * sin(Double.pi/3)
            return CGPoint(x: x, y: y)
        case RotationController.Rotation.upLeft:
            let x = -(swipeLength) * cos(Double.pi/3)
            let y = swipeLength * sin(Double.pi/3)
            return CGPoint(x: x, y: y)
        case RotationController.Rotation.left:
            return CGPoint(x: -(swipeLength), y: 0)
        case RotationController.Rotation.downLeft:
            let x = -(swipeLength) * cos(Double.pi/3)
            let y = -(swipeLength) * sin(Double.pi/3)
            return CGPoint(x: x, y: y)
        case RotationController.Rotation.downRight:
            let x = swipeLength * cos(Double.pi/3)
            let y = -(swipeLength) * sin(Double.pi/3)
            return CGPoint(x: x, y: y)
        default:
            fatalError("Unrecognised rotation type.")
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
