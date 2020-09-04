//
//  BaseGameScene.swift
//  Winton
//
//  Created by Alex Teague on 02/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit

class BaseGameScene: SCNScene
{
    var handedness: InversionController.Handedness = InversionController.DefaultHandedness
    var rightHanded: Bool
    {
        get { return handedness == InversionController.Handedness.right }
    }
    
    private(set) var inversionController: InversionController!
    private(set) var speedController: SpeedController!
    
    private(set) var cameraNode: SCNNode!
    private(set) var lightNode: SCNNode!
    private(set) var planeNode: SCNNode!
    
    private(set) var wallsNode: SCNNode!
    private(set) var gameObjectsNode: SCNNode!
    
    private(set) var player: Player!
    
    private(set) var lookAtOrigin: SCNLookAtConstraint!
    private(set) var lookAtPlayer: SCNLookAtConstraint!
    
    let playerPosition = SCNVector3(4, 0, 0)
    private(set) var gameModeCameraPosition = SCNVector3(x: -9, y: 12, z: 12)
    let gameModeCameraScale: Double = 5
    private(set) var secondaryModeCameraPosition: SCNVector3!
    let secondaryModeCameraScale: Double = 3
    private(set) var omniLightNodePosition = SCNVector3(x: 0, y: 4, z: 4)
    
    internal var canDisplayRotationWheel: Bool = true
    
    override init()
    {
        super.init()
    }
    
    init(hand: InversionController.Handedness, inversionControl: InversionController, speedControl: SpeedController, startsInGameMode: Bool, secondaryCameraPosition: SCNVector3)
    {
        super.init()
        
        handedness = hand
        inversionController = inversionControl
        speedController = speedControl
        secondaryModeCameraPosition = secondaryCameraPosition
        
        initialiseScene(startsInGameMode)
    }
    
    private func initialiseScene(_ startsInGameMode: Bool)
    {
        if handedness != InversionController.Handedness.right
        {
            flipPositionVectors()
        }
        
        initialiseCamera(startsInGameMode)
        initialiseLight()
        initialiseIntermediateNodes()
        initialisePlayer()
        initialiseFloor()
        initaliseLookAtConstraints(startsInGameMode)
    }
    
    internal func flipPositionVectors()
    {
        gameModeCameraPosition = inversionController.flipVector(gameModeCameraPosition)
        secondaryModeCameraPosition = inversionController.flipVector(secondaryModeCameraPosition)
        omniLightNodePosition = inversionController.flipVector(omniLightNodePosition)
    }
    
    private func initialiseCamera(_ startsInGameMode: Bool)
    {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = startsInGameMode
            ? gameModeCameraPosition
            : secondaryModeCameraPosition
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = startsInGameMode
            ? gameModeCameraScale
            : secondaryModeCameraScale
        
        rootNode.addChildNode(cameraNode)
    }
    
    private func initialiseLight()
    {
        let omniLight = SCNLight()
        omniLight.type = SCNLight.LightType.omni
        
        let ambience = SCNLight()
        ambience.type = SCNLight.LightType.ambient
        ambience.color = UIColor(white: 0.2, alpha: 1)
        
        lightNode = SCNNode()
        lightNode.light = omniLight
        lightNode.position = omniLightNodePosition
        
        rootNode.light = ambience
        rootNode.addChildNode(lightNode)
    }
    
    private func initialiseIntermediateNodes()
    {
        gameObjectsNode = SCNNode()
        rootNode.addChildNode(gameObjectsNode)
        
        wallsNode = SCNNode()
        gameObjectsNode.addChildNode(wallsNode)
    }
    
    func initialisePlayer()
    {
        player = Player(speedControl: speedController)
        player.node.position = playerPosition
        player.node.opacity = 0
        gameObjectsNode.addChildNode(player.node)
        
        let fadeIn = SCNAction.fadeIn(duration: 0.3)
        player.node.runAction(fadeIn)
    }
    
    private func initialiseFloor()
    {
        let floor = SCNFloor()
        floor.reflectivity = 0.4
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = false
        floor.materials = [material]
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0,-1.5,0)
        rootNode.addChildNode(floorNode)
    }
    
    private func initaliseLookAtConstraints(_ startsInGameMode: Bool)
    {
        lookAtPlayer = SCNLookAtConstraint(target: player.node)
        lookAtPlayer.isGimbalLockEnabled = true
        
        lookAtOrigin = SCNLookAtConstraint(target: rootNode)
        lookAtOrigin.isGimbalLockEnabled = true
        
        cameraNode.constraints = startsInGameMode ? [lookAtOrigin] : [lookAtPlayer]
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
