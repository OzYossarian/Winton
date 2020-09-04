//
//  WelcomeViewData.swift
//  Winton
//
//  Created by Alex Teague on 03/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation

class WelcomeViewData
{
    let handedness: InversionController.Handedness
    let initialViewController: String
    
    init(hand: InversionController.Handedness, viewController: String)
    {
        handedness = hand
        initialViewController = viewController
    }
}
