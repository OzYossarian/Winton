//
//  GameHud.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import UIKit
import SpriteKit

class GameHud: InvertibleHud
{
    private var _score = 0
    private var _highScore: Int = 0
    
    private(set) var score: Int
    {
        get { return _score }
        set { _score = newValue; scoreLabelNode.text = "\(_score)" }
    }
    private(set) var highScore: Int
    {
        get { return _highScore }
        set { _highScore = newValue; highScoreLabelNode.text = "BEST: \(_highScore)" }
    }
    private var lastLoadedHighScore: Int = 0
    
    private var pauseAndPlayNode: SKNode!
    private(set) var pauseButtonNode: SKSpriteNode!
    private(set) var playButtonNode: SKSpriteNode!
    
    private var soundsNode: SKNode!
    private(set) var soundPlayingNode: SKSpriteNode!
    private(set) var soundMutedNode: SKSpriteNode!
    
    private var scoresNode: SKNode!
    private var scoreLabelNode: SKLabelNode!
    private var highScoreLabelNode: SKLabelNode!
    
    private var pauseMenuNode: SKNode!
    private(set) var invertNode: SKLabelNode!
    private(set) var practiceNode: SKLabelNode!
    
    private var blurNode: SKNode!
    private let blurAlpha: CGFloat = 0.8
    
    private var visibleSoundNode: SKSpriteNode
    {
        get { return SessionInfo.SoundEnabled ? soundPlayingNode : soundMutedNode }
    }
    private var nodesVisibleOnlyWhenPaused: [SKNode]
    {
        get { return pauseMenuNode.children + [visibleSoundNode] }
    }
    private var nodesInvisibleWhenPlaying: [SKNode]
    {
        get { return pauseMenuNode.children + soundsNode.children + [blurNode] }
    }
    private var invertibleNodes: [SKNode]
    {
        get { return scoresNode.children + soundsNode.children + pauseAndPlayNode.children }
    }
    
    private(set) var isANewHighScore: Bool = false
    private var pausedActions: [SKAction] = []
    private let highlightColour = UIColor.red
    
