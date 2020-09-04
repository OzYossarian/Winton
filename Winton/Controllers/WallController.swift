//
//  WallController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit

class WallController: WallRequestDelegate
{
    private var gameScene: BaseGameScene!
    private var speedController: SpeedController!
    
    var isSpawnActive: Bool = false
    var mostRecentWall: SCNNode? = nil
    
    private let wallsDistanceApart: Double = 21
    let wallSpawnPosition = -15
    private let wallGarbageCollectThreshold = 20
    private let velocityUpdateRate = 10
    private var framesSinceLastVelocityUpdate = 0
    
    private var wallSpawnInterval: TimeInterval
    {
        get { return wallsDistanceApart/speedController.wallSpeed }
    }
    
    private var requestedWallsQueue: [String] = []
    
    private var nextWallBuildTime: TimeInterval
    private var lastUsedWallTypeKey: UInt32 = 6
    
    private var squareWallNode: SCNNode!
    private var circleWallNode: SCNNode!
    private var leftTriangleWallNode: SCNNode!
    private var rightTriangleWallNode: SCNNode!
    private var upTriangleWallNode: SCNNode!
    private var downTriangleWallNode: SCNNode!
    
    private var pausedAt: TimeInterval = 0
    private var pauseLength: TimeInterval = 0
    
    init(scene: BaseGameScene, speedControl: SpeedController, nextWallAt: TimeInterval)
    {
        gameScene = scene
        speedController = speedControl
        nextWallBuildTime = nextWallAt
        
        unloadAssets()
    }
    
    private func unloadAssets()
    {
        let squareScene = SCNScene(named: "art.scnassets/wallSquare.dae")!
        squareWallNode = squareScene.rootNode.childNode(withName: "Cube", recursively: true)!
        squareWallNode.name = Constants.Square
        
        let circleScene = SCNScene(named: "art.scnassets/wallCircle.dae")!
        circleWallNode = circleScene.rootNode.childNode(withName: "Cube", recursively: true)!
        circleWallNode.name = Constants.Circle
        
        let leftTriangleScene = SCNScene(named: "art.scnassets/wallLeftTriangle.dae")!
        leftTriangleWallNode = leftTriangleScene.rootNode.childNode(withName: "Cube", recursively: true)!
        leftTriangleWallNode.name = Constants.LeftTriangle
        
        let rightTriangleScene = SCNScene(named: "art.scnassets/wallRightTriangle.dae")!
        rightTriangleWallNode = rightTriangleScene.rootNode.childNode(withName: "Cube", recursively: true)!
        rightTriangleWallNode.name = Constants.RightTriangle
        
        let upTriangleScene = SCNScene(named: "art.scnassets/wallUpTriangle.dae")!
        upTriangleWallNode = upTriangleScene.rootNode.childNode(withName: "Cube", recursively: true)!
        upTriangleWallNode.name = Constants.UpTriangle
        
        let downTriangleScene = SCNScene(named: "art.scnassets/wallDownTriangle.dae")!
        downTriangleWallNode = downTriangleScene.rootNode.childNode(withName: "Cube", recursively: true)!
        downTriangleWallNode.name = Constants.DownTriangle
    }
    
    func ping(time: TimeInterval)
    {
        if framesSinceLastVelocityUpdate == velocityUpdateRate
        {
            manageWallVelocities()
            
            if pausedAt > 0
            {
                pauseLength = time - pausedAt
                pausedAt = 0
            }
            
            if shouldBuildWall(currentTime: time)
            {
                buildWall()
                nextWallBuildTime = time + wallSpawnInterval
                
                if pauseLength > 0 { pauseLength = 0 }
            }
            
            deleteWalls(threshold: wallGarbageCollectThreshold)
            framesSinceLastVelocityUpdate = 0
        }
        else
        {
            framesSinceLastVelocityUpdate += 1
        }
    }
    
    private func shouldBuildWall(currentTime: TimeInterval) -> Bool
    {
        return currentTime >= nextWallBuildTime + pauseLength
            && (isSpawnActive || !requestedWallsQueue.isEmpty)
    }
    
    func wallsExist() -> Bool
    {
        return !gameScene.wallsNode.childNodes.isEmpty
    }
    
    func pausePressed(time: TimeInterval)
    {
        pausedAt = time
    }
    
    private func manageWallVelocities()
    {
        for node in gameScene.wallsNode.childNodes
        {
            node.physicsBody?.velocity = SCNVector3(speedController.wallSpeed, 0, 0)
        }
    }
    
    func enterEndGameSequence(collisionWall: SCNNode)
    {
        paintWallRed(collisionWall)
        isSpawnActive = false
    }
    
    func restartGame()
    {
        speedController.resetGameSpeed()
        isSpawnActive = true
    }
    
    private func paintWallRed(_ wall: SCNNode)
    {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        let geometry = wall.geometry?.copy() as? SCNGeometry
        geometry?.materials = [material]
        wall.geometry = geometry
        
        SCNTransaction.commit()
    }
    
    private func buildWall()
    {
        let type = requestedWallsQueue.isEmpty
            ? getRandomWallType()
            : requestedWallsQueue.remove(at: 0)
        
        spawnWall(type: type)
    }
    
    private func getRandomWallType() -> String
    {
        var wallTypeKey: UInt32
        repeat { wallTypeKey = arc4random_uniform(6) } while wallTypeKey == lastUsedWallTypeKey
        lastUsedWallTypeKey = wallTypeKey
        
        var wallType: String!
        switch wallTypeKey
        {
            case 0:
                wallType = Constants.Square
            case 1:
                wallType = Constants.Circle
            case 2:
                wallType = Constants.LeftTriangle
            case 3:
                wallType = Constants.RightTriangle
            case 4:
                wallType = Constants.UpTriangle
            case 5:
                wallType = Constants.DownTriangle
            default:
                fatalError("Unknown wall type.")
        }
        return wallType
    }
    
    private func spawnWall(type: String)
    {
        var wallNode: SCNNode!
        switch type
        {
            case Constants.Square:
                wallNode = squareWallNode.clone()
            case Constants.Circle:
                wallNode = circleWallNode.clone()
            case Constants.LeftTriangle:
                wallNode = leftTriangleWallNode.clone()
            case Constants.RightTriangle:
                wallNode = rightTriangleWallNode.clone()
            case Constants.UpTriangle:
                wallNode = upTriangleWallNode.clone()
            case Constants.DownTriangle:
                wallNode = downTriangleWallNode.clone()
            default:
                fatalError("Unknown wall type.")
        }
        
        wallNode.geometry?.materials.first?.diffuse.contents = UIColor.gray
        
        wallNode.position = SCNVector3(wallSpawnPosition, 0, 0)
        wallNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        wallNode.physicsBody?.isAffectedByGravity = false
        wallNode.physicsBody?.damping = 0
        wallNode.physicsBody?.friction = 0
        wallNode.physicsBody?.rollingFriction = 0
        
        wallNode.physicsBody?.categoryBitMask = Constants.WallCategory
        wallNode.physicsBody?.contactTestBitMask = Constants.PlayerCategory
        wallNode.physicsBody?.collisionBitMask = Constants.NothingCategory
        
        gameScene.wallsNode.addChildNode(wallNode)
        speedController.incrementGameSpeed()
    }
    
    func requestWall(type: String)
    {
        requestedWallsQueue.append(type)
    }
    
    func deleteWalls(threshold: Int)
    {
        for node in gameScene.wallsNode.childNodes
        {
            if node.presentation.position.x >= Float(threshold)
            {
                node.removeFromParentNode()
            }
        }
    }
}


