//
//  ActualGameViewController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit
import SceneKit

class GameViewController: BaseGameViewController //, SCNSceneRendererDelegate
{
    private var gameScene: GameScene!
    private var gameHud: GameHud!
    
    private var isInverting: Bool = false
    private var pausePressed = false
    
    private var currentGameTime: TimeInterval = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        gameView!.delegate = self
        
        speedController = SpeedController(wallSpeed: 5.5, wallIncrement: 0.1)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if !SessionInfo.GameAppearedAlready
        {
            initialiseHuds()
            initialiseScene()
            initialiseControllers()
            
            SessionInfo.GameAppearedAlready = true
        }
    }
    
    private func initialiseHuds()
    {
        gameHud = GameHud(size: gameView.frame.size, safeSize: gameView.safeAreaLayoutGuide.layoutFrame.size, insets: gameView.safeAreaInsets, hand: handedness, inversionControl: inversionController)
        practiceHud = PracticeHud(size: gameView.frame.size, safeSize: gameView.safeAreaLayoutGuide.layoutFrame.size, insets: gameView.safeAreaInsets, hand: handedness, inversionControl: inversionController)
        
        gameView.overlaySKScene = practiceHud
    }
    
    private func initialiseScene()
    {
        gameScene = GameScene(hand: handedness, inversionControl: inversionController, speedControl: speedController)
        gameScene.physicsWorld.contactDelegate = super.self()
        gameView.scene = gameScene
        gameView.isPlaying = true
        
        baseScene = gameScene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        currentGameTime = time
        
        if !pausePressed
        {
            wallController?.ping(time: time)
        }
        
        if isInEndGameMode && !wallController.wallsExist()
        {
            restartGame()
        }
    }
    
    private func restartGame()
    {
        isInEndGameMode = false
        gameScene.initialisePlayer()
        wallController.restartGame()
    }
    
    internal override func rotationEnabled() -> Bool
    {
        return !isInEndGameMode
            && !(gameScene.isManuallyPaused && gameScene.isInGameMode)
    }
    
    @objc internal override func tapRecognised(_ tap: UITapGestureRecognizer)
    {
        let location = tap.location(in: gameView)
        let locationInHud = getLocationInHud(locationInView: location)
        
        if gameScene.isInGameMode
        {
            let nodesAtPoint = gameHud.nodes(at: locationInHud)
            if !gameScene.isManuallyPaused && nodesAtPoint.contains(gameHud.pauseButtonNode)
            {
                pauseGame()
            }
            else if gameScene.isManuallyPaused && !isInverting
            {
                pauseScreenTapRecognised(nodesAtPoint)
            }
        }
        else
        {
            if practiceHud.labelNode.contains(locationInHud)
            {
                switchToGameMode()
            }
        }
    }
    
    private func pauseScreenTapRecognised(_ nodesAtPoint: [SKNode])
    {
        if nodesAtPoint.contains(gameHud.playButtonNode)
        {
            unPauseGame()
        }
        else if nodesAtPoint.contains(gameHud.invertNode)
        {
            invertGame()
        }
        else if nodesAtPoint.contains(gameHud.practiceNode)
        {
            switchToPracticeMode()
        }
        else if SessionInfo.SoundEnabled && nodesAtPoint.contains(gameHud.soundPlayingNode)
        {
            gameHud.soundMuted()
        }
        else if !SessionInfo.SoundEnabled && nodesAtPoint.contains(gameHud.soundMutedNode)
        {
            gameHud.soundActivated()
        }
    }
    
    private func switchToGameMode()
    {
        swapHuds()
        wallController.isSpawnActive = true
        gameScene.switchToGameMode()
    }
    
    private func switchToPracticeMode()
    {
        swapHuds()
        gameScene.switchToPracticeMode()
        if isInEndGameMode
        {
            wallController.deleteWalls(threshold: wallController.wallSpawnPosition)
        }
    }
    
    private func swapHuds()
    {
        let newHud = gameView.overlaySKScene == practiceHud ? gameHud : practiceHud
        
        let fadeDuration = 0.5
        gameView.overlaySKScene?.run(SKAction.fadeOut(withDuration: fadeDuration), completion: {
            self.gameView.overlaySKScene = newHud
            newHud!.run(SKAction.fadeIn(withDuration: fadeDuration))
        })
    }
    
    @objc internal override func pauseGame()
    {
        if gameScene!.isInGameMode && !pausePressed
        {
            pausePressed = true
            
            wallController.pausePressed(time: currentGameTime)
            gameHud.pausePressed()
            gameScene.pausePressed()
        }
    }
    
    private func unPauseGame()
    {
        gameHud.playPressed()
        gameScene.playPressed()
        
        pausePressed = false
    }
    
    private func invertGame()
    {
        isInverting = true
        
        handedness = rightHanded ? InversionController.Handedness.left : InversionController.Handedness.right
        
        let inversionDuration: TimeInterval = 2.5
        gameScene.invert(hand: handedness, duration: inversionDuration, completion: {
            self.isInverting = false })
        gameHud.invert(hand: handedness, duration: inversionDuration)
        
        practiceHud.invert(hand: handedness)
        rotationController.invert(hand: handedness)
    }
    
    internal override func successfulCollision()
    {
        gameHud.incrementScore()
        if SessionInfo.SoundEnabled && successPlayer != nil
        {
            DispatchQueue.global().async {
                self.successPlayer?.play()
            }
        }
    }
    
    internal override func enterEndGameSequence(collisionWall: SCNNode)
    {
        isInEndGameMode = true
        
        wallController.enterEndGameSequence(collisionWall: collisionWall)
        gameScene.player.pop(isANewHighScore: gameHud.isANewHighScore)
        gameHud.resetScore()
        
        if SessionInfo.SoundEnabled && popPlayer != nil
        {
            DispatchQueue.global().async {
                self.popPlayer?.play()
            }
        }
    }
}

