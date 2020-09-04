//
//  InvertibleHud.swift
//  Winton
//
//  Created by Alex Teague on 05/04/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SpriteKit

class InvertibleHud: BaseHud
{
    private(set) var handedness: InversionController.Handedness = InversionController.DefaultHandedness
    private(set) var inversionController: InversionController!
    
    init(size: CGSize, safeSize: CGSize, insets: UIEdgeInsets, hand: InversionController.Handedness, inversionControl: InversionController)
    {
        super.init(size: size, safeSize: safeSize, insets: insets)
        
        handedness = hand
        inversionController = inversionControl
    }
    
    internal func invert(hand: InversionController.Handedness)
    {
        handedness = hand
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
