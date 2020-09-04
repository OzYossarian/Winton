//
//  TutorialScene.swift
//  Winton
//
//  Created by Alex Teague on 02/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class TutorialScene: BaseGameScene
{
    private(set) var tutorialHud: TutorialHud!
    var wallRequestDelegate: WallRequestDelegate?
    
    private let defaultFont: UIFont
    private let defaultMaterial: SCNMaterial
    private let textSpeed: Float = 20
    private let aboveScreenHeight: Float = 20
    private let displayHeight: Float = -1
    
    private var rightHandTextPosition: Float = -6
    private var leftHandTextPosition: Float = 1.5
    private var textPosition: Float
    {
        get { return rightHanded ? rightHandTextPosition : leftHandTextPosition }
    }
    private var eulerAngles: SCNVector3
    {
        get { return rightHanded ? SCNVector3(0,0,0) : SCNVector3(0, Double.pi, 0) }
    }
    
    private var textNode: SCNNode!
    
    private(set) var expectedWall: String?
    private var queuedRotation: RotationController.Rotation?
    
    private var onDisplay: SCNVector3
    {
        get { return SCNVector3(textPosition, displayHeight, textNode.position.z) }
    }
    private var aboveScreen: SCNVector3
    {
        get { return SCNVector3(textPosition, aboveScreenHeight, onDisplay.z) }
    }
    
    init(hand: InversionController.Handedness, inversionControl: InversionController, speedControl: SpeedController, hud: TutorialHud)
    {
        let defaultFontSize = Constants.SmallFont
        defaultFont = UIFont.boldSystemFont(ofSize: defaultFontSize)
        
        defaultMaterial = SCNMaterial()
        defaultMaterial.diffuse.contents = UIColor.black
        
        super.init(hand: hand, inversionControl: inversionControl, speedControl: speedControl, startsInGameMode: true, secondaryCameraPosition: SCNVector3(-4,0,0))
        
        tutorialHud = hud
        
        textNode = SCNNode()
        textNode.position = SCNVector3(textPosition, aboveScreenHeight, 0)
        textNode.eulerAngles = eulerAngles
        rootNode.addChildNode(textNode)
    }
    
    func runTutorial()
    {
        changeText(newText: "TUTORIAL", scale: SCNVector3(0.06, 0.06, 0.06))
        
        let show = getMoveTo(onDisplay)
        let wait = SCNAction.wait(duration: 3)
        let float = getMoveTo(aboveScreen)

        textNode.runAction(SCNAction.sequence([show, wait, float]), completionHandler: {
            DispatchQueue.global().async {
                self.showRotationText()
            }
        })
    }
    
    private func showRotationText()
    {
        // Add an extra space before "ROTATE" if right-handed.
        let newText = rightHanded ? "SWIPE TO\n  ROTATE" : "SWIPE TO\n ROTATE"
        changeText(newText: newText, scale: SCNVector3(0.05, 0.05, 0.05))
        
        moveTextOutwards(distance: 0.5)
        
        let show = getMoveTo(onDisplay)
//        let show = SCNAction.fadeIn(duration: 1)
//        let float = SCNAction.fadeOut(duration: 1)
        let wait = SCNAction.wait(duration: 4)
        let float = getMoveTo(aboveScreen)
        let rotations = [
            RotationController.Rotation.left,
            RotationController.Rotation.upRight,
            RotationController.Rotation.upLeft]
        
        textNode.runAction(show, completionHandler: {
            DispatchQueue.global().async {
                self.demonstrateRotations(rotations)
                self.textNode.runAction(SCNAction.sequence([wait, float]), completionHandler: {
                    DispatchQueue.global().async {
                        self.showMatchWallShapeText()
                    }
                })
            }
        })
    }
    
    private func demonstrateRotations(_ rotations: [RotationController.Rotation])
    {
        let rotations = rightHanded ? rotations : rotations.map({(rotation) in inversionController.getOppositeRotation(rotation)})
        tutorialHud.simulateRotations(rotations)
    }
    
    private func showMatchWallShapeText()
    {
        let newText = rightHanded ? "   MATCH THE\nWALL'S SHAPE" : "   MATCH THE\nWALL'S SHAPE"
        changeText(newText: newText, scale: SCNVector3(0.045, 0.045, 0.045))
        
        let distance: Float = rightHanded ? 0.5 : -0.5
        moveTextOutwards(distance: distance)
        
//        let show = SCNAction.fadeIn(duration: 1)
//        let float = SCNAction.fadeOut(duration: 1)
        
        let show = getMoveTo(onDisplay)
        let wait = SCNAction.wait(duration: 4)
        let float = getMoveTo(aboveScreen)
        
        textNode.runAction(SCNAction.sequence([show, wait]), completionHandler: {
            DispatchQueue.global().async {
                self.passThroughWall()
                self.textNode.runAction(float)
            }
        })
    }
    
    func showContinueText()
    {
        let newText = rightHanded ? "TAP TO END\n  TUTORIAL" : "TAP TO END\n  TUTORIAL"
        changeText(newText: newText, scale: nil)
        
//        let show = SCNAction.fadeIn(duration: 1)
        let show = getMoveTo(onDisplay)
        textNode.runAction(show)
    }
    
    private func passThroughWall()
    {
        let wallType = Constants.DownTriangle
        wallRequestDelegate?.requestWall(type: wallType)
        expectedWall = wallType
        
        let rotation = RotationController.Rotation.upRight
        queuedRotation = rightHanded
            ? rotation
            : inversionController.getOppositeRotation(rotation)
    }
    
    private func collideWithWall()
    {
        let wallType = Constants.Square
        wallRequestDelegate?.requestWall(type: wallType)
        expectedWall = wallType
        
        let rotation = RotationController.Rotation.downRight
        queuedRotation = rightHanded
            ? rotation
            : inversionController.getOppositeRotation(rotation)
    }
    
    func wallNearingPlayer()
    {
        if queuedRotation != nil
        {
            tutorialHud.simulateRotations([queuedRotation!])
        }
        if expectedWall == Constants.DownTriangle
        {
            collideWithWall()
        }
        else if expectedWall == Constants.Square
        {
            expectedWall = nil
            queuedRotation = nil
        }
    }
    
    private func changeText(newText: String, scale: SCNVector3?)
    {
        let text = SCNText(string: newText, extrusionDepth: 1)
        
        text.materials = [defaultMaterial]
        text.font = defaultFont
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        
        textNode.scale = scale != nil ? scale! : textNode.scale
        textNode.geometry = text
    }
    
    private func moveTextOutwards(distance: Float)
    {
        rightHandTextPosition -= distance
        leftHandTextPosition -= distance
    }
    
    private func getMoveTo(_ newPosition: SCNVector3) -> SCNAction
    {
        let action = SCNAction.move(to: newPosition, duration: 1)
        action.timingMode = SCNVector3EqualToVector3(newPosition, aboveScreen)
            ? SCNActionTimingMode.easeIn
            : SCNActionTimingMode.easeOut
        return action
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
