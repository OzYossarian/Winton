//
//  Player.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit

class Player
{
    private let _node: SCNNode!
    var node: SCNNode! { get { return _node } }
    private(set) var popNode: SCNNode?
    private(set) var popSystem: SCNParticleSystem?
    
    private(set) var rotationUponSwitchingToPracticeMode = SCNVector4(0,0,0,0)
    var isResettingRotation = false
    
    private var rotationQueue: RotationQueue<SCNVector3>!
    
    private var speedController: SpeedController!
    
    private let minVertex: SCNVector3!
    private let maxVertex: SCNVector3!
    var lengthInXAxis: Float { get { return maxVertex.x - minVertex.x } }
    
    init(speedControl: SpeedController)
    {
        let playerScene = SCNScene(named: "art.scnassets/azad.dae")!
        let playerNode = playerScene.rootNode.childNode(withName: "Cylinder", recursively: true)!
        playerNode.name = Constants.Player
        _node = playerNode.clone()
        
        let (min, max) = _node.boundingBox
        minVertex = min
        maxVertex = max
        
        let colour = UIColor(red: 0.98, green: 0.95, blue: 0.9, alpha: 1)
        let material = SCNMaterial()
        material.diffuse.contents = colour
        node.geometry?.materials = [material]
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        
        node.physicsBody?.categoryBitMask = Constants.PlayerCategory
        node.physicsBody?.contactTestBitMask = Constants.WallCategory
        node.physicsBody?.collisionBitMask = Constants.NothingCategory
        
        speedController = speedControl
        rotationQueue = RotationQueue<SCNVector3>(size: 5, rotationMethod: rotate)
        
        popNode?.removeFromParentNode()
    }
    
    func queueRotation(axis: SCNVector3)
    {
        rotationQueue.enqueue(axis)
    }
    
    private func rotate(axis: SCNVector3, completion: @escaping () -> Void)
    {
        let duration = speedController.rotationDuration
        let rotation = SCNAction.rotate(by: CGFloat(Float.pi/2), around: axis, duration: duration)
        node.runAction(rotation, completionHandler: completion)
    }
    
    func isRotatedCorrectly(wallType: String) -> Bool
    {
        let (wallFace, upwardFace, otherVisibleFace) = getKeyFaceIndeces()
        
        // Index 0 - 'Front' - Normal is (0,0,1)  - Square
        // Index 1 - 'Right' - Normal is (1,0,0)  - Triangle
        // Index 2 - 'Back'  - Normal is (0,0,-1) - Sqaure
        // Index 3 - 'Left'  - Normal is (-1,0,0) - Triangle
        // Index 4 - 'Top'   - Normal is (0,1,0)  - Blade
        // Index 5 - 'Base'  - Normal is (0,-1,0) - Circle
        
        switch wallType
        {
        case Constants.Square:
            return [0,2].contains(wallFace)
        case Constants.Circle:
            return [4,5].contains(wallFace)
        case Constants.LeftTriangle:
            return [1,3].contains(wallFace) && otherVisibleFace == 5
        case Constants.RightTriangle:
            return [1,3].contains(wallFace) && otherVisibleFace == 4
        case Constants.UpTriangle:
            return [1,3].contains(wallFace) && upwardFace == 4
        case Constants.DownTriangle:
            return [1,3].contains(wallFace) && upwardFace == 5
        default:
            fatalError("Unrecognised wall type.")
        }
    }
    
    private func getKeyFaceIndeces() -> (Int, Int, Int)
    {
        let wallward = SCNVector3(-1,0,0)   // The direction of the face that hit the wall
        let upward = SCNVector3(0,1,0)      // The direction of the upwards face
        let outward = SCNVector3(0,0,1)     // The direction of the other visible face
        
        let rotatedWallward = getDirectionRotatated(direction: wallward)
        let rotatedUpward = getDirectionRotatated(direction: upward)
        let rotatedOutward = getDirectionRotatated(direction: outward)
        
        let faceNormals = [
            GLKVector3Make(0, 0, 1),    // front
            GLKVector3Make(1, 0, 0),    // right
            GLKVector3Make(0, 0, -1),   // back
            GLKVector3Make(-1, 0, 0),   // left
            GLKVector3Make(0, 1, 0),    // top
            GLKVector3Make(0, -1, 0)]   // down
        
        var bestWallwardIndex = -1
        var maxWallwardDotProduct: Float = -1
        
        var bestUpwardIndex = -1
        var maxUpwardDotProduct: Float = -1
        
        var bestOutwardIndex = -1
        var maxOutwardDotProduct: Float = -1
        
        for i in 0..<faceNormals.count
        {
            let wallwardDotProduct = GLKVector3DotProduct(faceNormals[i], rotatedWallward)
            let upwardDotProduct = GLKVector3DotProduct(faceNormals[i], rotatedUpward)
            let outwardDotProduct = GLKVector3DotProduct(faceNormals[i], rotatedOutward)
            
            if wallwardDotProduct > maxWallwardDotProduct
            {
                bestWallwardIndex = i
                maxWallwardDotProduct = wallwardDotProduct
            }
            if upwardDotProduct > maxUpwardDotProduct
            {
                bestUpwardIndex = i
                maxUpwardDotProduct = upwardDotProduct
            }
            if outwardDotProduct > maxOutwardDotProduct
            {
                bestOutwardIndex = i
                maxOutwardDotProduct = outwardDotProduct
            }
        }
        
        return (bestWallwardIndex, bestUpwardIndex, bestOutwardIndex)
    }
    
    private func getDirectionRotatated(direction: SCNVector3) -> GLKVector3
    {
        let rotation = node.presentation.rotation
        var inverseRotation = rotation
        inverseRotation.w = -inverseRotation.w;
        
        let rotationTransform = SCNMatrix4MakeRotation(
            inverseRotation.w,
            inverseRotation.x,
            inverseRotation.y,
            inverseRotation.z)
        
        let glkRotationTransform = SCNMatrix4ToGLKMatrix4(rotationTransform)
        let glkDirection = SCNVector3ToGLKVector3(direction)
        return GLKMatrix4MultiplyVector3(glkRotationTransform, glkDirection)
    }
    
    func pop(isANewHighScore: Bool)
    {
        popNode = SCNNode()
        let popKey = isANewHighScore ? Constants.PopColour : Constants.PopNormal
        popSystem = SCNParticleSystem(named: popKey, inDirectory: nil)
        popNode!.addParticleSystem(popSystem!)
        popNode!.position = node.position
        
        node.parent?.addChildNode(popNode!)
        node.removeFromParentNode()
    }
    
    func switchToPracticeMode()
    {
        rotationUponSwitchingToPracticeMode = node.presentation.rotation
    }
    
    func switchToGameMode()
    {
        let rotation = rotationUponSwitchingToPracticeMode
        node.runAction(SCNAction.rotate(toAxisAngle: rotation, duration: 1))
    }
}


