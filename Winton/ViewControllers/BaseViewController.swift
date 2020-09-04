//
//  BaseViewController.swift
//  Winton
//
//  Created by Alex Teague on 31/03/2018.
//  Copyright © 2018 Former Yugoslavic Republic of Asgaard. All rights reserved.
//

import Foundation
import SceneKit

class BaseViewController: UIViewController, SCNSceneRendererDelegate
{
    internal var handedness = InversionController.DefaultHandedness
    internal var rightHanded: Bool
    {
        get { return handedness == InversionController.Handedness.right }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func getLocationInHud(locationInView: CGPoint) -> CGPoint
    {
        return CGPoint(x: locationInView.x, y: self.view.frame.size.height - locationInView.y)
    }
}