    override init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets, hand: InversionController.Handedness, inversionControl: InversionController)
    {
        super.init(size: size, safeSize: safeSize, insets: insets, hand: hand, inversionControl: inversionControl)
        
        initialiseScene()
    }
    
    private func initialiseScene()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(saveGame), name: Constants.SaveGame, object: nil)
        
        initialiseBlur()
        initialiseIntermediateNodes()
        initialiseScoreNodes()
        initialisePauseNodes()
        initialiseSoundNodes()
        initialisePauseMenu()
        highScore = loadHighScore()
    }
    
    private func loadHighScore() -> Int
    {
        let defaults = UserDefaults.standard
        let highScoreExists = defaults.dictionaryRepresentation().keys.contains(Constants.HighScoreKey)
        lastLoadedHighScore = highScoreExists
            ? defaults.integer(forKey: Constants.HighScoreKey)
            : lastLoadedHighScore
        
        return lastLoadedHighScore
    }
    
    private func initialiseBlur()
    {
        blurNode = SKSpriteNode(color: UIColor.white, size: self.size)
        blurNode.position = trueCenter
        blurNode.alpha = 0
        blurNode.zPosition = -1
        addChild(blurNode)
    }
    
    private func initialiseIntermediateNodes()
    {
        pauseAndPlayNode = SKNode()
        soundsNode = SKNode()
        scoresNode = SKNode()
        pauseMenuNode = SKNode()
        
        addChild(pauseAndPlayNode)
        addChild(soundsNode)
        addChild(scoresNode)
        addChild(pauseMenuNode)
    }
    
    private func initialiseScoreNodes()
    {
        let scorePosition = CGPoint(x: safeAreaLeft + 70, y: safeAreaTop - 65)
        scoreLabelNode = standardLabelNode(fontSize: Constants.BigFont, position: scorePosition, alignment: SKLabelHorizontalAlignmentMode.left, text: "\(score)", colour: UIColor.black)
        
        let highScorePosition = CGPoint(x: safeAreaLeft + 14, y: safeAreaTop - 100)
        highScoreLabelNode = standardLabelNode(fontSize: Constants.SmallFont, position: highScorePosition, alignment: SKLabelHorizontalAlignmentMode.left, text: "BEST: \(highScore)", colour: UIColor.black)
        
        scoresNode.addChild(scoreLabelNode)
        scoresNode.addChild(highScoreLabelNode)
        
        if handedness != InversionController.Handedness.right
        {
            inversionController.flipLabelNode(node: scoreLabelNode, sceneSize: self.size)
            inversionController.flipLabelNode(node: highScoreLabelNode, sceneSize: self.size)
        }
    }
    
    private func initialisePauseNodes()
    {
        pauseButtonNode = SKSpriteNode(imageNamed: "art.scnassets/PauseChalk2.png")
        pauseButtonNode.position = CGPoint(x: safeAreaLeft + 35, y: safeAreaTop - 38)
        pauseAndPlayNode.addChild(pauseButtonNode)
        
        playButtonNode = SKSpriteNode(imageNamed: "art.scnassets/PlayChalk2.png")
        playButtonNode.position = CGPoint(x: safeAreaLeft + 38, y: safeAreaTop - 38)
        playButtonNode.isHidden = true
        pauseAndPlayNode.addChild(playButtonNode)
        
        if handedness != InversionController.Handedness.right
        {
            for node in [pauseButtonNode, playButtonNode]
            {
                inversionController.flipNode(node: node!, sceneSize: self.size)
            }
        }
    }

    private func initialiseSoundNodes()
    {
        let position = CGPoint(x: safeAreaRight - 38, y: safeAreaTop - 38)
        
        soundPlayingNode = SKSpriteNode(imageNamed: "art.scnassets/SoundOnChalk.png")
        soundPlayingNode.position = position
        soundPlayingNode.alpha = 0
        soundsNode.addChild(soundPlayingNode)
        
        soundMutedNode = SKSpriteNode(imageNamed: "art.scnassets/SoundMutedChalk.png")
        soundMutedNode.position = position
        soundMutedNode.alpha = 0
        soundsNode.addChild(soundMutedNode)
        
        if handedness != InversionController.Handedness.right
        {
            for node in [soundPlayingNode, soundMutedNode]
            {
                inversionController.flipNode(node: node!, sceneSize: self.size)
            }
        }
    }
    
    private func initialisePauseMenu()
    {
        let fontSize = Constants.MediumFont
        let colour = UIColor.black
        let offset: CGFloat = 60
        
        invertNode = standardLabelNode(fontSize: fontSize, position: CGPoint(x: safeAreaCenterX, y: trueCenterY + offset/2), alignment: SKLabelHorizontalAlignmentMode.center, text: "INVERT", colour: colour)
        practiceNode = standardLabelNode(fontSize: fontSize, position: CGPoint(x: safeAreaCenterX, y: trueCenterY - offset/2), alignment: SKLabelHorizontalAlignmentMode.center, text: "PRACTICE", colour: colour)
        
        for node in [invertNode, practiceNode]
        {
            node?.alpha = 0
            pauseMenuNode.addChild(node!)
        }
    }
    
    func pausePressed()
    {
        pauseButtonNode.isHidden = true
        playButtonNode.isHidden = false
        
        backgroundColor = UIColor.white
        
        let fadeInDuration = 0.2
        blurNode.run(SKAction.fadeAlpha(to: blurAlpha, duration: fadeInDuration))
        for node in nodesVisibleOnlyWhenPaused
        {
            node.run(SKAction.fadeAlpha(to: 1, duration: fadeInDuration))
        }
        
        for node in scoresNode.children
        {
            for key in [Constants.HighlightAction, Constants.ResetAction]
            {
                if let action = node.action(forKey: key)
                {
                    pausedActions.append(action)
                    action.speed = 0
                }
            }
        }
        
        saveGame()
    }
    
    func playPressed()
    {
        playButtonNode.isHidden = true
        pauseButtonNode.isHidden = false
        
        let fadeOutDuration = 0.2
        for node in nodesInvisibleWhenPlaying
        {
            node.run(SKAction.fadeAlpha(to: 0, duration: fadeOutDuration))
        }
        
        for action in pausedActions
        {
            action.speed = 1
        }
        pausedActions = []
    }
    
    func soundActivated()
    {
        SessionInfo.SoundEnabled = true
        soundMutedNode.alpha = 0
        soundPlayingNode.alpha = 1
    }
    
    func soundMuted()
    {
        SessionInfo.SoundEnabled = false
        soundPlayingNode.alpha = 0
        soundMutedNode.alpha = 1
    }
    
    func resetScore()
    {
        let highlightDuration: TimeInterval = 1.5
        let highlight = getChangeTextColourAction(duration: highlightDuration, colour: highlightColour)
        let wait = SKAction.wait(forDuration: highlightDuration)
        let firstScoreAction = isANewHighScore ? wait : highlight
        
        let fadeOutDuration: TimeInterval = 0.75
        let fadeOut = SKAction.fadeOut(withDuration: fadeOutDuration)
        let reset = SKAction.customAction(withDuration: 0.5, actionBlock: {(node, timeElapsed) in
            let labelNode = node as! SKLabelNode
            self.score = 0
            labelNode.fontColor = SKColor.black
        })
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let scoreSequence = SKAction.sequence([firstScoreAction, fadeOut, reset, fadeIn])
        
        var highScoreActions: [SKAction] = []
        if isANewHighScore
        {
            let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let backToBlack = getChangeTextColourAction(duration: fadeOutDuration, colour: black)
            highScoreActions = [wait, backToBlack]
        }
        let highScoreSequence = SKAction.sequence(highScoreActions)
        
        scoreLabelNode.run(scoreSequence, withKey: Constants.ResetAction)
        highScoreLabelNode.run(highScoreSequence, withKey: Constants.ResetAction)
        
        isANewHighScore = false
    }
    
    private func getChangeTextColourAction(duration: TimeInterval, colour: UIColor) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: {(node, timeElapsed) in
            let labelNode = node as! SKLabelNode
            let newColorParts = colour.cgColor.components
            let oldColorParts = labelNode.fontColor!.cgColor.components
            
            let timeFactor = CGFloat(timeElapsed/CGFloat(duration))
            let red = oldColorParts![0] + (newColorParts![0] - oldColorParts![0]) * timeFactor
            let green = oldColorParts![1] + (newColorParts![1] - oldColorParts![1]) * timeFactor
            let blue = oldColorParts![2] + (newColorParts![2] - oldColorParts![2]) * timeFactor
            let alpha = oldColorParts![3] + (newColorParts![3] - oldColorParts![3]) * timeFactor
            
            labelNode.fontColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        })
    }
    
    func incrementScore()
    {
        score += 1
        if score > highScore
        {
            if !isANewHighScore // As in it wasn't a new high score until now.
            {
                let highlight = getChangeTextColourAction(duration: 0.5, colour: highlightColour)
                scoreLabelNode.run(highlight, withKey: Constants.HighlightAction)
                highScoreLabelNode.run(highlight, withKey: Constants.HighlightAction)
            }
            
            isANewHighScore = true
            highScore = score
        }
    }
    
    func invert(hand: InversionController.Handedness, duration: TimeInterval)
    {
        super.invert(hand: hand)
        
        let fadeOut = SKAction.fadeOut(withDuration: duration/2)
        let fadeIn = SKAction.fadeIn(withDuration: duration/2)
        
        let flipNode = SKAction.customAction(withDuration: 0, actionBlock: { (node, timeElapsed) in
            if let labelNode = node as? SKLabelNode
            {
                self.inversionController.flipLabelNode(node: labelNode, sceneSize: self.size)
            }
            else
            {
                self.inversionController.flipNode(node: node, sceneSize: self.size)
            }
        })
        for node in invertibleNodes
        {
            node.run(SKAction.sequence([fadeOut, flipNode, fadeIn]))
        }
        
        let denominator: Double = 12
        let disable = SKAction.fadeAlpha(to: 0.5, duration: duration/denominator)
        let wait = SKAction.wait(forDuration: (denominator - 2) * duration/denominator)
        let enable = SKAction.fadeAlpha(to: 1, duration: duration/denominator)
        
        for node in pauseMenuNode.children
        {
            node.run(SKAction.sequence([disable, wait, enable]))
        }
    }
    
    @objc private func saveGame()
    {
        if highScore != lastLoadedHighScore
        {
            UserDefaults.standard.set(highScore, forKey: Constants.HighScoreKey)
            _ = loadHighScore()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

