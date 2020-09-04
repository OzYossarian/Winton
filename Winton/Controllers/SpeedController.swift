//
//  SpeedController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation

class SpeedController
{
    private let baseWallSpeed: Double
    private let wallSpeedIncrement: Double
    private var additionalWallSpeed: Double = 0
    var wallSpeed: Double { get { return baseWallSpeed + additionalWallSpeed } }
    
    private let baseRotationDuration: Double = 0.25
    var rotationDuration: Double
    {
        get
        {
            return baseRotationDuration * exp(-(0.09 * additionalWallSpeed))
        }
    }
    
    init(wallSpeed: Double, wallIncrement: Double)
    {
        baseWallSpeed = wallSpeed
        wallSpeedIncrement = wallIncrement
    }
    
    func incrementGameSpeed()
    {
        additionalWallSpeed += wallSpeedIncrement
    }
    
    func resetGameSpeed()
    {
        additionalWallSpeed = 0
    }
}

