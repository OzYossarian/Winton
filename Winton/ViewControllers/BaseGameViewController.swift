//
//  BaseGameViewController.swift
//  Winton
//
//  Created by Alex Teague on 02/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import AVFoundation
import SceneKit

class BaseGameViewController: BaseViewController, AVAudioPlayerDelegate, SCNPhysicsContactDelegate, UITabBarControllerDelegate
{
    private(set) var gameView: SCNView!
    internal(set) var baseScene: BaseGameScene!
    
    internal(set) var practiceHud: PracticeHud!
    
    internal(set) var wallController: WallController!
    internal(set) var rotationController: RotationController!
    internal(set) var speedController: SpeedController!
    internal(set) var inversionController: InversionController!
    
    private(set) var popPlayer: AVAudioPlayer?
    private(set) var successPlayer: AVAudioPlayer?
    
    internal(set) var isInEndGameMode = false
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: Constants.PauseGame, object: nil)
        
        initialiseView()
        initialiseSoundEffects()
        initialiseInversionController()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if SessionInfo.SoundEnabled
        {
            popPlayer?.play()
        }
    }
    
    private func initialiseView()
    {
        gameView = self.view as! SCNView
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(tapRecognised(_:)))
        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(panRecognised(_:)))
        panRecogniser.maximumNumberOfTouches = 1
        panRecogniser.require(toFail: tapRecogniser)
        
        gameView!.gestureRecognizers = [tapRecogniser, panRecogniser]
    }
    
    private func initialiseSoundEffects()
    {
        if let popPath = Bundle.main.path(forResource: "Pop", ofType: "wav")
        {
            let popUrl = URL(fileURLWithPath: popPath)
            popPlayer = try? AVAudioPlayer(contentsOf: popUrl)
            popPlayer?.delegate = self
            popPlayer?.prepareToPlay()
            popPlayer?.play()
            popPlayer?.stop()
        }
        
        if let successPath = Bundle.main.path(forResource: "Success", ofType: "wav")
        {
            let successUrl = URL(fileURLWithPath: successPath)
            successPlayer = try? AVAudioPlayer(contentsOf: successUrl)
            successPlayer?.delegate = self
            successPlayer?.prepareToPlay()
            successPlayer?.play()
            successPlayer?.stop()
        }
    }
    
    private func initialiseInversionController()
    {
        let safeFrame = gameView.safeAreaLayoutGuide.layoutFrame
        let safeCenterX = gameView.safeAreaInsets.left + safeFrame.width/2
        let safeCenterY = gameView.safeAreaInsets.bottom + safeFrame.height/2
        let safeCenter = CGPoint(x: safeCenterX, y: safeCenterY)
        inversionController = InversionController(safeCenter: safeCenter)
    }
    
    internal func initialiseControllers()
    {
        wallController = WallController(scene: baseScene, speedControl: speedController, nextWallAt: 0)
        rotationController = RotationController(scene: baseScene, hud: practiceHud, hand: handedness, inversionControl: inversionController)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        player.prepareToPlay()
    }
    
    @objc internal func panRecognised(_ pan: UIPanGestureRecognizer)
    {
        if rotationEnabled()
        {
            let location = pan.location(in: gameView)
            let locationInHud = getLocationInHud(locationInView: location)
            let translation = pan.translation(in: gameView)
            
            rotationController.convertPanToRotation(locationInHud: locationInHud, translation: translation, state: pan.state)
        }
    }
    
    @objc internal func rotationEnabled() -> Bool
    {
        preconditionFailure("This method must be overridden.")
    }
    
    @objc internal func tapRecognised(_ tap: UITapGestureRecognizer)
    {
        preconditionFailure("This method must be overridden.")
    }
    
    @objc internal func pauseGame()
    {
        preconditionFailure("This method must be overridden.")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact)
    {
        if contact.nodeA == baseScene.player.node || contact.nodeB == baseScene.player.node
        {
            let wallNode = contact.nodeA != baseScene.player.node ? contact.nodeA : contact.nodeB
            let collisionLocationThreshold = baseScene.playerPosition.x + baseScene.player.lengthInXAxis/2
            if wallNode.presentation.position.x <= collisionLocationThreshold
            {
                let success = baseScene.player.isRotatedCorrectly(wallType: wallNode.name!)
                if success && wallNode != wallController.mostRecentWall
                {
                    successfulCollision()
                }
                else if !success
                {
                    enterEndGameSequence(collisionWall: wallNode)
                }
                wallController.mostRecentWall = wallNode
            }
        }
    }
    
    internal func successfulCollision()
    {
        preconditionFailure("This method must be overridden.")
    }
    
    internal func enterEndGameSequence(collisionWall: SCNNode)
    {
        preconditionFailure("This method must be overridden.")
    }
}
