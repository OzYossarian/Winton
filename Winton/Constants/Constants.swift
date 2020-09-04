//
//  Constants.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit

struct Constants
{
    static let NothingCategory = 0
    static let PlayerCategory = 1
    static let WallCategory = 1 << 1
    
    static let Square = "Square"
    static let Circle = "Circle"
    static let LeftTriangle = "LeftTriangle"
    static let RightTriangle = "RightTriangle"
    static let UpTriangle = "UpTriangle"
    static let DownTriangle = "DownTriangle"
    
    static let PauseGame = NSNotification.Name(rawValue: "PauseGame")
    static let UnPauseGame = NSNotification.Name(rawValue: "UnPauseGame")
    static let SaveGame = NSNotification.Name(rawValue: "SaveGame")
    
    static let HighScoreKey = "HighScore"
    static let HandednessKey = "Handedness"
    static let TutorialCompletedKey = "TutorialCompleted"
    static let PracticeCompletedKey = "PracticeCompleted"
    
    static let BigFont: CGFloat = 73
    static let MediumFont: CGFloat = 40
    static let SmallFont: CGFloat = 24
    
    static let HighlightAction = "HighlightAction"
    static let ResetAction = "ResetAction"
    
    static let EnterGameView = "EnterGameView"
    
    static let Player = "Player"
    
    static let PopNormal = "PopNormal"
    static let PopColour = "PopColour"
    
    static let PopSound = "Pop.wav"
    static let SuccessSound = "Success.wav"
    
    static let GameViewController = "GameViewController"
    static let TutorialViewController = "TutorialViewController"
}

