//
//  InversionController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

class InversionController
{
    private(set) var safeAreaCenter: CGPoint!
    
    init(safeCenter: CGPoint)
    {
        safeAreaCenter = safeCenter
    }
    
    enum Handedness
    {
        case left, right
    }
    
    static let DefaultHandedness = Handedness.right
    
    func flipNode(node: SKNode, sceneSize: CGSize)
    {
        let offsetX = node.position.x - safeAreaCenter.x
        let newX = safeAreaCenter.x - offsetX
        node.position = CGPoint(x: newX, y: node.position.y)
        
//        node.position = CGPoint(x: sceneSize.width - node.position.x, y: node.position.y)
    }
    
    func flipLabelNode(node: SKLabelNode, sceneSize: CGSize)
    {
        flipNode(node: node, sceneSize: sceneSize)
        if node.horizontalAlignmentMode == SKLabelHorizontalAlignmentMode.left
        {
            node.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        }
        else if node.horizontalAlignmentMode == SKLabelHorizontalAlignmentMode.right
        {
            node.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        }
    }
    
    func flipVector(_ vector: SCNVector3) -> SCNVector3
    {
        return SCNVector3(vector.x, vector.y, (-vector.z))
    }
    
    func flipCGPoint(_ point: CGPoint, sceneSize: CGSize) -> CGPoint
    {
        let offsetX = point.x - safeAreaCenter.x
        let newX = safeAreaCenter.x - offsetX
        return CGPoint(x: newX, y: point.y)
        
//        return CGPoint(x: sceneSize.width - point.x, y: point.y)
    }
    
    func getOppositeRotation(_ rotation: RotationController.Rotation) -> RotationController.Rotation
    {
        switch rotation
        {
            case RotationController.Rotation.right:
                return RotationController.Rotation.left
            case RotationController.Rotation.upRight:
                return RotationController.Rotation.upLeft
            case RotationController.Rotation.upLeft:
                return RotationController.Rotation.upRight
            case RotationController.Rotation.left:
               return RotationController.Rotation.right
            case RotationController.Rotation.downLeft:
                return RotationController.Rotation.downRight
            case RotationController.Rotation.downRight:
                return RotationController.Rotation.downLeft
            default:
                fatalError("Unknown rotation type.")
        }
    }
    
}

