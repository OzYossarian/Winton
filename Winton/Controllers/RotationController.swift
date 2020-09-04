//
//  RotationController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit

class RotationController: RotationDemoDelegate
{
    private var gameScene: BaseGameScene!
    private var practiceHud: PracticeHud!
    
    private let varianceThreshold: Float = 0.5
    
    private var currentPanX: CGFloat = 0
    private var currentPanY: CGFloat = 0
    private var currentPanSubGestureCount = 0
    private var currentPanSubGestureAngles: [Float] = []
    
    private let rightHandedRotations: [Rotation: SCNVector3] = [
        Rotation.right: SCNVector3(0, 1, 0),
        Rotation.upRight: SCNVector3(0, 0, -1),
        Rotation.upLeft: SCNVector3(-1, 0, 0),
        Rotation.left: SCNVector3(0, -1, 0),
        Rotation.downLeft: SCNVector3(0, 0, 1),
        Rotation.downRight: SCNVector3(1, 0, 0)]
    
    private let leftHandedRotations: [Rotation: SCNVector3] = [
        Rotation.right: SCNVector3(0, 1, 0),
        Rotation.upRight: SCNVector3(1, 0, 0),
        Rotation.upLeft: SCNVector3(0, 0, -1),
        Rotation.left: SCNVector3(0, -1, 0),
        Rotation.downLeft: SCNVector3(-1, 0, 0),
        Rotation.downRight: SCNVector3(0, 0, 1)]
    
    private var rightHanded: Bool
    {
        get { return handedness == InversionController.Handedness.right }
    }
    
    private var rotations: [Rotation: SCNVector3]
    {
        get { return rightHanded ? rightHandedRotations : leftHandedRotations }
    }
    
    private var handedness: InversionController.Handedness!
    private var inversionController: InversionController
    
    private var rotationsCount = 0
    private let practiceThreshold = 3
    private var practiceCompleted = false
    
    init(scene: BaseGameScene, hud: PracticeHud, hand: InversionController.Handedness, inversionControl: InversionController)
    {
        gameScene = scene
        practiceHud = hud
        handedness = hand
        inversionController = inversionControl
    }
    
    func convertPanToRotation(locationInHud: CGPoint, translation: CGPoint, state: UIGestureRecognizer.State)
    {
        if state == UIGestureRecognizer.State.began
        {
            resetState() // ToDo: check this solves anything.
            if gameScene.canDisplayRotationWheel
            {
                practiceHud.rotationWheel.showBase(location: locationInHud)
            }
        }
        
        currentPanX += translation.x
        currentPanY += (-translation.y) // N.B. y is positive in downward direction.
        currentPanSubGestureCount += 1
        
        let subGestureAngleInRadians = atan2f(Float((-translation.y)), Float(translation.x))
        currentPanSubGestureAngles.append(subGestureAngleInRadians)
        
        if (state == UIGestureRecognizer.State.ended && currentPanSubGestureCount > 0)
        {
            if currentPanSubGestureCount > 0 && getGestureVariance() <= varianceThreshold
            {
                let angleInRadians = atan2f(
                    Float(currentPanY)/Float(currentPanSubGestureCount),
                    Float(currentPanX)/Float(currentPanSubGestureCount))
                let angleInDegrees = angleInRadians * 180/Float.pi
                
                if let rotation = getRotation(angle: angleInDegrees)
                {
                    rotate(rotation)
                }
                else if gameScene.canDisplayRotationWheel
                {
                    practiceHud.rotationWheel.fadeOut()
                }
            }
            else if gameScene.canDisplayRotationWheel
            {
                practiceHud.rotationWheel.fadeOut()
            }
            
            resetState()
        }
    }
    
    private func rotate(_ rotation: Rotation)
    {
        gameScene.player.queueRotation(axis: rotations[rotation]!)
        if gameScene.canDisplayRotationWheel
        {
            practiceHud.rotationWheel.showRotation(rotation)
        }
        incrementRotations()
    }
    
    func incrementRotations()
    {
        rotationsCount += 1
        if !practiceCompleted && rotationsCount >= practiceThreshold
        {
            practiceHud.fadeInLabel()
            practiceCompleted = true
        }
    }
    
    func demonstrateRotation(_ rotation: Rotation)
    {
        rotate(rotation)
    }
    
    private func getGestureVariance() -> Float
    {
        let angles = currentPanSubGestureAngles
        let cosSum = angles.map({(angle) -> Float in cos(angle)}).reduce(0, +)
        let sinSum = angles.map({(angle) -> Float in sin(angle)}).reduce(0, +)
        let R = sqrt(powf(cosSum, 2) + powf(sinSum, 2))
        let variance = 1 - R/Float(angles.count)
        
        return variance
    }
    
    private func getRotation(angle: Float) -> Rotation?
    {
        if -25 < angle && angle <= 25
        {
            return Rotation.right
        }
        else if 25 < angle && angle <= 90
        {
            return Rotation.upRight
        }
        else if 90 < angle && angle <= 155
        {
            return Rotation.upLeft
        }
        else if 155 < angle && angle <= 180 || -180 <= angle && angle <= -155
        {
            return Rotation.left
        }
        else if -155 < angle && angle <= -90
        {
            return Rotation.downLeft
        }
        else if -90 < angle && angle <= -25
        {
            return Rotation.downRight
        }
        else
        {
            return nil
        }
    }
    
    func invert(hand: InversionController.Handedness)
    {
        handedness = hand
    }
    
    enum Rotation
    {
        case base
        case right
        case upRight
        case upLeft
        case left
        case downLeft
        case downRight
    }
    
    
    private func resetState()
    {
        currentPanX = 0
        currentPanY = 0
        currentPanSubGestureCount = 0
        currentPanSubGestureAngles = []
    }
}

