//
//  GameScene.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class GameScene: BaseGameScene
{
    private(set) var isInGameMode: Bool = false
    
    private(set) var isManuallyPaused: Bool = false
    private var frozenConfetti: SCNParticleSystem?
    
    override internal var canDisplayRotationWheel: Bool { get { return !isInGameMode } set {} }
    
    init(hand: InversionController.Handedness, inversionControl: InversionController, speedControl: SpeedController)
    {
        super.init(hand: hand, inversionControl: inversionControl, speedControl: speedControl, startsInGameMode: false, secondaryCameraPosition: SCNVector3(x: -2, y: 6, z: 6))
    }
    
    func switchToGameMode()
    {
        isInGameMode = true
        player.switchToGameMode()
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        cameraNode.constraints = [lookAtOrigin]
        
        SCNTransaction.commit()
        
        cameraNode.position = gameModeCameraPosition
        
        SCNTransaction.commit()
        
        cameraNode.camera?.orthographicScale = gameModeCameraScale
        for node in gameObjectsNode.childNodes
        {
            node.opacity = 1
        }
        
        SCNTransaction.commit()
    }
    
    func switchToPracticeMode()
    {
        isInGameMode = false
        
        if player.node.parent != nil
        {
            player.switchToPracticeMode()
        }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 2
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 4
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        cameraNode.constraints = [lookAtPlayer]
        
        SCNTransaction.commit()
        
        cameraNode.position = secondaryModeCameraPosition
        
        SCNTransaction.commit()
        
        cameraNode.camera?.orthographicScale = secondaryModeCameraScale
        for node in gameObjectsNode.childNodes
        {
            if node.name != Constants.Player { node.opacity = 0 }
        }
        
        SCNTransaction.commit()
    }
    
    func pausePressed()
    {
        isManuallyPaused = true
        physicsWorld.speed = 0
        if let confetti = player.popNode?.particleSystems?.first
        {
            confetti.speedFactor = 0
            frozenConfetti = confetti
        }
    }
    
    func playPressed()
    {
        isManuallyPaused = false
        physicsWorld.speed = 1
        frozenConfetti?.speedFactor = 1
        frozenConfetti = nil
    }
    
    func invert(hand: InversionController.Handedness, duration: TimeInterval, completion: @escaping () -> Void)
    {
        handedness = hand
        flipPositionVectors()
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.completionBlock = completion
        
        cameraNode.position = gameModeCameraPosition
        lightNode.position = omniLightNodePosition
        
        SCNTransaction.commit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

